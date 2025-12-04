import mongoose from 'mongoose';

const SocialAccountSchema = new mongoose.Schema({
  firebaseUid: { type: String, required: true, index: true },
  provider: { type: String, required: true }, // 'twitter', 'tiktok', ...
  providerUserId: { type: String, required: true },
  displayName: String,
  handle: String,
  profileImage: String,
  // store tokens securely (encrypted at rest in production)
  tokenType: String,      // 'oauth1'|'oauth2'|'bearer'
  accessToken: String,
  refreshToken: String,
  accessSecret: String,   // twitter oauth1 secret
  scopes: [String],
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

export default mongoose.model('SocialAccount', SocialAccountSchema);
