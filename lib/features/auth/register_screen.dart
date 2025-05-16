import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'registration_success_screen.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const RegisterScreen({super.key, required this.themeNotifier});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _employeeIDController = TextEditingController();

  String _selectedRole = 'user';
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _employeeIDController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isLoading) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

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
          PageRouteBuilder(
            pageBuilder: (_, animation, __) =>
                RegistrationSuccessScreen(themeNotifier: widget.themeNotifier),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
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
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = _selectedRole == 'admin';

    // Colors
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : Colors.white;
    final textColor = isDark
        ? Colors.white
        : const Color(0xFF1E1E1E);
    final accentColor = const Color(0xFF007AFF); // iOS blue
    final cardColor = isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.08);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A1A), const Color(0xFF121212)]
                : [const Color(0xFFF6F6F6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Stack(
                children: [
                  // Back button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: textColor),
                      onPressed: () => Navigator.pop(context),
                      iconSize: 20,
                    ),
                  ),

                  // Decorative elements
                  Positioned(
                    top: -size.width * 0.4,
                    right: -size.width * 0.4,
                    child: Container(
                      width: size.width * 0.8,
                      height: size.width * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withOpacity(0.03),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -size.width * 0.3,
                    left: -size.width * 0.3,
                    child: Container(
                      width: size.width * 0.6,
                      height: size.width * 0.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withOpacity(0.03),
                      ),
                    ),
                  ),

                  // Main content
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 60),

                            // App logo
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_add_outlined,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Title
                            Text(
                              tr('register.title'),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Subtitle
                            Text(
                              tr('register.subtitle') ?? "Create your account to get started",
                              style: TextStyle(
                                color: textColor.withOpacity(0.6),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Role Selector
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  _buildRoleOption('user', isDark, textColor, accentColor),
                                  const SizedBox(width: 8),
                                  _buildRoleOption('admin', isDark, textColor, accentColor),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Form Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: shadowColor,
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Full Name field
                                  _buildTextField(
                                    controller: _nameController,
                                    hintText: tr('register.full_name'),
                                    prefixIcon: Icons.person_outline,
                                    textColor: textColor,
                                    isDark: isDark,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return tr('register.name_required') ?? "Name is required";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Email field
                                  _buildTextField(
                                    controller: _emailController,
                                    hintText: tr('register.email'),
                                    prefixIcon: Icons.email_outlined,
                                    textColor: textColor,
                                    isDark: isDark,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return tr('register.email_required') ?? "Email is required";
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                        return tr('register.invalid_email') ?? "Invalid email format";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Password field
                                  _buildTextField(
                                    controller: _passwordController,
                                    hintText: tr('register.password'),
                                    prefixIcon: Icons.lock_outline,
                                    textColor: textColor,
                                    isDark: isDark,
                                    obscureText: _obscurePassword,
                                    suffix: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      child: Icon(
                                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        size: 20,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return tr('register.password_required') ?? "Password is required";
                                      }
                                      if (value.length < 6) {
                                        return tr('register.password_short') ?? "Password is too short";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Employee ID field (only for admin)
                                  if (isAdmin)
                                    Column(
                                      children: [
                                        _buildTextField(
                                          controller: _employeeIDController,
                                          hintText: tr('register.employee_id'),
                                          prefixIcon: Icons.badge_outlined,
                                          textColor: textColor,
                                          isDark: isDark,
                                          validator: isAdmin ? (value) {
                                            if (value == null || value.isEmpty) {
                                              return tr('register.employee_id_required') ?? "Employee ID is required for admin";
                                            }
                                            return null;
                                          } : null,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),

                                  // Register button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _register,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentColor,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: accentColor.withOpacity(0.5),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : Text(
                                        tr('register.button'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Error message
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 32),

                            // Already have account link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  tr('register.have_account') ?? "Already have an account?",
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.7),
                                    fontSize: 15,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    tr('register.login') ?? "Log In",
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required Color textColor,
    required bool isDark,
    bool obscureText = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: textColor.withOpacity(0.5),
          fontSize: 16,
        ),
        filled: true,
        fillColor: isDark
            ? const Color(0xFF2C2C2E).withOpacity(0.5)
            : const Color(0xFFF2F2F7),
        prefixIcon: Icon(
          prefixIcon,
          color: textColor.withOpacity(0.6),
          size: 20,
        ),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF007AFF),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.red.shade400,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String role, bool isDark, Color textColor, Color accentColor) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : (isDark ? Colors.transparent : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              role.toUpperCase(),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? textColor.withOpacity(0.7) : textColor.withOpacity(0.7)),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}