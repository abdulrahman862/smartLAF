import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prototype1/features/auth/change_password_success_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  final _auth = FirebaseAuth.instance;

  Future<void> _changePassword() async {
    final currentUser = _auth.currentUser;
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = tr('change_password.mismatch');
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _errorMessage = tr('change_password.too_short');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cred = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );

      await currentUser.reauthenticateWithCredential(cred);
      await currentUser.updatePassword(newPassword);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChangePasswordSuccessScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.code == 'wrong-password'
            ? tr('change_password.incorrect_current')
            : tr('change_password.generic_error');
      });
    } catch (_) {
      setState(() {
        _errorMessage = tr('change_password.general_error');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('change_password.title'), style: theme.textTheme.titleLarge),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: theme.iconTheme,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPasswordField(context, _currentPasswordController, tr('change_password.current')),
            const SizedBox(height: 16),
            _buildPasswordField(context, _newPasswordController, tr('change_password.new')),
            const SizedBox(height: 16),
            _buildPasswordField(context, _confirmPasswordController, tr('change_password.confirm')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(tr('change_password.button'), style: const TextStyle(color: Colors.white)),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context, TextEditingController controller, String label) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      obscureText: true,
      obscuringCharacter: '•',
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: theme.textTheme.bodySmall,
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
