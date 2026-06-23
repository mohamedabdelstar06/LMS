import 'package:equatable/equatable.dart';

import '../get_user_model/view.dart';

abstract class GetUsersState extends Equatable {
  const GetUsersState();

  @override
  List<Object?> get props => [];
}

class GetUsersInitial extends GetUsersState {}

class GetUsersLoading extends GetUsersState {}

class GetUsersLoaded extends GetUsersState {

  const GetUsersLoaded({
    required this.usersResponse,
    this.searchQuery = '',
    this.currentPage = 1,
    this.filterStatus = 0,
    this.sortBy = 'createdAt',
    this.order = 'desc',
  });
  final AllUsersResponseModel usersResponse;
  final String searchQuery;
  final int currentPage;
  final int filterStatus;
  final String sortBy;
  final String order;

  GetUsersLoaded copyWith({
    AllUsersResponseModel? usersResponse,
    String? searchQuery,
    int? currentPage,
    int? filterStatus,
    String? sortBy,
    String? order,
  }) {
    return GetUsersLoaded(
      usersResponse: usersResponse ?? this.usersResponse,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      filterStatus: filterStatus ?? this.filterStatus,
      sortBy: sortBy ?? this.sortBy,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
    usersResponse,
    searchQuery,
    currentPage,
    filterStatus,
    sortBy,
    order,
  ];
}

class GetUsersUnauthorized extends GetUsersState {}

class GetUsersError extends GetUsersState {
  const GetUsersError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class DeleteUserLoading extends GetUsersState {}

class DeleteUserSuccess extends GetUsersState {

  const DeleteUserSuccess(this.message);
  final String message;
}

class DeleteUserError extends GetUsersState {

  const DeleteUserError(this.message);
  final String message;
}

class GetUsersLoadingMore extends GetUsersState {}

class DeactivateUserLoading extends GetUsersState {}

class DeactivateUserSuccess extends GetUsersState {
  const DeactivateUserSuccess(this.message);
  final String message;
}

class DeactivateUserError extends GetUsersState {
  const DeactivateUserError(this.message);
  final String message;
}

class ActivateUserLoading extends GetUsersState {}

class ActivateUserSuccess extends GetUsersState {
  const ActivateUserSuccess(this.message);
  final String message;
}

class ActivateUserError extends GetUsersState {
  const ActivateUserError(this.message);
  final String message;
}

// class UpdateUsersLoading extends GetUsersState {}
//
// class UpdateUsersSuccess extends GetUsersState {
//   final String message;
//   const UpdateUsersSuccess(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }
//
// class UpdateUsersError extends GetUsersState {
//   final String message;
//   const UpdateUsersError(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }
class UpdateUsersLoading extends GetUsersState {}

class UpdateUsersSuccess extends GetUsersState {

  UpdateUsersSuccess(this.message, {this.statusCode})
      : timestamp = DateTime.now();
  final String message;
  final int? statusCode;
  final DateTime timestamp;

  @override
  List<Object?> get props => [message, statusCode, timestamp];
}

class UpdateUsersError extends GetUsersState {

  const UpdateUsersError(this.errorMessage, {this.statusCode});
  final String errorMessage;
  final int? statusCode;

  @override
  List<Object?> get props => [errorMessage, statusCode];
}

class GetUserByIdLoading extends GetUsersState {
  const GetUserByIdLoading();

  @override
  List<Object?> get props => [];
}

class GetUserByIdSuccess extends GetUsersState {

  const GetUserByIdSuccess(this.user);
  final GetUserModel user;

  @override
  List<Object?> get props => [user];
}

class GetUserByIdError extends GetUsersState {

  const GetUserByIdError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
