import React from 'react';
import { Button, View } from 'react-native';

export default function MyButton({ title, onPress }) {
  return (
    <View>
      <Button title={title} onPress={onPress} />
    </View>
  );
}
