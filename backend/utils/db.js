import mongoose from "mongoose";
import User from "../models/User.js"; // your Mongoose user model
import dotenv from "dotenv";
dotenv.config();

const MONGO_URI = process.env.MONGO_URI || "mongodb://127.0.0.1:27017/socials";

export async function connectDB() {
  try {
    await mongoose.connect(MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log("✅ MongoDB connected");
  } catch (err) {
    console.error("❌ MongoDB connection error:", err);
    process.exit(1);
  }
}

/**
 * Fetch a user from MongoDB and return Twitter account info
 * Returns object suitable for service/twitter.js
 */
export async function getUserAccountFromDb(userId) {
  const user = await User.findById(userId).lean();
  if (!user || !user.twitter) return null;

  return {
    tokenType: user.twitter.tokenType,
    accessToken: user.twitter.accessToken,
    accessSecret: user.twitter.accessSecret,
    providerUserId: user.twitter.providerUserId,
    handle: user.twitter.handle,
    profileImage: user.twitter.profileImage,
    displayName: user.displayName || user.twitter.displayName,
  };
}

export default mongoose;
