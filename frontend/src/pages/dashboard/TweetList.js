// TweetList.js
export default function TweetList({ tweets }) {
    return (
      <div className="tweet-list">
        {tweets.map(tweet => (
          <div key={tweet.id} className="tweet-card">
            <p className="tweet-content">{tweet.text}</p>
            <div className="tweet-meta">
              <span>❤️ {tweet.likes}</span>
              <span>🔁 {tweet.retweets}</span>
              <span>⏱️ {new Date(tweet.created_at).toLocaleDateString()}</span>
            </div>
          </div>
        ))}
      </div>
    );
  }