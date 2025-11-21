# Firebase Auth Demo — Run Instructions

This repo contains a small React Native app that uses Firebase Authentication.

Prerequisites
- Node.js (14+)
- npm (comes with Node)
- Git (optional)

Recommended: run with Expo (no native toolchain required).

Local setup (PowerShell on Windows):

```powershell
cd c:\Users\harsh\Documents\EXXPERRIMENT12\firebase-auth-demo
npm install
# start Metro / Expo dev tools
npx expo start
```

Then press `a` to open on an Android emulator or `w` for web, or scan the QR code with the Expo Go app.

Notes
- The project expects `firebase` v9-style imports (already used in `firebase.js`).
- Phone auth using `RecaptchaVerifier` may require web support; on device you may need to follow Expo/React Native Firebase phone auth setup or use a backend.
- If you prefer the bare React Native CLI instead of Expo, install required native dependencies and configure Android/iOS projects.
