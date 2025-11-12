// App.tsx
import React, { useState } from "react";
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert } from "react-native";
import { createUserWithEmailAndPassword, signInWithEmailAndPassword, signOut } from "firebase/auth";
import { auth } from "./firebaseConfig";

export default function App() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [user, setUser] = useState<any>(null);

  // 🔹 Create New User (Sign Up)
  const handleSignUp = () => {
    createUserWithEmailAndPassword(auth, email, password)
      .then(userCredential => {
        setUser(userCredential.user);
        Alert.alert("Success", "Account created successfully!");
      })
      .catch(error => {
        Alert.alert("Error", error.message);
      });
  };

  // 🔹 Login Existing User
  const handleLogin = () => {
    signInWithEmailAndPassword(auth, email, password)
      .then(userCredential => {
        setUser(userCredential.user);
        Alert.alert("Success", "Logged in successfully!");
      })
      .catch(error => {
        Alert.alert("Error", error.message);
      });
  };

  // 🔹 Logout
  const handleLogout = () => {
    signOut(auth)
      .then(() => setUser(null))
      .catch(error => {
        Alert.alert("Error", error.message);
      });
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>🔥 Firebase Auth Example 🔥</Text>

      {user ? (
        <>
          <Text style={{ marginVertical: 10 }}>Welcome, {user.email}</Text>
          <TouchableOpacity style={styles.button} onPress={handleLogout}>
            <Text style={styles.buttonText}>Logout</Text>
          </TouchableOpacity>
        </>
      ) : (
        <>
          <TextInput
            style={styles.input}
            placeholder="Enter Email"
            value={email}
            onChangeText={setEmail}
            autoCapitalize="none"
          />

          <TextInput
            style={styles.input}
            placeholder="Enter Password"
            secureTextEntry
            value={password}
            onChangeText={setPassword}
          />

          <TouchableOpacity style={styles.button} onPress={handleLogin}>
            <Text style={styles.buttonText}>Login</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.button} onPress={handleSignUp}>
            <Text style={styles.buttonText}>Sign Up</Text>
          </TouchableOpacity>
        </>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: "#f9f9f9" },
  title: { fontSize: 24, fontWeight: "bold", marginBottom: 20 },
  input: {
    borderWidth: 1,
    borderColor: "#ccc",
    padding: 10,
    width: "80%",
    marginVertical: 8,
    borderRadius: 5,
    backgroundColor: "#fff",
  },
  button: {
    backgroundColor: "#007BFF",
    padding: 10,
    borderRadius: 5,
    marginVertical: 5,
    width: "80%",
    alignItems: "center",
  },
  buttonText: { color: "#fff", fontWeight: "bold" },
});
