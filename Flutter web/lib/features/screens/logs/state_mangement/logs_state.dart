import 'package:equatable/equatable.dart';
import '../model.dart';

abstract class ActivityLogsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ActivityLogsInitial extends ActivityLogsState {}

class ActivityLogsLoading extends ActivityLogsState {}

class ActivityLogsLoadingMore extends ActivityLogsState {
  final List<ActivityLog> currentLogs;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final String? activeComponent;
  final String? activeOrigin;
  final String? searchQuery;

  ActivityLogsLoadingMore({
    required this.currentLogs,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    this.activeComponent,
    this.activeOrigin,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [currentLogs, currentPage];
}

class ActivityLogsLoaded extends ActivityLogsState {
  final List<ActivityLog> logs;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final String? activeComponent;
  final String? activeOrigin;
  final String? searchQuery;

  ActivityLogsLoaded({
    required this.logs,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.activeComponent,
    this.activeOrigin,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [logs, totalCount, currentPage, activeComponent, activeOrigin, searchQuery];
}

class ActivityLogsError extends ActivityLogsState {
  final String message;

  ActivityLogsError(this.message);

  @override
  List<Object?> get props => [message];
}