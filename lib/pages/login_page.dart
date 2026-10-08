import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:sahaaya/services/auth_service.dart';
import 'package:sahaaya/l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _errorMessage;

  static const _primaryColor = Color(0xFF4F46E5); // Vibrant Royal Indigo
  static const _secondaryColor = Color(0xFF7C3AED); // Radiant Violet
  static const _darkTextColor = Color(0xFF0F172A); // Slate 900
  static const _labelColor = Color(0xFF334155); // Slate 700
  static const _mutedColor = Color(0xFF64748B); // Slate 500
  static const _borderColor = Color(0xFFE2E8F0); // Slate 200

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        await AuthService.instance.saveUserToFirestore(userCredential.user);
        if (mounted) {
          context.go('/dashboard');
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException on Login: ${e.code} - ${e.message}');
      if (mounted) {
        setState(() => _errorMessage = _getFirebaseError(e));
      }
    } catch (e) {
      debugPrint('General Login Error: $e');
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        setState(() => _errorMessage = t.loginFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _getFirebaseError(FirebaseAuthException e) {
    final t = AppLocalizations.of(context)!;
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-credential':
        return t.userNotFound;
      case 'wrong-password':
        return t.wrongPassword;
      case 'invalid-email':
        return t.invalidEmail;
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return e.message ?? t.loginFailed;
    }
  }

  Future<void> _signInWithGoogle() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }
    try {
      final credential = await AuthService.instance.signInWithGoogle();
      if (credential != null && mounted) {
        context.go('/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Google Sign-In Auth Error: ${e.code} - ${e.message}');
      if (mounted) {
        setState(() => _errorMessage = _getFirebaseError(e));
      }
    } catch (e) {
      debugPrint('Google Sign-In General Error: $e');
      if (mounted) {
        final t = AppLocalizations.of(context)!;
        setState(() => _errorMessage = t.loginFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.pleaseEnterEmailFirst),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.resetEmailSent),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${t.resetEmailFailed}: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(prefixIcon, color: _primaryColor, size: 22),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderColor, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: _darkTextColor,
                  size: 20,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
                tooltip: 'Back',
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // 3D Logo Display
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withValues(alpha: 0.22),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/images/sahaaya_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title & Subtitle
              Text(
                t.welcomeBack,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: _darkTextColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to access emergency relief & services',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _mutedColor,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 24),

              // Error Alert Banner
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFECDD3),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFDC2626),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Form Section
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email Field
                    const Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _labelColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 15,
                        color: _darkTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _inputDecoration(
                        hint: 'name@example.com',
                        prefixIcon: Icons.email_outlined,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!v.contains('@') || !v.contains('.')) {
                          return t.enterValidEmail;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Password Field
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _labelColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      style: const TextStyle(
                        fontSize: 15,
                        color: _darkTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _inputDecoration(
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: _mutedColor,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) =>
                          v != null && v.length >= 6 ? null : t.min6Chars,
                    ),

                    const SizedBox(height: 6),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _resetPassword,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          t.forgotPassword,
                          style: const TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Primary Sign In Button
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primaryColor, _secondaryColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _loading ? null : _login,
                          child: Center(
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        t.signIn,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Divider with Text
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: _borderColor, thickness: 1.2),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: _mutedColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: _borderColor, thickness: 1.2),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Google Sign In Button
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _borderColor, width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _loading ? null : _signInWithGoogle,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://img.icons8.com/color/48/google-logo.png',
                                height: 22,
                                width: 22,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.g_mobiledata_rounded,
                                      color: Colors.red,
                                      size: 26,
                                    ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                t.signInWithGoogle,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _darkTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Register Now CTA Link
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: Text.rich(
                          TextSpan(
                            text: t.noAccount,
                            style: const TextStyle(
                              color: _mutedColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: t.registerNow,
                                style: const TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
