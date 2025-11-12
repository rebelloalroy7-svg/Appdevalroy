import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registration Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const RegistrationForm(),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Dropdowns
  String? selectedCountry;
  String? selectedRole;

  // Gender
  String gender = "Male";

  // Checkbox
  bool isAgreed = false;

  // Password visibility
  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Create an Account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Please fill in your details to continue",
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Enter your name" : null,
                      ),
                      const SizedBox(height: 12),

                      // Email
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email Address",
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.contains("@") ? null : "Enter valid email",
                      ),
                      const SizedBox(height: 12),

                      // Phone
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.length == 10
                            ? null
                            : "Enter 10-digit phone number",
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: !showPassword,
                        validator: (value) => value!.length < 6
                            ? "Password must be at least 6 chars"
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Confirm Password
                      TextFormField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                showConfirmPassword = !showConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: !showConfirmPassword,
                        validator: (value) =>
                            value != passwordController.text
                                ? "Passwords do not match"
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Gender
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Gender",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile(
                              title: const Text("Male"),
                              value: "Male",
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = value.toString();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              title: const Text("Female"),
                              value: "Female",
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = value.toString();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Dropdowns
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Country",
                          prefixIcon: Icon(Icons.flag),
                        ),
                        value: selectedCountry,
                        items: ["India", "USA", "UK", "Canada"]
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCountry = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? "Select country" : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "User Role",
                          prefixIcon: Icon(Icons.work),
                        ),
                        value: selectedRole,
                        items: ["Student", "Developer", "Designer", "Other"]
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? "Select role" : null,
                      ),
                      const SizedBox(height: 12),

                      // Checkbox
                      CheckboxListTile(
                        value: isAgreed,
                        onChanged: (value) {
                          setState(() {
                            isAgreed = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text("I agree to the Terms & Conditions"),
                      ),
                      const SizedBox(height: 16),

                      // Register Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate() && isAgreed) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ Registration Successful!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "⚠️ Please complete all fields properly"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Center(
                          child: Text(
                            "Register",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () {
                          // Navigate to Login Screen
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.black54),
                            children: [
                              TextSpan(
                                text: "Log in",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
