import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  void _show(String text) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)),
      );

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
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
        case 'invalid-credential':
          message = 'Invalid email/password credentials.';
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
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text('Login or continue with Google'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(
                        Icons.email,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passCtrl,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  if (_loading) const CircularProgressIndicator(),
                  if (!_loading)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _signIn,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Login'),
                          ),
                        ),
                        TextButton(
                          onPressed: _forgotPassword,
                          child: const Text('Forgot password?'),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _continueWithGoogle,
                            icon: Icon(
                              Icons.account_circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            label: const Text('Continue with Google'),
                          ),
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
