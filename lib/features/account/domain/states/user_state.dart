// features/account/domain/states/user_state.dart

import '../../data/models/user_model.dart';

enum UserStatus { initial, loading, ready, error }

class UserState {
  final UserStatus status;
  final UserModel? user;
  final String? errorMessage;

  const UserState._({required this.status, this.user, this.errorMessage});
  const UserState.initial() : this._(status: UserStatus.initial);
  const UserState.loading() : this._(status: UserStatus.loading);
  const UserState.ready(UserModel user)
      : this._(status: UserStatus.ready, user: user);
  const UserState.error(String message)
      : this._(status: UserStatus.error, errorMessage: message);

  UserState copyWith({
    UserStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return UserState._(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
