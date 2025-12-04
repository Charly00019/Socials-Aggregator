import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyDcWYwcS_TOHIqn3PZVJrAJdElX_Y-Vy1g",
  authDomain: "social-aggregator-114cb.firebaseapp.com",
  databaseURL: "https://social-aggregator-114cb-default-rtdb.firebaseio.com",
  projectId: "social-aggregator-114cb",
  storageBucket: "social-aggregator-114cb.firebasestorage.app",
  messagingSenderId: "626259715818",
  appId: "1:626259715818:web:7680450f2cf8aa5e8a5993",
  measurementId: "G-F45QE2KNW8"
  
  // Paste your config here

};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);