import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> params;
  const ChatScreen({super.key, this.params = const {}});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final lowerText = text.toLowerCase();

    String replyText;
    final asksAvailability =
        lowerText.contains('available') ||
        lowerText.contains('still there') ||
        lowerText.contains('sold');
    final asksPrice =
        lowerText.contains('price') ||
        lowerText.contains('last') ||
        lowerText.contains('discount') ||
        lowerText.contains('best');
    final asksMeetup =
        lowerText.contains('meet') ||
        lowerText.contains('where') ||
        lowerText.contains('pickup') ||
        lowerText.contains('location');
    final asksTime =
        lowerText.contains('today') ||
        lowerText.contains('tonight') ||
        lowerText.contains('time') ||
        lowerText.contains('when');
    final asksCondition =
        lowerText.contains('condition') ||
        lowerText.contains('scratch') ||
        lowerText.contains('damage') ||
        lowerText.contains('new');

    if (asksAvailability) {
      replyText = 'Hi! The item is still available.';
    } else if (asksPrice) {
      replyText = 'The price is negotiable a bit. What is your offer?';
    } else if (asksMeetup) {
      replyText = 'We can meet on campus near the library this afternoon.';
    } else if (asksTime) {
      replyText = 'I am free after 3 PM today. Does that work for you?';
    } else if (asksCondition) {
      replyText = 'It is in good condition and works properly.';
    } else {
      replyText = 'Thanks for your message! Yes, it is available.';
    }

    setState(() {
      _messages.add({
        'text': text,
        'sender': 'user',
        'createdAt': DateTime.now(),
      });
    });

    _controller.clear();

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final lowerMessage = text.toLowerCase();
      if (lowerMessage.contains('100') || RegExp(r'\d+').hasMatch(lowerMessage)) {
        replyText = 'The price is negotiable. Let me think about your offer.';
      } else if (lowerMessage.contains('thank')) {
        replyText = 'Thank you for your interest in my item!';
      } else if (lowerMessage.contains('condition')) {
        replyText = 'The item is in good condition and lightly used.';
      } else if (lowerMessage.contains('pickup') || lowerMessage.contains('meet')) {
        replyText = 'We can meet near the library this afternoon.';
      } else {
        replyText = 'Could you clarify your question?';
      }

      setState(() {
        _messages.add({
          'text': replyText,
          'sender': 'owner',
          'createdAt': DateTime.now(),
        });
      });
    });
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
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final d = _messages[i];
                final isMe = d['sender'] == 'user';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Card(
                    color: isMe ? Colors.lightBlue : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        d['text'] ?? '',
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
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
