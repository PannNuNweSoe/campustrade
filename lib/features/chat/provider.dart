import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
	ChatService({
		FirebaseFirestore? firestore,
		FirebaseFunctions? functions,
		FirebaseAuth? auth,
	}) : _firestore = firestore ?? FirebaseFirestore.instance,
		   _functions =
			   functions ?? FirebaseFunctions.instanceFor(region: 'asia-southeast1'),
			 _auth = auth ?? FirebaseAuth.instance;

	final FirebaseFirestore _firestore;
	final FirebaseFunctions _functions;
	final FirebaseAuth _auth;

	Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String chatId) {
		return _firestore
				.collection('chats')
				.doc(chatId)
				.collection('messages')
				.orderBy('createdAt', descending: false)
				.snapshots();
	}

	String _buildFallbackReply(String message, Map<String, dynamic> itemContext) {
		final lower = message.toLowerCase();
		final title = (itemContext['title'] as String?)?.trim();
		final price = (itemContext['price'] as String?)?.trim();
		final condition = (itemContext['condition'] as String?)?.trim();

		if (lower.contains('available') ||
				lower.contains('still there') ||
				lower.contains('sold')) {
			return '${title?.isNotEmpty == true ? title : 'The item'} is still available right now.';
		}

		if (lower.contains('price') ||
				lower.contains('discount') ||
				lower.contains('offer') ||
				RegExp(r'\d+').hasMatch(lower)) {
			return 'The listed price is ${price?.isNotEmpty == true ? price : 'available in the post'}. You can share your offer.';
		}

		if (lower.contains('condition') ||
				lower.contains('scratch') ||
				lower.contains('damage') ||
				lower.contains('new') ||
				lower.contains('used')) {
			return 'The item condition is ${condition?.isNotEmpty == true ? condition : 'as described in the listing'}.';
		}

		if (lower.contains('where') ||
				lower.contains('meet') ||
				lower.contains('pickup')) {
			return 'Meet-up can be arranged in a safe public area on campus.';
		}

		return 'Thanks for your message. Please ask about availability, price, condition, or meetup.';
	}

	Future<void> sendMessage({
		required String chatId,
		required String text,
		required Map<String, dynamic> itemContext,
	}) async {
		final currentUser = _auth.currentUser;
		if (currentUser == null) {
			throw Exception('You must be logged in to send a message.');
		}

		final cleanText = text.trim();
		if (cleanText.isEmpty) {
			return;
		}

		final chatDocRef = _firestore.collection('chats').doc(chatId);

		await chatDocRef.collection('messages').add({
			'text': cleanText,
			'sender': currentUser.uid,
			'senderType': 'user',
			'createdAt': FieldValue.serverTimestamp(),
		});

		final callable = _functions.httpsCallable('askChatAssistant');
		try {
			await callable.call({
				'chatId': chatId,
				'message': cleanText,
				'itemContext': itemContext,
			});
		} catch (_) {
			final fallback = _buildFallbackReply(cleanText, itemContext);
			await chatDocRef.collection('messages').add({
				'text': fallback,
				'sender': 'ai-assistant',
				'senderType': 'assistant',
				'createdAt': FieldValue.serverTimestamp(),
			});
		}
	}
}
