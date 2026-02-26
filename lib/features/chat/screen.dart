import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'provider.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> params;
  const ChatScreen({super.key, this.params = const {}});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final ChatService _chatService = ChatService();

  bool _isSending = false;

  String get _chatId => (widget.params['chatId'] as String?)?.trim() ?? '';

  Map<String, dynamic> get _itemContext {
    return {
      'itemId': widget.params['itemId'],
      'title': widget.params['title'],
      'description': widget.params['description'],
      'price': widget.params['price'],
      'condition': widget.params['condition'],
      'ownerUid': widget.params['ownerUid'],
      'itemImage': widget.params['itemImage'],
    };
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _chatId.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _controller.clear();

    try {
      await _chatService.sendMessage(
        chatId: _chatId,
        text: text,
        itemContext: _itemContext,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemImage = (widget.params['itemImage'] as String?)?.trim();
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          if (itemImage != null && itemImage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(itemImage, height: 120),
            ),
          Expanded(
            child: _chatId.isEmpty
                ? const Center(child: Text('Invalid chat ID'))
                : StreamBuilder(
                    stream: _chatService.messagesStream(_chatId),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snap.data?.docs ?? [];

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final d = docs[i].data();
                          final sender = d['sender'] as String?;
                          final text = (d['text'] as String?) ?? '';
                          final isMe = sender == currentUid;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Card(
                              color: isMe
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'Generating reply...',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isSending,
                    decoration: InputDecoration(
                      hintText: _isSending
                          ? 'Please wait...'
                          : 'Type a message',
                      prefixIcon: const Icon(Icons.chat_bubble_outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isSending ? null : _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          if (i == 0) context.go('/home');
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
