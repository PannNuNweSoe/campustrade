import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/web_email_launcher.dart';
import '../../core/wishlist_store.dart';

class ItemDetailScreen extends StatelessWidget {
  static const List<String> _categories = [
    'Food',
    'Electronics',
    'Clothes',
    'Shoes',
    'Books',
    'Beauty',
    'Other',
  ];
  final String? itemId;
  const ItemDetailScreen({super.key, this.itemId});

  String? _normalizePriceInput(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return null;

    var normalized = clean.replaceAll(',', '').trim();
    normalized = normalized
        .replaceAll('฿', '')
        .replaceAll('บาท', '')
      .replaceAll(RegExp(r'\bthb\b', caseSensitive: false), '')
        .trim();

    if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(normalized)) {
      return null;
    }

    final parsed = num.tryParse(normalized);
    if (parsed == null) return null;
    final amount = parsed % 1 == 0 ? parsed.toInt().toString() : parsed.toString();
    return '$amount THB';
  }

  Future<void> _showEditDialog({
    required BuildContext context,
    required DocumentReference<Map<String, dynamic>> docRef,
    required String initialTitle,
    required String initialDescription,
    required String initialPrice,
    required String initialCategory,
    required String initialCondition,
  }) async {
    final titleCtrl = TextEditingController(text: initialTitle);
    final descCtrl = TextEditingController(text: initialDescription);
    final priceCtrl = TextEditingController(text: initialPrice);
    var selectedCategory = initialCategory.isNotEmpty ? initialCategory : 'Other';
    var selectedCondition = initialCondition.isNotEmpty ? initialCondition : 'New';
    var isSaving = false;

    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Item name'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories
                          .map((category) => DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceCtrl,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCondition,
                      decoration: const InputDecoration(labelText: 'Condition'),
                      items: const [
                        DropdownMenuItem(value: 'New', child: Text('New')),
                        DropdownMenuItem(value: 'Used', child: Text('Used')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedCondition = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                    final title = titleCtrl.text.trim();
                    final description = descCtrl.text.trim();
                    final normalizedPrice = _normalizePriceInput(
                      priceCtrl.text,
                    );

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Please enter item name')),
                      );
                      return;
                    }

                    if (normalizedPrice == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid price (e.g. 300 THB)')),
                      );
                      return;
                    }

                    setDialogState(() => isSaving = true);

                    try {
                      await docRef
                          .update({
                            'title': title,
                            'description': description,
                            'price': normalizedPrice,
                            'category': selectedCategory,
                            'condition': selectedCondition,
                          })
                          .timeout(const Duration(seconds: 12));
                    } on TimeoutException {
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Network unstable. Changes may sync shortly.'),
                          ),
                        );
                      }
                      return;
                    } catch (e) {
                      if (dialogContext.mounted) {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text('Update failed: $e')),
                        );
                      }
                      return;
                    }

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop(true);
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (context.mounted && updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated')),
      );
    }
  }

  Future<void> _deleteItem({
    required BuildContext context,
    required DocumentReference<Map<String, dynamic>> docRef,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final firestore = FirebaseFirestore.instance;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    QuerySnapshot<Map<String, dynamic>>? relatedChats;
    try {
      relatedChats = await firestore
          .collection('chats')
          .where('itemId', isEqualTo: docRef.id)
          .get();
    } catch (_) {
      relatedChats = null;
    }

    if (relatedChats != null) {
      for (final chatDoc in relatedChats.docs) {
        final participants =
            (chatDoc.data()['participants'] as List?)?.whereType<String>().toList() ??
            const <String>[];

        if (currentUid == null || participants.contains(currentUid)) {
          try {
            await chatDoc.reference.set({
              'exchangeCompleted': true,
              'exchangeCompletedAt': FieldValue.serverTimestamp(),
              'exchangeCompletedBy': currentUid,
            }, SetOptions(merge: true));
          } catch (_) {
          }
        }
      }
    }

    await docRef.delete();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item deleted')),
    );
    context.go('/home');
  }

  String _formatPostedDate(dynamic createdAt) {
    if (createdAt is! Timestamp) {
      return 'Recently';
    }

    final date = createdAt.toDate();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour12 = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour12:$minute $ampm';
  }

  String _deriveNameFromEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Campus Seller';
    }
    if (!email.contains('@')) {
      return email;
    }
    return email.split('@').first;
  }

  Future<void> _openEmailApp(BuildContext context, String ownerEmail) async {
    final email = ownerEmail.trim();
    if (email.isEmpty) return;

    try {
      if (kIsWeb) {
        final opened = openGmailComposeOnWeb(
          email: email,
          subject: 'CampusTrade Item Inquiry',
        );

        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to open email on this browser')),
          );
        }
        return;
      }

      final emailUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': 'CampusTrade Item Inquiry'},
      );

      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No email app available on this device')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open email right now')),
        );
      }
    }
  }

  Widget _buildEmailLinkText(BuildContext context, String email) {
    final linkStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );

    return InkWell(
      onTap: () => _openEmailApp(context, email),
      child: Text(email, style: linkStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (itemId == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          title: const Text('Item Detail'),
        ),
        body: const Center(child: Text('No item selected')),
      );
    }

    final docRef = FirebaseFirestore.instance.collection('items').doc(itemId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Item Detail'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snap.hasData || !snap.data!.exists) return const Center(child: Text('Item not found'));
          final data = snap.data!.data()!;
          final title = (data['title'] as String?) ?? '';
          final description = (data['description'] as String?) ?? '';
          final price = (data['price'] as String?) ?? '';
          final category = (data['category'] as String?) ?? 'Other';
          final condition = (data['condition'] as String?) ?? '';
          final imageUrl = (data['imageUrl'] as String?)?.trim();
          final ownerUid = data['ownerUid'] as String?;
          final currentUid = FirebaseAuth.instance.currentUser?.uid;
          final isOwner = ownerUid != null && ownerUid == currentUid;
          final ownerNameFromItem = (data['ownerName'] as String?)?.trim();
          final ownerEmailFromItem = (data['ownerEmail'] as String?)?.trim();
          final postedText = _formatPostedDate(data['createdAt']);

          final sellerInfoWidget =
              (ownerNameFromItem != null && ownerNameFromItem.isNotEmpty) ||
                  (ownerEmailFromItem != null && ownerEmailFromItem.isNotEmpty)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ownerNameFromItem != null && ownerNameFromItem.isNotEmpty
                          ? ownerNameFromItem
                          : _deriveNameFromEmail(ownerEmailFromItem),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (ownerEmailFromItem != null && ownerEmailFromItem.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildEmailLinkText(context, ownerEmailFromItem),
                    ],
                  ],
                )
              : FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: ownerUid == null
                      ? null
                      : FirebaseFirestore.instance
                            .collection('users')
                            .doc(ownerUid)
                            .get(),
                  builder: (context, userSnap) {
                    final userData = userSnap.data?.data();
                    final ownerEmail =
                        (userData?['email'] as String?)?.trim() ?? '';
                    final ownerName =
                        (userData?['name'] as String?)?.trim() ??
                        _deriveNameFromEmail(ownerEmail);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ownerName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        if (ownerEmail.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _buildEmailLinkText(context, ownerEmail),
                        ],
                      ],
                    );
                  },
                );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 250,
                      constraints: const BoxConstraints(maxWidth: 700),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: (imageUrl != null && imageUrl.isNotEmpty)
                            ? Container(
                                color: Colors.white,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: 250,
                                ),
                              )
                            : Container(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.20),
                                alignment: Alignment.center,
                                child: const Icon(Icons.image, size: 64, color: Colors.white70),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: ValueListenableBuilder<List<WishlistItem>>(
                        valueListenable: WishlistStore.wishlistItems,
                        builder: (context, wishlist, _) {
                          final isWishlisted = wishlist.any((item) => item.id == docRef.id);
                          return Material(
                            color: Colors.white.withValues(alpha: 0.90),
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: isWishlisted ? 'Remove from wishlist' : 'Add to wishlist',
                              onPressed: () {
                                WishlistStore.toggle(
                                  WishlistItem(
                                    id: docRef.id,
                                    title: title,
                                    price: price,
                                    imageUrl: imageUrl ?? '',
                                    category: category,
                                  ),
                                );
                              },
                              icon: Icon(
                                isWishlisted ? Icons.favorite : Icons.favorite_border,
                                color: isWishlisted ? Colors.red : Colors.black87,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Posted by',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      sellerInfoWidget,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(description),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'Item Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Category', style: Theme.of(context).textTheme.bodySmall),
                        const Spacer(),
                        Text(
                          category.isNotEmpty ? category : 'Other',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Condition', style: Theme.of(context).textTheme.bodySmall),
                        const Spacer(),
                        Text(
                          condition.isNotEmpty ? condition : '-',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Posted', style: Theme.of(context).textTheme.bodySmall),
                        const Spacer(),
                        Text(
                          postedText,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 18),
              if (isOwner) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            await _showEditDialog(
                              context: context,
                              docRef: docRef,
                              initialTitle: title,
                              initialDescription: description,
                              initialPrice: price,
                              initialCategory: category,
                              initialCondition: condition,
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Update failed: $e')),
                            );
                          }
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          try {
                            await _deleteItem(context: context, docRef: docRef);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Delete failed: $e')),
                            );
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (!isOwner)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final currentUid = FirebaseAuth.instance.currentUser?.uid;
                      final chatRef = await FirebaseFirestore.instance.collection('chats').add({
                        'itemId': itemId,
                        'itemImage': imageUrl,
                        'participants': [ownerUid, currentUid],
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      if (!context.mounted) return;
                      GoRouter.of(context).go('/chat', extra: {
                        'chatId': chatRef.id,
                        'itemId': itemId,
                        'title': title,
                        'description': description,
                        'price': price,
                        'condition': condition,
                        'itemImage': imageUrl,
                        'ownerUid': ownerUid,
                      });
                    },
                    child: const Text('Contact Owner'),
                  ),
                ),
            ]),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) { if (i==0) context.go('/home'); if (i==1) context.go('/profile'); },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
