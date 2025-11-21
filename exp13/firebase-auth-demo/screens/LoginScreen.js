import React, { useState } from "react";
import { View, TextInput, Button, Text } from "react-native";
import { signInWithEmailAndPassword, sendPasswordResetEmail } from "firebase/auth";
import { auth } from "../firebase";

export default function LoginScreen({ navigation }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const login = () => {
    setError("");
    if (!email || !password) {
      setError("Please enter email and password.");
      return;
    }

    signInWithEmailAndPassword(auth, email, password)
      .then(() => {
        // Navigate to Home on success
        setError("");
        navigation.navigate("Home");
      })
      .catch(err => {
        // Log the full error object for debugging
        // eslint-disable-next-line no-console
        console.error("signInWithEmailAndPassword error:", err);

        // Build a friendly message but include the error code to help diagnose
        let msg = err && err.message ? err.message : "Authentication failed.";
        const code = err && err.code ? err.code : null;

        if (code === "auth/user-not-found") msg = "No user found with this email.";
        else if (code === "auth/wrong-password") msg = "Incorrect password.";
        else if (code === "auth/invalid-email") msg = "Invalid email address.";
        else if (code === "auth/too-many-requests") msg = "Too many failed attempts. Try again later.";
        else if (code) msg = `${code}: ${msg}`;

        setError(msg);
      });
  };

  const forgotPassword = () => {
    if (!email) {
      setError("Please enter your email to reset password.");
      return;
    }

    sendPasswordResetEmail(auth, email)
      .then(() => {
        alert("Password reset email sent. Check your inbox.");
      })
      .catch(err => {
        let msg = err.message;
        if (err.code === "auth/user-not-found") msg = "No account found for that email.";
        else if (err.code === "auth/invalid-email") msg = "Invalid email address.";
        setError(msg);
      });
  };

  return (
    <View style={{ padding: 20 }}>
      <Text style={{ fontSize: 24 }}>Login</Text>

      <TextInput
        placeholder="Email"
        keyboardType="email-address"
        autoCapitalize="none"
        value={email}
        style={{ borderWidth: 1, padding: 10, marginVertical: 10 }}
        onChangeText={setEmail}
      />

      <TextInput
        placeholder="Password"
        secureTextEntry
        value={password}
        style={{ borderWidth: 1, padding: 10, marginVertical: 10 }}
        onChangeText={setPassword}
      />

      {error ? (
        <Text style={{ color: "red", marginBottom: 10 }}>{error}</Text>
      ) : null}

      <Button title="Login" onPress={login} />

      <View style={{ height: 10 }} />
      <Button title="Register" onPress={() => navigation.navigate("Register")} />
      <View style={{ height: 10 }} />
      <Button title="Phone Auth" onPress={() => navigation.navigate("PhoneAuth")} />
    </View>
  );
}
