
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/get_users/state_managment/get_users_cubit.dart';
import 'package:lms/features/screens/get_users/state_managment/get_users_state.dart';

class GetUsersScreen extends StatelessWidget {
  const GetUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UsersCubit()..getUsers(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All Users'),
        ),
        body: BlocBuilder<UsersCubit, UsersState>(
          builder: (context, state) {
            if (state is UsersLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UsersUnauthorized) {
              return const Center(
                child: Text('Session expired, please login again'),
              );
            }

            if (state is UsersError) {
              return Center(child: Text(state.message));
            }

            if (state is UsersLoaded) {
              return Column(
                children: [
                  /// USERS LIST
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.users.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = state.users[index];

                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(user.fullName.isNotEmpty ? user.fullName[0] : '?'),
                          ),
                          title: Text('${user.fullName}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: ${user.id}'),
                              Text(user.email),
                              Text(
                                '${user.academicInfo?.department?.name ?? 'N/A'} • ${user.academicInfo?.year?.name ?? 'N/A'}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text('Squadron: ${user.academicInfo?.squadron?.name ?? 'N/A'}'),
                            ],
                          ),
                          trailing: Text(
                            user.accountStatus,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );

                      },
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: state.pageIndex > 1
                              ? () => context
                              .read<UsersCubit>()
                              .previousPage()
                              : null,
                          child: const Text('Previous'),
                        ),

                        Text(
                          'Page ${state.pageIndex} of ${state.totalPages}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        ElevatedButton(
                          onPressed: state.pageIndex < state.totalPages
                              ? () => context
                              .read<UsersCubit>()
                              .nextPage()
                              : null,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

