import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prototype1/features/auth/register_screen.dart';
import 'package:prototype1/features/User/User_home_screen.dart';
import 'package:prototype1/features/admin/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const LoginScreen({super.key, required this.themeNotifier});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "login.enter_both".tr();
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        setState(() {
          _errorMessage = "login.general_error".tr();
        });
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!doc.exists || !doc.data()!.containsKey('role')) {
        setState(() {
          _errorMessage = "login.role_missing".tr();
        });
        return;
      }

      final role = doc['role'];

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHomeScreen(themeNotifier: widget.themeNotifier),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(themeNotifier: widget.themeNotifier),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = "login.user_not_found".tr();
            break;
          case 'wrong-password':
            _errorMessage = "login.wrong_password".tr();
            break;
          case 'invalid-email':
            _errorMessage = "login.invalid_email".tr();
            break;
          case 'too-many-requests':
            _errorMessage = "login.too_many_attempts".tr();
            break;
          case 'network-request-failed':
            _errorMessage = "login.network_error".tr();
            break;
          case 'user-disabled':
            _errorMessage = "login.user_disabled".tr();
            break;
          default:
            _errorMessage = "${"login.failed".tr()} ${e.message ?? "Unknown error"}";
        }
      });
    } catch (_) {
      setState(() {
        _errorMessage = "login.general_error".tr();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "login.title".tr(),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration("login.email".tr(), Icons.email_outlined),
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration("login.password".tr(), Icons.lock_outline),
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("login.button".tr(), style: const TextStyle(color: Colors.white)),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("login.no_account".tr()),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(themeNotifier: widget.themeNotifier),
                          ),
                        );
                      },
                      child: Text(
                        "login.signup".tr(),
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
      filled: true,
      fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
      prefixIcon: Icon(icon, color: isDark ? Colors.white : Colors.black),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
