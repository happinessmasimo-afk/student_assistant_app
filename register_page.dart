/* Student numbers: 224091294, 222082043 ,223022927 ,223013027 ,224036718 ,224063836 ,224036084 ,224132354 */
/* Student names:   B Masimong, MW Taeli , T Mokgwati , R Mosia,S Mnyameni, BKD Mthembu, O Mangoejane, L Koloi */


import 'package:flutter/material.dart';
import 'package:supabasedb/auth/auth_service.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authService = AuthService();

  final _fullNameController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> signUp() async {
    final fullName = _fullNameController.text.trim();
    final studentNumber = _studentNumberController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty ||
        studentNumber.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords don't match")),
      );
      return;
    }

    try {
      await authService.signUpWithEmailPassword(
        email: email,
        password: password,
        fullName: fullName,
        studentNumber: studentNumber,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Please log in.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _fullNameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _studentNumberController,
            decoration: const InputDecoration(labelText: 'Student Number'),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 20),
          TextField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: signUp,
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}