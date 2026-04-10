import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _obscurePassword = true;

  String _normalizeForValidation(String value) {
    // Strip invisible zero-width characters often used in edge/sad-path input.
    final withoutInvisible = value.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');
    return withoutInvisible.trim();
  }

  InputDecoration _fieldDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      prefixIcon: Icon(
        prefixIcon,
        color: colorScheme.primary,
      ),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.22),
          width: 1.0,
        ),
      ),
    );
  }

  void _show(String text) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)),
      );

  Future<void> _signIn() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passCtrl.text;

    setState(() => _loading = true);
    try {
      await _auth.signIn(email, password);
      _show('Logged in');
      if (!mounted) return;
      context.go('/home');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        case 'user-not-found':
          message = 'No account found for this email. Use Continue with Google.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-login-credentials':
        case 'invalid-credential':
          message = 'Email or password is incorrect. If this email was used with Google before, use Continue with Google. Otherwise use Forgot password.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password login is not enabled in Firebase Authentication.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;
        default:
          message = 'Sign in failed: ${e.message ?? e.code}';
      }
      _show(message);
    } catch (e) {
      _show('Sign in failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithGoogle();
      _show('Signed in with Google');
      if (!mounted) return;
      context.go('/home');
    } on PlatformException catch (e) {
      final details = [e.code, if (e.message != null && e.message!.isNotEmpty) e.message].join(': ');
      _show('Google sign in failed: $details');
    } on FirebaseAuthException catch (e) {
      _show('Google sign in failed: ${e.message ?? e.code}');
    } catch (e) {
      _show('Google sign in failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _show('Please enter your email first.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _show('Password reset email sent. Please check your inbox.');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        case 'user-not-found':
          message = 'No account found for this email.';
          break;
        default:
          message = 'Reset failed: ${e.message ?? e.code}';
      }
      _show(message);
    } catch (e) {
      _show('Reset failed: $e');
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CampusTrade')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.storefront,
                      size: 34,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome to CampusTrade',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Login or continue with Google'),
                  const SizedBox(height: 36),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          key: const Key('email_input'),
                          controller: _emailCtrl,
                          decoration: _fieldDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: Icons.email,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final email = _normalizeForValidation(value ?? '');
                            if (email.isEmpty) {
                              return 'Email is required';
                            }
                            if (email.length > 254) {
                              return 'Invalid email format';
                            }
                            final emailPattern = RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            );
                            if (!emailPattern.hasMatch(email)) {
                              return 'Invalid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('password_input'),
                          controller: _passCtrl,
                          decoration: _fieldDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icons.lock,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            final password = _normalizeForValidation(value ?? '');
                            if (password.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loading) const CircularProgressIndicator(),
                  if (!_loading)
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            key: const Key('login_submit_button'),
                            onPressed: _signIn,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          thickness: 1,
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                          .withValues(alpha: 0.12),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _continueWithGoogle,
                            icon: const FaIcon(FontAwesomeIcons.google, size: 18),
                            label: const Text('Continue with Google'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            TextButton(
                              onPressed: () => context.go('/signup'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Sign up now'),
                            ),
                          ],
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
