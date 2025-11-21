import React from "react";
import { View, Text, Button } from "react-native";
import { signOut } from "firebase/auth";
import { auth } from "../firebase";

export default function HomeScreen({ navigation }) {
  const logout = async () => {
    try {
      await signOut(auth);
      navigation.navigate("Login");
    } catch (err) {
      alert("Error signing out: " + err.message);
    }
  };

  return (
    <View style={{ padding: 20 }}>
      <Text style={{ fontSize: 24, marginBottom: 20 }}>Welcome</Text>
      <Text style={{ marginBottom: 20 }}>You are logged in.</Text>
      <Button title="Sign out" onPress={logout} />
    </View>
  );
}
