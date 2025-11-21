import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import MyButton from './Button';

test('renders button and handles press', () => {
  const mockPress = jest.fn();

  const { getByText } = render(
    <MyButton title="Click me" onPress={mockPress} />
  );

  fireEvent.press(getByText('Click me'));

  expect(mockPress).toHaveBeenCalled();
});
