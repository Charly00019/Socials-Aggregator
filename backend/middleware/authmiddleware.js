// backend/middleware/authMiddleware.js
import admin from "firebase-admin";
import User from "../models/user.js";

const protect = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(" ")[1];

    if (!token) {
      return res.status(401).json({ message: "No token, authorization denied" });
    }

    // Verify Firebase token
    const decodedToken = await admin.auth().verifyIdToken(token);
    const firebaseUid = decodedToken.uid;

    // Find or create user in MongoDB
    let user = await User.findOne({ firebaseUid });
    if (!user) {
      user = await User.create({
        firebaseUid,
        name: decodedToken.name || "Unnamed User",
        email: decodedToken.email,
        photoURL: decodedToken.picture || "",
      });
    }

    // Attach user data
    req.user = user;

    // ✅ Attach Twitter tokens in new v2 format
    if (user.twitterAccessToken && user.twitterAccessSecret && user.twitterId) {
      req.user.twitter = {
        oauthToken: user.twitterAccessToken,
        oauthSecret: user.twitterAccessSecret,
        twitterId: user.twitterId,
      };
    }

    next();
  } catch (err) {
    console.error("Auth error:", err.message);
    res.status(401).json({ message: "Token is not valid" });
  }
};

export default protect;
