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
  void _openDetail(DocumentSnapshot<Map<String, dynamic>> doc) {
    final item = doc.data()!;
    final imageUrl = (item['imageUrl'] as String?)?.trim();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty) Center(child: Image.network(imageUrl, height: 160)),
            const SizedBox(height: 8),
            Text(item['title'] ?? '', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(item['price'] ?? '', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(item['description'] ?? ''),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final currentUid = FirebaseAuth.instance.currentUser?.uid;
                      final ownerUid = item['ownerUid'];
                      // create chat doc
                      final chatRef = await FirebaseFirestore.instance.collection('chats').add({
                        'itemId': doc.id,
                        'itemImage': imageUrl,
                        'participants': [ownerUid, currentUid],
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      // navigate to chat
                      GoRouter.of(context).go('/chat', extra: {'chatId': chatRef.id, 'itemImage': item['imageUrl'], 'ownerUid': ownerUid});
                    },
                    child: const Text('Contact Owner'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.swap_horiz),
            const SizedBox(width: 8),
            const Text('CampusTrade'),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          IconButton(
            tooltip: 'Seed sample items',
            onPressed: () async {
              final batch = FirebaseFirestore.instance.batch();
              final col = FirebaseFirestore.instance.collection('items');
              for (var i = 1; i <= 6; i++) {
                final doc = col.doc();
                batch.set(doc, {
                  'title': 'Sample Item $i',
                  'description': 'This is a sample item #$i',
                  'price': '฿${(i + 1) * 100}',
                  'imageUrl': null,
                  'ownerUid': FirebaseAuth.instance.currentUser?.uid,
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }
              await batch.commit();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sample items added')));
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
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('items').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final docs = snap.data?.docs ?? [];
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final it = doc.data();
                    final thumbUrl = (it['imageUrl'] as String?)?.trim();
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
                                decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(8)),
                                child: thumbUrl != null && thumbUrl.isNotEmpty
                                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(thumbUrl, fit: BoxFit.cover, width: double.infinity, height: 110))
                                  : const Center(child: Icon(Icons.image, size: 48, color: Colors.white70)),
                              ),
                              const SizedBox(height: 8),
                              Text(it['title'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(it['ownerUid'] ?? '', style: Theme.of(context).textTheme.bodySmall),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(it['price'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Chip(label: Text('New', style: TextStyle(color: Colors.white)), backgroundColor: Colors.lightBlue),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Post an item', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    const TextField(decoration: InputDecoration(labelText: 'Item name')),
                    const SizedBox(height: 8),
                    const TextField(decoration: InputDecoration(labelText: 'Price')),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: () { Navigator.of(context).pop(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item posted (mock)'))); }, child: const Text('Post Item')),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          if (i == 1) context.go('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
