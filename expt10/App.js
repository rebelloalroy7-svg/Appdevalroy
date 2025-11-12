import React, { useState, useEffect } from "react";
import { View, Text, TextInput, Button, FlatList, StyleSheet } from "react-native";
import { db } from "./firebaseConfig";
import { collection, addDoc, getDocs, updateDoc, doc, deleteDoc } from "firebase/firestore";

export default function App() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [age, setAge] = useState("");
  const [users, setUsers] = useState([]);

  const usersCollectionRef = collection(db, "users");

  // Fetch users from Firestore
  const getUsers = async () => {
    const querySnapshot = await getDocs(usersCollectionRef);
    const userList = querySnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));
    setUsers(userList);
  };

  useEffect(() => {
    getUsers();
  }, []);

  // Add user
  const addUser = async () => {
    if (name && email && age) {
      await addDoc(usersCollectionRef, { name, email, age: Number(age) });
      setName(""); setEmail(""); setAge("");
      getUsers();
    }
  };

  // Update user age
  const updateUser = async (id, currentAge) => {
    const userDoc = doc(db, "users", id);
    await updateDoc(userDoc, { age: currentAge + 1 });
    getUsers();
  };

  // Delete user
  const deleteUser = async (id) => {
    const userDoc = doc(db, "users", id);
    await deleteDoc(userDoc);
    getUsers();
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Firestore CRUD App</Text>

      <TextInput placeholder="Name" style={styles.input} value={name} onChangeText={setName} />
      <TextInput placeholder="Email" style={styles.input} value={email} onChangeText={setEmail} />
      <TextInput placeholder="Age" style={styles.input} value={age} onChangeText={setAge} keyboardType="numeric" />

      <Button title="Add User" onPress={addUser} />

      <FlatList
        style={{ marginTop: 20 }}
        data={users}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <View style={styles.user}>
            <Text>{item.name} - {item.email} - {item.age}</Text>
            <View style={{ flexDirection: "row", marginTop: 5 }}>
              <Button title="Update Age" onPress={() => updateUser(item.id, item.age)} />
              <View style={{ width: 10 }} />
              <Button title="Delete" onPress={() => deleteUser(item.id)} color="red" />
            </View>
          </View>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, marginTop: 50 },
  title: { fontSize: 24, fontWeight: "bold", marginBottom: 20 },
  input: { borderWidth: 1, borderColor: "#ccc", padding: 10, marginBottom: 10, borderRadius: 5 },
  user: { padding: 10, borderBottomWidth: 1, borderBottomColor: "#ccc", marginBottom: 10 }
});
