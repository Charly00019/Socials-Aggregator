// backend/routes/twitter.js
import express from "express";
import { getTimeline, postTweet } from "../services/twitter.js";
import User from "../models/User.js";
import admin from "firebase-admin";

const router = express.Router();

// GET /api/timeline
router.get("/api/timeline", async (req, res) => {
  try {
    // 1. Verify Firebase ID token
    const idToken = req.headers.authorization?.split(" ")[1];
    if (!idToken) return res.status(401).json({ error: "No Firebase token" });

    const decoded = await admin.auth().verifyIdToken(idToken);
    const firebaseUid = decoded.uid;

    // 2. Get user from MongoDB
    const user = await User.findOne({ firebaseUid });
    if (!user || !user.accessToken || !user.accessSecret) {
      return res
        .status(404)
        .json({ error: "Twitter account not linked or tokens missing" });
    }

    // 3. Fetch tweets from Twitter API
    const tweets = await getTimeline(user, { max_results: 20 });

    res.json({ tweets });
  } catch (err) {
    console.error("Timeline route error:", err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
