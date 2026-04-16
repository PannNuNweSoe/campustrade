import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() => {
    'title': title,
    'price': price,
    'imageUrl': imageUrl,
    'category': category,
  };

  factory WishlistItem.fromMap(String id, Map<String, dynamic> map) =>
      WishlistItem(
        id: id,
        title: (map['title'] as String?) ?? '',
        price: (map['price'] as String?) ?? '',
        imageUrl: (map['imageUrl'] as String?) ?? '',
        category: (map['category'] as String?) ?? '',
      );
}

class WishlistStore {
  static final ValueNotifier<List<WishlistItem>> wishlistItems =
      ValueNotifier<List<WishlistItem>>(<WishlistItem>[]);
  static bool _isInitialized = false;

  static void initialize() {
    _ensureInitialized();
  }

  static CollectionReference<Map<String, dynamic>>? _wishlistCol(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('wishlist');

  static void _ensureInitialized() {
    if (_isInitialized) return;
    _isInitialized = true;

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        wishlistItems.value = [];
        return;
      }
      _loadFromFirestore(user.uid);
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _loadFromFirestore(uid);
    }
  }

  static Future<void> _loadFromFirestore(String uid) async {
    try {
      final snapshot = await _wishlistCol(uid)!.get();
      wishlistItems.value = snapshot.docs
          .map((doc) => WishlistItem.fromMap(doc.id, doc.data()))
          .toList();
    } catch (_) {
      // Keep existing value if load fails
    }
  }

  static bool contains(String id) {
    _ensureInitialized();
    return wishlistItems.value.any((item) => item.id == id);
  }

  static void toggle(WishlistItem item) {
    _ensureInitialized();
    final updated = List<WishlistItem>.from(wishlistItems.value);
    final index = updated.indexWhere((saved) => saved.id == item.id);
    final isRemoving = index >= 0;

    if (isRemoving) {
      updated.removeAt(index);
    } else {
      updated.add(item);
    }
    wishlistItems.value = updated;

    // Persist to Firestore in background
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final col = _wishlistCol(uid)!;
      if (isRemoving) {
        col
            .doc(item.id)
            .delete()
            .catchError((_) {});
      } else {
        col
            .doc(item.id)
            .set(item.toMap())
            .catchError((_) {});
      }
    }
  }
}
