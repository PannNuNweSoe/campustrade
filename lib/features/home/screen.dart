import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  static const List<String> _categories = [
    'Food',
    'Electronics',
    'Clothes',
    'Shoes',
    'Books',
    'Beauty',
    'Other',
  ];
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.storefront_outlined),
            const SizedBox(width: 8),
            const Text('CampusTrade'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.go('/notifications'),
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            tooltip: 'Seed sample items',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final user = FirebaseAuth.instance.currentUser;
              final ownerEmail = user?.email ?? '';
              final ownerName =
                  (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
                  ? user.displayName!.trim()
                  : (ownerEmail.contains('@')
                        ? ownerEmail.split('@').first
                        : 'Campus Seller');
              final batch = FirebaseFirestore.instance.batch();
              final col = FirebaseFirestore.instance.collection('items');
              for (var i = 1; i <= 6; i++) {
                final doc = col.doc();
                final category = _categories[(i - 1) % _categories.length];
                batch.set(doc, {
                  'title': 'Sample Item $i',
                  'description': 'This is a sample item #$i',
                  'price': '฿${(i + 1) * 100}',
                  'category': category,
                  'imageUrl': null,
                  'ownerUid': user?.uid,
                  'ownerName': ownerName,
                  'ownerEmail': ownerEmail,
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }
              await batch.commit();
              if (!mounted) return;
              messenger.showSnackBar(const SnackBar(content: Text('Sample items added')));
            },
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    for (final category in ['All', ..._categories])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          backgroundColor: Colors.white,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          side: const BorderSide(color: Colors.black, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelStyle: TextStyle(
                            color: _selectedCategory == category ? Colors.white : Colors.black,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('items').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final docs = snap.data?.docs ?? [];

                final filteredDocs = docs.where((doc) {
                  final data = doc.data();
                  final category = (data['category'] as String?)?.trim();
                  final matchesCategory =
                      _selectedCategory == 'All' || category == _selectedCategory;
                  if (!matchesCategory) return false;

                  if (_searchQuery.isEmpty) return true;

                  final title = (data['title'] as String?)?.toLowerCase() ?? '';
                  final description = (data['description'] as String?)?.toLowerCase() ?? '';
                  final price = (data['price'] as String?)?.toLowerCase() ?? '';
                  final condition = (data['condition'] as String?)?.toLowerCase() ?? '';
                  final categoryText = (data['category'] as String?)?.toLowerCase() ?? '';
                  final ownerName = (data['ownerName'] as String?)?.toLowerCase() ?? '';
                  final ownerEmail = (data['ownerEmail'] as String?)?.toLowerCase() ?? '';
                  return title.contains(_searchQuery) ||
                      description.contains(_searchQuery) ||
                      price.contains(_searchQuery) ||
                      condition.contains(_searchQuery) ||
                      categoryText.contains(_searchQuery) ||
                      ownerName.contains(_searchQuery) ||
                      ownerEmail.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty && _selectedCategory == 'All'
                          ? 'No items found'
                          : 'No items match your filters',
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final it = doc.data();
                    final thumbUrl = (it['imageUrl'] as String?)?.trim();
                    final ownerName = (it['ownerName'] as String?)?.trim();
                    final ownerEmail = (it['ownerEmail'] as String?)?.trim();
                    final ownerUid = (it['ownerUid'] as String?)?.trim();
                    final ownerText = (ownerName != null && ownerName.isNotEmpty)
                        ? ownerName
                        : ((ownerEmail != null && ownerEmail.isNotEmpty)
                              ? ownerEmail
                              : (ownerUid ?? 'Campus Seller'));
                    return GestureDetector(
                      onTap: () => GoRouter.of(context).go('/item/${doc.id}'),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: thumbUrl != null && thumbUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        color: Colors.white,
                                        child: Image.network(
                                          thumbUrl,
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                          height: 110,
                                        ),
                                      ),
                                    )
                                  : const Center(child: Icon(Icons.image, size: 48, color: Colors.white70)),
                              ),
                              const SizedBox(height: 8),
                              Text(it['title'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(ownerText, style: Theme.of(context).textTheme.bodySmall),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(it['price'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Chip(
                                    avatar: const Icon(Icons.verified, color: Colors.white, size: 16),
                                    label: Text(it['condition'] ?? 'New'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          if (i == 1) context.go('/post');
          if (i == 2) context.go('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
