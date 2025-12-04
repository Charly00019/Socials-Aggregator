import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import mongoose from "mongoose";

import twitterRoutes from "./routes/tweets.js";
import admin from "./config/firebase.js"; // <-- Use only this
dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// ------------------- MongoDB -------------------
mongoose
  .connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("✅ MongoDB Connected"))
  .catch((err) => console.error("❌ MongoDB Error:", err));

// ------------------- Firebase Admin -------------------
console.log("✅ Firebase Admin initialized");

// ------------------- Routes -------------------
app.use("/api/tweets", twitterRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
