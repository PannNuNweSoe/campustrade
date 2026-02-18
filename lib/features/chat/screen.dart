import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> params;
  const ChatScreen({super.key, this.params = const {}});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? chatId;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    chatId = widget.params['chatId'] as String?;
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || chatId == null) return;
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
      'text': text,
      'sender': user?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final itemImage = (widget.params['itemImage'] as String?)?.trim();
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          if (itemImage != null && itemImage.isNotEmpty) Padding(padding: const EdgeInsets.all(8.0), child: Image.network(itemImage, height: 120)),
          Expanded(
            child: chatId == null
                ? const Center(child: Text('No chat selected'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').orderBy('createdAt').snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                      final docs = snap.data!.docs;
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final d = docs[i].data() as Map<String, dynamic>;
                          final isMe = d['sender'] == FirebaseAuth.instance.currentUser?.uid;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Card(
                              color: isMe ? Colors.lightBlue : Colors.white,
                              child: Padding(padding: const EdgeInsets.all(8.0), child: Text(d['text'] ?? '', style: TextStyle(color: isMe ? Colors.white : Colors.black))),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Type a message', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none)),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(onPressed: _sendMessage, child: const Icon(Icons.send), mini: true),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
        onTap: (i) { if (i==0) Navigator.of(context).pushReplacementNamed('/home'); },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
