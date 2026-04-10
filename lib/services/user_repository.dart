import 'package:campustrade/core/network/api_client.dart';
import 'package:campustrade/models/user.dart';

class UserRepository {
  UserRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<User> getUser() async {
    final json = await _apiClient.get('/user');
    return User.fromJson(json);
  }
}
