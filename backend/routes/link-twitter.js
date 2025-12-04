// backend/routes/user.js (or twitter.js)
import express from "express";
import User from "../models/User.js";

const router = express.Router();

router.post("/api/link-twitter", async (req, res) => {
  const { providerId, oauthToken, oauthSecret, displayName, email } = req.body;
  if (!providerId || !oauthToken || !oauthSecret) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    let user = await User.findOne({ firebaseUid: providerId });
    if (!user) {
      user = new User({ firebaseUid: providerId, displayName, email });
    }

    user.accessToken = oauthToken;
    user.accessSecret = oauthSecret;

    await user.save();
    res.json({ message: "Tokens saved successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

export default router;
