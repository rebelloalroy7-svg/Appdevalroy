import 'dart:io';

void main() {
  // Taking name input
  stdout.write("Enter your name: ");
  String? name = stdin.readLineSync();

  // Taking number input safely
  stdout.write("Enter a number: ");
  String? input = stdin.readLineSync();

  // Check if input is valid
  int number;
  if (input != null && int.tryParse(input) != null) {
    number = int.parse(input);
  } else {
    print("❌ Invalid number entered. Defaulting to 5.");
    number = 5;
  }

  print("\nHello, $name! Let's print numbers from 1 to $number:");

  // For loop
  for (int i = 1; i <= number; i++) {
    print("Number $i");
  }

  // While loop
  print("\nPrinting even numbers up to $number using while loop:");
  int j = 2;
  while (j <= number) {
    print(j);
    j += 2;
  }

  // Do-while loop
  print("\nCountdown using do-while loop:");
  int k = number;
  do {
    print(k);
    k--;
  } while (k > 0);
}
