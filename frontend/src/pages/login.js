import { useState } from "react";
import { signInWithPopup, TwitterAuthProvider } from "firebase/auth";
import { auth } from "../firebase";
import Button from "@mui/material/Button";
import "../styles/login.css"; // Import the CSS file

export default function Login({ onLoginSuccess }) {
  const [user, setUser] = useState(null);
  const [error, setError] = useState(null);

  const signInWithTwitter = async () => {
    try {
      const provider = new TwitterAuthProvider();
      const result = await signInWithPopup(auth, provider);
      
      setUser(result.user);
      
      const credential = TwitterAuthProvider.credentialFromResult(result);
      const token = credential.accessToken;
      localStorage.setItem("twitterToken", token);
      
      console.log("Logged in as:", result.user);
      
      if (onLoginSuccess) {
        onLoginSuccess(result.user);
      }
      
    } catch (error) {
      console.error("Login failed:", error);
      setError(error.message);
      
      if (error.code === 'auth/popup-closed-by-user') {
        setError("You closed the login popup too soon");
      } else if (error.code === 'auth/cancelled-popup-request') {
        setError("Login request was cancelled");
      }
    }
  };

  return (
    <div className="login-container">
      {error && <div className="login-error">{error}</div>}
      
      {user ? (
        <div>
          <h2 className="welcome-message">Welcome, {user.displayName || 'User'}!</h2>
          <p className="user-email">Email: {user.email || 'Not provided'}</p>
        </div>
      ) : (
        <Button 
          className="twitter-login-btn"
          variant="contained" 
          onClick={signInWithTwitter}
          fullWidth
          size="large"
        >
          Sign in with Twitter
        </Button>
      )}
    </div>
  );
}