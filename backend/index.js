import express from 'express';
import tweetsRoute from './routes/tweets.js';
import cors from 'cors';
import dotenv from 'dotenv';
import { connectDB } from './utils/db.js'; // import DB connector

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Connect to MongoDB
connectDB();

// Routes
app.use('/api/tweets', tweetsRoute);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
