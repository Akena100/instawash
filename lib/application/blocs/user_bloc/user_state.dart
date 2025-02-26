part of 'user_bloc.dart';

class UserState extends Equatable {
  final UserModel user;

  const UserState({
    required this.user,
  });

  factory UserState.initial() {
    return const UserState(user: UserModel());
  }

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'UserState(user: $user)';

  UserState copyWith({
    UserModel? user,
  }) {
    return UserState(
      user: user ?? this.user,
    );
  }
}
