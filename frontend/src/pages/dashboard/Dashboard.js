import { useState, useEffect } from 'react';
import UserProfile from './UserProfile';
import TweetList from './TweetList';
import '../../styles/dashboard.css';

export default function Dashboard({ user }) {
  const [tweets, setTweets] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Mock data - replace with real API call later
    const mockTweets = [
      {
        id: '1',
        text: 'Just signed up for this awesome social aggregator! #excited',
        created_at: new Date().toISOString(),
        likes: 42,
        retweets: 5
      },
      {
        id: '2',
        text: 'Check out what I built with Twitter API! 🚀 #coding #webdev',
        created_at: new Date().toISOString(),
        likes: 87,
        retweets: 12
      }
    ];

    // Simulate API loading delay
    const timer = setTimeout(() => {
      setTweets(mockTweets);
      setLoading(false);
    }, 1500);

    return () => clearTimeout(timer);
  }, []);

  return (
    <div className="dashboard">
      <div className="profile-header">
        <img src={user.photoURL} alt="Profile" className="profile-img" />
        <UserProfile user={user} />
      </div>
      
      <div className="tweets-section">
        <h2>Your Recent Posts</h2>
        {loading ? (
          <div className="loading-state">
            <p>Loading your tweets...</p>
          </div>
        ) : (
          <TweetList tweets={tweets} />
        )}
      </div>
    </div>
  );
}