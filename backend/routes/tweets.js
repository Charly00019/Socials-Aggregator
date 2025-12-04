// routes/twitter.js
import express from "express";
import { getTimeline, postTweet } from "../services/twitter.js";
import { getUserAccountFromDb } from "../utils/db.js"; // implement this

const router = express.Router();

/**
 * GET /api/timeline?userId=<MongoDB user ID>
 */
router.get("/timeline", async (req, res) => {
  const { userId } = req.query;
  if (!userId) return res.status(400).json({ error: "Missing userId" });

  try {
    const accountDoc = await getUserAccountFromDb(userId);
    if (!accountDoc) return res.status(404).json({ error: "User account not found" });

    const tweets = await getTimeline(accountDoc, { max_results: 20 });
    res.json({ tweets });
  } catch (err) {
    console.error("Timeline route error:", err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * POST /api/tweet
 * Body: { userId, text }
 */
router.post("/tweet", async (req, res) => {
  const { userId, text } = req.body;
  if (!userId || !text) return res.status(400).json({ error: "Missing userId or text" });

  try {
    const accountDoc = await getUserAccountFromDb(userId);
    if (!accountDoc) return res.status(404).json({ error: "User account not found" });

    const response = await postTweet(accountDoc, text);
    res.json(response);
  } catch (err) {
    console.error("Post tweet error:", err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
