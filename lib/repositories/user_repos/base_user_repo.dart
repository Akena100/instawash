part of 'user_repo.dart';

abstract class BaseUserRepository {
  Stream<UserModel> getUser(String userId);
}
