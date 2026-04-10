import 'package:campustrade/core/network/api_client.dart';
import 'package:campustrade/models/user.dart';
import 'package:campustrade/services/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('UserRepository', () {
    late MockApiClient apiClient;
    late UserRepository repository;

    setUp(() {
      apiClient = MockApiClient();
      repository = UserRepository(apiClient);
    });

    test('should parse fake JSON into a User object', () async {
      // This mirrors the slide: stub the API response and verify parsing.
      when(() => apiClient.get('/user')).thenAnswer(
        (_) async => {'name': 'Test User'},
      );

      final user = await repository.getUser();

      expect(user, isA<User>());
      expect(user.name, 'Test User');
      verify(() => apiClient.get('/user')).called(1);
      verifyNoMoreInteractions(apiClient);
    });

    test('should handle a missing name field as empty string', () async {
      // Edge case: repository should still parse JSON even if the name is absent.
      when(() => apiClient.get('/user')).thenAnswer(
        (_) async => <String, dynamic>{},
      );

      final user = await repository.getUser();

      expect(user.name, '');
    });
  });
}
