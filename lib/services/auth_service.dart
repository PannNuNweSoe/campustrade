import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _normalizePassword(String password) => password;

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: _normalizeEmail(email),
      password: _normalizePassword(password),
    );
  }

  Future<UserCredential> signUp(
    String email,
    String password, {
    String? username,
  }) async {
    final cleanUsername = username?.trim();
    final normalizedEmail = _normalizeEmail(email);
    final normalizedPassword = _normalizePassword(password);
    final cred = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: normalizedPassword,
    );
    if (cleanUsername != null && cleanUsername.isNotEmpty) {
      await cred.user?.updateDisplayName(cleanUsername);
    }
    // create basic user doc
    final uid = cred.user?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).set({
        'email': normalizedEmail,
        if (cleanUsername != null && cleanUsername.isNotEmpty)
          'username': cleanUsername,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return cred;
  }

  Future<UserCredential> signInWithGoogle() async {
    late UserCredential cred;

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      cred = await _auth.signInWithPopup(provider);
    } else {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      cred = await _auth.signInWithCredential(authCredential);
    }

    final user = cred.user;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return cred;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
