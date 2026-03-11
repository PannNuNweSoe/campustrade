import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/wishlist_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Stream<int> _itemsCountStream;
  late final Stream<int> _exchangesCountStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _itemsCountStream = Stream<int>.value(0);
      _exchangesCountStream = Stream<int>.value(0);
      return;
    }

    _itemsCountStream = FirebaseFirestore.instance
        .collection('items')
        .where('ownerUid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.size);

    _exchangesCountStream = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: uid)
      .where('exchangeCompleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text("Profile"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(),
              builder: (context, userSnapshot) {
                final user = userSnapshot.data ?? FirebaseAuth.instance.currentUser;
                final userEmail = user?.email ?? 'No email';
                final photoUrl = user?.photoURL;
                final userName = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
                    ? user.displayName!.trim()
                    : (userEmail.contains('@') ? userEmail.split('@').first : 'User');

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      photoUrl != null && photoUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                photoUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const CircleAvatar(
                                    radius: 40,
                                    child: Icon(Icons.person, size: 40),
                                  );
                                },
                              ),
                            )
                          : const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                      const SizedBox(height: 12),
                      Text(userName, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(
                        userEmail,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.badge_outlined,
                                      size: 20,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Account Information', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: const [
                                    Icon(Icons.school),
                                    SizedBox(width: 8),
                                    Expanded(child: Text('Mae Fah Luang University')),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: const [
                                    Icon(Icons.person),
                                    SizedBox(width: 8),
                                    Expanded(child: Text('Member since Feb 2026')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: StreamBuilder<int>(
                          stream: _itemsCountStream,
                          builder: (context, itemsSnapshot) {
                            return StreamBuilder<int>(
                              stream: _exchangesCountStream,
                              builder: (context, exchangesSnapshot) {
                                final isLoading =
                                    itemsSnapshot.connectionState == ConnectionState.waiting ||
                                    exchangesSnapshot.connectionState == ConnectionState.waiting;
                                final itemsCount = itemsSnapshot.data ?? 0;
                                final exchangesCount = exchangesSnapshot.data ?? 0;

                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.insights_outlined,
                                              size: 20,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text('Activity Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    isLoading ? '-' : '$itemsCount',
                                                    style: Theme.of(context).textTheme.titleLarge,
                                                  ),
                                                  const Text('Items'),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    isLoading ? '-' : '$exchangesCount',
                                                    style: Theme.of(context).textTheme.titleLarge,
                                                  ),
                                                  const Text('Exchanges'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.favorite_border,
                                      size: 20,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('My Wishlist', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ValueListenableBuilder<List<WishlistItem>>(
                                  valueListenable: WishlistStore.wishlistItems,
                                  builder: (context, wishlist, _) {
                                    if (wishlist.isEmpty) {
                                      return Text(
                                        'No items in wishlist yet',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      );
                                    }

                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: wishlist.length,
                                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final item = wishlist[index];
                                        return InkWell(
                                          borderRadius: BorderRadius.circular(8),
                                          onTap: () => context.go('/item/${item.id}'),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: item.imageUrl.isNotEmpty
                                                    ? ClipRRect(
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: Image.network(
                                                          item.imageUrl,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, _, _) => const Icon(Icons.image),
                                                        ),
                                                      )
                                                    : const Icon(Icons.favorite_border),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.title,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: Theme.of(context).textTheme.bodyMedium,
                                                    ),
                                                    Text(
                                                      '${item.price}  ${item.category}',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: Theme.of(context).textTheme.bodySmall,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldLogout != true) return;

                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  context.go('/');
                },
                child: const Text('Logout'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
