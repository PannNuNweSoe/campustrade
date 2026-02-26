import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemDetailScreen extends StatelessWidget {
  final String? itemId;
  const ItemDetailScreen({super.key, this.itemId});

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
          final condition = (data['condition'] as String?) ?? '';
          final imageUrl = (data['imageUrl'] as String?)?.trim();
          final ownerUid = data['ownerUid'] as String?;
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
                      'Seller: ${ownerNameFromItem != null && ownerNameFromItem.isNotEmpty ? ownerNameFromItem : _deriveNameFromEmail(ownerEmailFromItem)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (ownerEmailFromItem != null && ownerEmailFromItem.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Email: $ownerEmailFromItem',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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
                          'Seller: $ownerName',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (ownerEmail.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Email: $ownerEmail',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    );
                  },
                );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Container(
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
              ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(price, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(description),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Item Details', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    sellerInfoWidget,
                    const SizedBox(height: 4),
                    Text('Posted: $postedText', style: Theme.of(context).textTheme.bodySmall),
                  ]),
                ),
              ),
              const SizedBox(height: 18),
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
