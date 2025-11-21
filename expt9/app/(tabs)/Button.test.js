// app/(tabs)/Button.test.js
import { fireEvent, render } from '@testing-library/react-native';
import MyButton from './Button'; // Ensure the path is correct

describe('MyButton component', () => {
  it('renders correctly and handles press', () => {
    const mockPress = jest.fn();
    const { getByText } = render(<MyButton title="Press me" onPress={mockPress} />);
    
    // Check if the button text is rendered
    expect(getByText('Press me')).toBeTruthy();

    // Simulate a press
    fireEvent.press(getByText('Press me'));
    
    // Check if the mock function was called
    expect(mockPress).toHaveBeenCalled();
  });
});
