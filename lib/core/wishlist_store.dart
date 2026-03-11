import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistItem {
  final String id;
  final String title;
  final String price;
  final String imageUrl;
  final String category;

  const WishlistItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.category,
  });
}

class WishlistStore {
  static final ValueNotifier<List<WishlistItem>> wishlistItems =
      ValueNotifier<List<WishlistItem>>(<WishlistItem>[]);
  static final Map<String, List<WishlistItem>> _wishlistsByUser =
      <String, List<WishlistItem>>{};
  static bool _isInitialized = false;
  static String _activeUserKey = _userKey(FirebaseAuth.instance.currentUser?.uid);

  static String _userKey(String? uid) {
    if (uid == null || uid.isEmpty) return '__guest__';
    return uid;
  }

  static void _ensureInitialized() {
    if (_isInitialized) return;
    _isInitialized = true;

    FirebaseAuth.instance.authStateChanges().listen((user) {
      _activeUserKey = _userKey(user?.uid);
      final current = _wishlistsByUser[_activeUserKey] ?? <WishlistItem>[];
      wishlistItems.value = List<WishlistItem>.from(current);
    });

    final current = _wishlistsByUser[_activeUserKey] ?? <WishlistItem>[];
    wishlistItems.value = List<WishlistItem>.from(current);
  }

  static bool contains(String id) {
    _ensureInitialized();
    return wishlistItems.value.any((item) => item.id == id);
  }

  static void toggle(WishlistItem item) {
    _ensureInitialized();
    final updated = List<WishlistItem>.from(wishlistItems.value);
    final index = updated.indexWhere((saved) => saved.id == item.id);
    if (index >= 0) {
      updated.removeAt(index);
    } else {
      updated.add(item);
    }
    _wishlistsByUser[_activeUserKey] = updated;
    wishlistItems.value = List<WishlistItem>.from(updated);
  }
}
