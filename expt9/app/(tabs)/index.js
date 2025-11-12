import * as SQLite from 'expo-sqlite';
import { useEffect, useState } from 'react';
import { Alert, Button, FlatList, StyleSheet, Text, TextInput, View } from 'react-native';

const db = SQLite.openDatabaseSync('users.db');

export default function App() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [users, setUsers] = useState([]);

  useEffect(() => {
    initDb();
  }, []);

  async function initDb() {
    try {
      await db.execAsync(`
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT
        );
      `);
      fetchUsers();
    } catch (error) {
      console.error('DB init error:', error);
      Alert.alert('Database Error', error.message);
    }
  }

  async function fetchUsers() {
    try {
      const result = await db.getAllAsync('SELECT * FROM users');
      setUsers(result);
    } catch (error) {
      console.error('Fetch error:', error);
    }
  }

  async function addUser() {
    if (name.trim() === '' || email.trim() === '') {
      Alert.alert('Please enter both name and email');
      return;
    }

    try {
      await db.runAsync('INSERT INTO users (name, email) VALUES (?, ?)', [name, email]);
      setName('');
      setEmail('');
      fetchUsers();
    } catch (error) {
      console.error('Insert error:', error);
      Alert.alert('Error adding user', error.message);
    }
  }

  async function deleteUser(id) {
    try {
      await db.runAsync('DELETE FROM users WHERE id = ?', [id]);
      fetchUsers();
    } catch (error) {
      console.error('Delete error:', error);
    }
  }

  return (
    <View style={styles.container}>
      <Text style={styles.heading}>SQLite User List</Text>

      <TextInput
        style={styles.input}
        placeholder="Enter name"
        value={name}
        onChangeText={setName}
      />
      <TextInput
        style={styles.input}
        placeholder="Enter email"
        value={email}
        onChangeText={setEmail}
      />

      <Button title="Add User" onPress={addUser} />

      <FlatList
        data={users}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <View style={styles.item}>
            <View>
              <Text style={styles.text}>{item.name}</Text>
              <Text style={styles.subText}>{item.email}</Text>
            </View>
            <Button title="Delete" onPress={() => deleteUser(item.id)} />
          </View>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, backgroundColor: '#fff' },
  heading: { fontSize: 24, fontWeight: 'bold', marginBottom: 10 },
  input: { borderWidth: 1, borderColor: '#ccc', padding: 8, marginBottom: 10 },
  item: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginVertical: 5 },
  text: { fontSize: 18, fontWeight: '600' },
  subText: { fontSize: 14, color: '#666' },
});
