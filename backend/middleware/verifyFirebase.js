import admin from 'firebase-admin';

// Make sure firebase-admin is initialized in your app.js using service account
export default function verifyFirebase(req, res, next) {
  const authHeader = req.header('Authorization') || '';
  const token = authHeader.replace(/^Bearer\s+/i, '');
  if (!token) return res.status(401).json({ error: 'Missing Firebase ID token' });

  admin.auth().verifyIdToken(token)
    .then((decoded) => {
      req.firebaseUid = decoded.uid;
      next();
    })
    .catch((err) => {
      console.error('Firebase token verify failed', err);
      res.status(401).json({ error: 'Invalid or expired token' });
    });
}
