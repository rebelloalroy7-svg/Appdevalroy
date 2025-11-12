// Home.tsx - Firebase Auth Screen
import React, { useState } from "react";
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert, ScrollView } from "react-native";
import { createUserWithEmailAndPassword, signInWithEmailAndPassword, signOut } from "firebase/auth";
import { auth } from "@/firebaseConfig";

export default function HomeScreen() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [user, setUser] = useState<any>(null);

  // 🔹 Create New User (Sign Up)
  const handleSignUp = () => {
    if (!email || !password) {
      Alert.alert("Error", "Please enter email and password");
      return;
    }
    createUserWithEmailAndPassword(auth, email, password)
      .then(userCredential => {
        setUser(userCredential.user);
        setEmail("");
        setPassword("");
        Alert.alert("Success", "Account created successfully!");
      })
      .catch(error => {
        Alert.alert("Error", error.message);
      });
  };

  // 🔹 Login Existing User
  const handleLogin = () => {
    if (!email || !password) {
      Alert.alert("Error", "Please enter email and password");
      return;
    }
    signInWithEmailAndPassword(auth, email, password)
      .then(userCredential => {
        setUser(userCredential.user);
        setEmail("");
        setPassword("");
        Alert.alert("Success", "Logged in successfully!");
      })
      .catch(error => {
        Alert.alert("Error", error.message);
      });
  };

  // 🔹 Logout
  const handleLogout = () => {
    signOut(auth)
      .then(() => {
        setUser(null);
        setEmail("");
        setPassword("");
        Alert.alert("Success", "Logged out successfully!");
      })
      .catch(error => {
        Alert.alert("Error", error.message);
      });
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.title}>🔥 Firebase Auth 🔥</Text>

      {user ? (
        <View style={styles.userSection}>
          <Text style={styles.userText}>Welcome!</Text>
          <Text style={styles.userEmail}>{user.email}</Text>
          <TouchableOpacity style={styles.button} onPress={handleLogout}>
            <Text style={styles.buttonText}>Logout</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <View style={styles.authSection}>
          <TextInput
            style={styles.input}
            placeholder="Enter Email"
            value={email}
            onChangeText={setEmail}
            autoCapitalize="none"
            keyboardType="email-address"
            placeholderTextColor="#999"
          />

          <TextInput
            style={styles.input}
            placeholder="Enter Password"
            secureTextEntry
            value={password}
            onChangeText={setPassword}
            placeholderTextColor="#999"
          />

          <TouchableOpacity style={styles.button} onPress={handleLogin}>
            <Text style={styles.buttonText}>Login</Text>
          </TouchableOpacity>

          <TouchableOpacity style={[styles.button, styles.signupButton]} onPress={handleSignUp}>
            <Text style={styles.buttonText}>Sign Up</Text>
          </TouchableOpacity>
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#f9f9f9",
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: "bold",
    marginBottom: 30,
    color: "#333",
  },
  userSection: {
    width: "100%",
    alignItems: "center",
    backgroundColor: "#fff",
    padding: 20,
    borderRadius: 10,
    elevation: 3,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
  },
  userText: {
    fontSize: 20,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 10,
  },
  userEmail: {
    fontSize: 16,
    color: "#666",
    marginBottom: 20,
  },
  authSection: {
    width: "100%",
    maxWidth: 300,
    backgroundColor: "#fff",
    padding: 20,
    borderRadius: 10,
    elevation: 3,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
  },
  input: {
    borderWidth: 1,
    borderColor: "#ddd",
    padding: 12,
    width: "100%",
    marginVertical: 10,
    borderRadius: 8,
    backgroundColor: "#fff",
    color: "#333",
    fontSize: 16,
  },
  button: {
    backgroundColor: "#007BFF",
    padding: 14,
    width: "100%",
    borderRadius: 8,
    alignItems: "center",
    marginVertical: 10,
  },
  signupButton: {
    backgroundColor: "#28a745",
  },
  buttonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "bold",
  },
});
