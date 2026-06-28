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
  final List<GetUserModel> users;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final String searchQuery;
  final int filterStatus;
  final String roleFilter; // ← أُضيف
  final String sortBy;
  final String order;

  const GetUsersLoaded({
    required this.users,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.searchQuery = '',
    this.filterStatus = 0,
    this.roleFilter = '', // ← أُضيف
    this.sortBy = 'createdAt',
    this.order = 'desc',
  });

  @override
  List<Object?> get props => [
    users,
    totalCount,
    currentPage,
    totalPages,
    hasNextPage,
    hasPreviousPage,
    searchQuery,
    filterStatus,
    roleFilter,
    sortBy,
    order,
  ];
}

/// Shown while next page is fetching — keeps current list visible
class GetUsersLoadingMore extends GetUsersState {
  final List<GetUserModel> currentUsers;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final String searchQuery;
  final int filterStatus;
  final String sortBy;
  final String order;

  const GetUsersLoadingMore({
    required this.currentUsers,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    this.searchQuery = '',
    this.filterStatus = 0,
    this.sortBy = 'createdAt',
    this.order = 'desc',
  });

  @override
  List<Object?> get props => [
    currentUsers,
    totalCount,
    currentPage,
    totalPages,
    searchQuery,
    filterStatus,
    sortBy,
    order,
  ];
}

class GetUsersError extends GetUsersState {
  final String message;
  const GetUsersError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Get single user ───────────────────────────────────────────────────────────
class GetUserByIdLoading extends GetUsersState {
  const GetUserByIdLoading();
}

class GetUserByIdSuccess extends GetUsersState {
  final GetUserModel user;
  const GetUserByIdSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class GetUserByIdError extends GetUsersState {
  final String message;
  const GetUserByIdError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Update ────────────────────────────────────────────────────────────────────
class UpdateUsersLoading extends GetUsersState {}

class UpdateUsersSuccess extends GetUsersState {
  final String message;
  final int? statusCode;
  const UpdateUsersSuccess(this.message, {this.statusCode});
  @override
  List<Object?> get props => [message, statusCode];
}

class UpdateUsersError extends GetUsersState {
  final String errorMessage;
  final int? statusCode;
  const UpdateUsersError(this.errorMessage, {this.statusCode});
  @override
  List<Object?> get props => [errorMessage, statusCode];
}

// ── Deactivate ────────────────────────────────────────────────────────────────
class DeactivateUserLoading extends GetUsersState {}

class DeactivateUserSuccess extends GetUsersState {
  final String message;
  const DeactivateUserSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class DeactivateUserError extends GetUsersState {
  final String message;
  const DeactivateUserError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Delete ────────────────────────────────────────────────────────────────────
class DeleteUserLoading extends GetUsersState {}

class DeleteUserSuccess extends GetUsersState {
  final String message;
  const DeleteUserSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class DeleteUserError extends GetUsersState {
  final String message;
  const DeleteUserError(this.message);
  @override
  List<Object?> get props => [message];
}
