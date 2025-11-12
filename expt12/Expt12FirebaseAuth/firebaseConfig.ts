// firebaseConfig.ts
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyBpYsYVuvLZRhPleGjNBLYC4ixb9EsLg-g",
  authDomain: "expt12firebaseauth-94d86.firebaseapp.com",
  projectId: "expt12firebaseauth-94d86",
  storageBucket: "expt12firebaseauth-94d86.firebasestorage.app",
  messagingSenderId: "431270096705",
  appId: "1:431270096705:web:3cab1371d4a192a1ff7bc0",
  measurementId: "G-6LMKLRN5M4"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase Authentication
export const auth = getAuth(app);
