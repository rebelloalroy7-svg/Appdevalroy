import React, { useState } from 'react';
import { StyleSheet, Text, View, TextInput, Button, FlatList, TouchableOpacity } from 'react-native';

export default function App() {
  const [task, setTask] = useState('');
  const [tasks, setTasks] = useState([]);

  const addTask = () => {
    if (task.trim().length > 0) {
      setTasks([...tasks, { id: Date.now().toString(), value: task }]);
      setTask('');
    }
  };

  const deleteTask = (taskId) => {
    setTasks(tasks.filter((item) => item.id !== taskId));
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>To-Do List</Text>
      
      <View style={styles.inputContainer}>
        <TextInput
          placeholder="Enter task"
          value={task}
          onChangeText={(text) => setTask(text)}
          style={styles.input}
        />
        <Button title="Add" onPress={addTask} />
      </View>

      <FlatList
        data={tasks}
        renderItem={(itemData) => (
          <TouchableOpacity onPress={() => deleteTask(itemData.item.id)}>
            <View style={styles.listItem}>
              <Text>{itemData.item.value}</Text>
            </View>
          </TouchableOpacity>
        )}
        keyExtractor={(item) => item.id}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 50,
    backgroundColor: '#fff',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  inputContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  input: {
    borderBottomColor: 'black',
    borderBottomWidth: 1,
    padding: 8,
    width: '70%',
    marginRight: 10,
  },
  listItem: {
    padding: 15,
    marginVertical: 8,
    backgroundColor: '#f2f2f2',
    borderRadius: 5,
  },
});
