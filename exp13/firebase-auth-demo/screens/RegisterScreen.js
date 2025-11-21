import React, { useState } from "react";
import { View, TextInput, Button, Text } from "react-native";
import { createUserWithEmailAndPassword } from "firebase/auth";
import { auth } from "../firebase";

export default function RegisterScreen({ navigation }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const register = () => {
    setError("");
    if (!email || !password) {
      setError("Please enter email and password.");
      return;
    }
    // Defensive check: ensure auth is initialized
    if (!auth) {
      setError("Authentication is not configured. Check firebase.js exports.");
      // eslint-disable-next-line no-console
      console.error("firebase auth is undefined in RegisterScreen");
      return;
    }

    // Attempt registration and provide clearer error logging
    createUserWithEmailAndPassword(auth, email, password)
      .then(() => {
        alert("User registered! You can now log in.");
        navigation.navigate("Login");
      })
      .catch(err => {
        // Log full error for debugging
        // eslint-disable-next-line no-console
        console.error("createUserWithEmailAndPassword error:", err);

        let msg = "Registration failed. Check console for details.";
        if (err && err.code) {
          if (err.code === "auth/email-already-in-use") msg = "This email is already registered.";
          else if (err.code === "auth/weak-password") msg = "Password is too weak (min 6 characters).";
          else if (err.code === "auth/invalid-email") msg = "Invalid email address.";
        } else if (err && err.message) {
          // Some runtime errors (like undefined auth) show up here
          msg = err.message;
        }

        setError(msg);
      });
  };

  return (
    <View style={{ padding: 20 }}>
      <Text style={{ fontSize: 24 }}>Register</Text>

      <TextInput
        placeholder="Email"
        style={{ borderWidth: 1, padding: 10, marginVertical: 10 }}
        onChangeText={setEmail}
      />

      <TextInput
        placeholder="Password"
        secureTextEntry
        style={{ borderWidth: 1, padding: 10, marginVertical: 10 }}
        onChangeText={setPassword}
      />

      {error ? (
        <Text style={{ color: "red", marginBottom: 10 }}>{error}</Text>
      ) : null}

      <Button title="Register" onPress={register} />
      <View style={{ height: 10 }} />
      <Button title="Back to Login" onPress={() => navigation.navigate("Login")} />
    </View>
  );
}
