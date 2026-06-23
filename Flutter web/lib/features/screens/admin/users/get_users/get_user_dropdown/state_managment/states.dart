import '../model_dropdown/view.dart';

abstract class UsersStateDrop {}

class UsersInitialState extends UsersStateDrop {}

class UsersLoadingState extends UsersStateDrop {}

class UsersLoadedState extends UsersStateDrop {
  UsersLoadedState(this.users);
  final List<UserLiteModel> users;
}

class UsersErrorState extends UsersStateDrop {
  UsersErrorState(this.message);
  final String message;
}
