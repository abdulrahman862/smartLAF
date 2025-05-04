import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'registration_success_screen.dart';

class RegisterScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const RegisterScreen({super.key, required this.themeNotifier});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _employeeIDController = TextEditingController();

  String _selectedRole = 'user';
  String? _errorMessage;
  bool _isLoading = false;

  void _register() async {
    if (_isLoading) return;

    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final employeeID = _employeeIDController.text.trim();
    final isAdmin = _selectedRole == 'admin';

    if (fullName.isEmpty || email.isEmpty || password.isEmpty || (isAdmin && employeeID.isEmpty)) {
      setState(() {
        _errorMessage = tr('register.fill_all_fields');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': fullName,
        'email': email,
        'role': _selectedRole,
        if (isAdmin) 'employeeID': employeeID,
        'registeredAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegistrationSuccessScreen(themeNotifier: widget.themeNotifier),
          ),
        );
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = tr('register.email_exists');
            break;
          case 'weak-password':
            _errorMessage = tr('register.weak_password');
            break;
          case 'invalid-email':
            _errorMessage = tr('register.invalid_email');
            break;
          default:
            _errorMessage = "${tr('register.auth_error')} ${e.message}";
        }
      } else {
        _errorMessage = tr('register.general_error');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _selectedRole == 'admin';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  tr('register.title'),
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    children: [
                      _buildRoleOption('user'),
                      const SizedBox(width: 10),
                      _buildRoleOption('admin'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration(tr('register.full_name'), Icons.person_outline),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration(tr('register.email'), Icons.email_outlined),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration(tr('register.password'), Icons.lock_outline),
                ),
                const SizedBox(height: 20),
                if (isAdmin)
                  TextField(
                    controller: _employeeIDController,
                    decoration: _inputDecoration(tr('register.employee_id'), Icons.badge_outlined),
                  ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      tr('register.button'),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey[100],
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildRoleOption(String role) {
    final isSelected = _selectedRole == role;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : theme.cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              role.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
