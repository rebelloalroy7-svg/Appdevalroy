// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getAuth } from "firebase/auth";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyDhWigzX1JUDDEDpj6JPAex_-ZUBJogF70",
  authDomain: "exp10appdev.firebaseapp.com",
  projectId: "exp10appdev",
  storageBucket: "exp10appdev.firebasestorage.app",
  messagingSenderId: "862180362528",
  appId: "1:862180362528:web:20f0320536a7b6361aef45",
  measurementId: "G-GLB717TH0H"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize analytics only when running in a browser with measurementId
let analytics;
try {
  if (typeof window !== "undefined" && firebaseConfig.measurementId) {
    analytics = getAnalytics(app);
  }
} catch (e) {
  // Analytics initialization can fail in some environments; log and continue
  // eslint-disable-next-line no-console
  console.warn("Firebase analytics not initialized:", e && e.message ? e.message : e);
}

export const auth = getAuth(app);
export default app;