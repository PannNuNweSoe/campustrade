import 'package:campustrade/features/chat/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock implements HttpsCallableResult<dynamic> {}

void main() {
  group('ChatService.sendMessage', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseFunctions functions;
    late MockHttpsCallable callable;

    setUpAll(() {
      registerFallbackValue(<String, dynamic>{});
    });

    setUp(() {
      firestore = FakeFirebaseFirestore();
      functions = MockFirebaseFunctions();
      callable = MockHttpsCallable();

      when(() => functions.httpsCallable('askChatAssistant')).thenReturn(callable);
    });

    ChatService buildService(FirebaseAuth auth) {
      return ChatService(
        firestore: firestore,
        functions: functions,
        auth: auth,
      );
    }

    test('throws exception when user is not logged in', () async {
      // Simulate signed-out state to validate error handling.
      final auth = MockFirebaseAuth(signedIn: false);
      final service = buildService(auth);

      await expectLater(
        () => service.sendMessage(
          chatId: 'chat-1',
          text: 'hello',
          itemContext: {'title': 'Laptop'},
        ),
        throwsA(isA<Exception>()),
      );

      final docs =
          await firestore.collection('chats').doc('chat-1').collection('messages').get();
      expect(docs.docs, isEmpty);
    });

    test('returns early and does not write when message is only whitespace', () async {
      // Empty/whitespace input should be ignored.
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-1', email: '6631501001@lamduan.mfu.ac.th'),
      );
      final service = buildService(auth);

      await service.sendMessage(
        chatId: 'chat-1',
        text: '   ',
        itemContext: {'title': 'Laptop'},
      );

      final docs =
          await firestore.collection('chats').doc('chat-1').collection('messages').get();
      expect(docs.docs, isEmpty);

      verifyNever(() => functions.httpsCallable(any()));
    });

    test('writes user message and calls cloud function on happy path', () async {
      // Happy path: user message is stored and callable is invoked once.
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-1', email: '6631501001@lamduan.mfu.ac.th'),
      );
      final service = buildService(auth);

      when(() => callable.call(any())).thenAnswer((_) async => MockHttpsCallableResult());

      await service.sendMessage(
        chatId: 'chat-1',
        text: 'Is this item available?',
        itemContext: {
          'title': 'Laptop',
          'price': '12,000 THB',
          'condition': 'Used',
        },
      );

      final docs = await firestore
          .collection('chats')
          .doc('chat-1')
          .collection('messages')
          .orderBy('senderType')
          .get();

      expect(docs.docs.length, 1);
      expect(docs.docs.first.data()['senderType'], 'user');
      expect(docs.docs.first.data()['sender'], 'user-1');
      expect(docs.docs.first.data()['text'], 'Is this item available?');

      verify(() => functions.httpsCallable('askChatAssistant')).called(1);
      verify(() => callable.call(any())).called(1);
    });

    test('adds fallback assistant message when callable throws', () async {
      // Sad path: cloud function fails, fallback response should be saved.
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-2', email: '6631501002@lamduan.mfu.ac.th'),
      );
      final service = buildService(auth);

      when(() => callable.call(any())).thenThrow(Exception('network down'));

      await service.sendMessage(
        chatId: 'chat-2',
        text: 'What is the price?',
        itemContext: {
          'title': 'iPad',
          'price': '12,000 THB',
          'condition': 'Like new',
        },
      );

      final docs = await firestore
          .collection('chats')
          .doc('chat-2')
          .collection('messages')
          .get();

      expect(docs.docs.length, 2);

      final messages = docs.docs.map((d) => d.data()).toList();
      final userMessage = messages.firstWhere((m) => m['senderType'] == 'user');
      final botMessage = messages.firstWhere((m) => m['senderType'] == 'assistant');

      expect(userMessage['text'], 'What is the price?');
      expect(botMessage['sender'], 'ai-assistant');
      expect((botMessage['text'] as String).toLowerCase(), contains('listed price'));
      expect((botMessage['text'] as String), contains('12,000 THB'));
    });
  });
}
