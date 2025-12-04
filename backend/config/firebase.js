import admin from "firebase-admin";
import fs from "fs";
import path from "path";

let firebaseApp;

if (!admin.apps.length) {
  try {
    const serviceAccountPath = path.resolve("./sa.json");
    const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, "utf8"));

    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });

    console.log("✅ Firebase Admin initialized");
  } catch (err) {
    console.error("❌ Firebase Admin init error:", err);
    throw new Error("Failed to initialize Firebase Admin. Check your sa.json path and permissions.");
  }
}

export default admin;
