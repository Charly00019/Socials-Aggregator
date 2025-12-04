import { useState, useEffect } from 'react';
import { onAuthStateChanged } from 'firebase/auth';
import { auth } from './firebase';
import Login from './pages/login';
import Dashboard from './pages/dashboard/Dashboard'; // Make sure this import path is correct

function App() {
  const [user, setUser] = useState(null); // Track user authentication state

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      if (currentUser) {
        console.log("User is signed in:", currentUser);
        setUser(currentUser); // Update state when user logs in
      } else {
        console.log("User is signed out");
        setUser(null); // Clear state when user logs out
      }
    });
    return () => unsubscribe();
  }, []);

  return (
    <div className="App">
      {user ? (
        <Dashboard user={user} /> // Show dashboard when authenticated
      ) : (
        <Login onLoginSuccess={setUser} /> // Show login when not authenticated
      )}
    </div>
  );
}

export default App;