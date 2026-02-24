import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/get_all%20squadrons/state_managment/cubit.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/get_all%20squadrons/state_managment/states.dart';

import '../../../../../../core/cons/Colors/app_colors.dart';
import '../../../../../../core/widgets/admin_action_button.dart';
import '../../../../../../core/widgets/custome_sidebar.dart';
import '../model/view.dart';
import '../update_squadrons/view.dart';

String selectedMenuItem = 'All Squadrons';

class GetSquadronPage extends StatefulWidget {
  const GetSquadronPage({super.key});

  @override
  State<GetSquadronPage> createState() => _SquadronsScreenState();
}

class _SquadronsScreenState extends State<GetSquadronPage> {
  int? hoveredRowIndex;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AllSquadronCubit()..fetchSquadrons(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MYColors.gradientColor_3,
              MYColors.gradientColor_2.withValues(alpha: 0.25),
              MYColors.gradientColor_3,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: BlocConsumer<AllSquadronCubit, AllSquadronState>(
            listener: (context, state) {
              if (state is DeleteSquadronSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Squadron deleted successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
                Navigator.of(context).pop();
                context.read<AllSquadronCubit>().fetchSquadrons();
              } else if (state is DeleteSquadronError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(state.message),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is AllSquadronLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AllSquadronError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ),
                );
              }

              if (state is AllSquadronLoaded) {
                return Row(
                  children: [
                    CustomeSidebar(selectedMenuItem: selectedMenuItem),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFFE2E8F0),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF2563EB,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.airplanemode_active,
                                        color: Color(0xFF2563EB),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'All Squadrons',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Manage all Squadrons',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    _buildStatsHeader(state.squadrons.length),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildModernTable(
                                        context,
                                        state.squadrons,
                                      ),
                                      const SizedBox(height: 40),
                                      _buildDangerZone(
                                        context,
                                        state.squadrons,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, List<SquadronModel> squadrons) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF2F2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danger Zone',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    Text(
                      'These actions are irreversible. Please proceed with caution.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEF4444)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: squadrons.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: Color(0xFFFFE4E4),
              indent: 24,
              endIndent: 24,
            ),
            itemBuilder: (context, index) {
              final squadron = squadrons[index];
              return _buildDangerZoneRow(context, squadron);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDangerZoneRow(BuildContext context, SquadronModel squadron) {
    final hasStudents = squadron.studentCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasStudents
                  ? Colors.grey.withOpacity(0.1)
                  : const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.airplanemode_active,
              size: 18,
              color: hasStudents ? Colors.grey : const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  squadron.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 13,
                      color: hasStudents
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasStudents
                          ? '${squadron.studentCount} student${squadron.studentCount > 1 ? 's' : ''} — cannot delete'
                          : 'No students — safe to delete',
                      style: TextStyle(
                        fontSize: 12,
                        color: hasStudents
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF64748B),
                        fontWeight: hasStudents
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Tooltip(
            message: hasStudents
                ? 'Remove all students before deleting'
                : 'Delete ${squadron.name}',
            child: ElevatedButton.icon(
              onPressed: hasStudents
                  ? null
                  : () => _showDangerDeleteDialog(context, squadron),
              icon: const Icon(Icons.delete_forever, size: 16),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDangerDeleteDialog(BuildContext context, SquadronModel squadron) {
    final TextEditingController confirmController = TextEditingController();
    final String confirmText = squadron.name;
    bool isConfirmed = false;
    final cubit = context.read<AllSquadronCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: cubit,

          child: StatefulBuilder(
            builder: (_, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: EdgeInsets.zero,
                content: Container(
                  width: 480,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFEF4444,
                                ).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_forever,
                                color: Color(0xFFEF4444),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Delete Squadron',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'This action cannot be undone',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFB91C1C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFED7AA),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Color(0xFFD97706),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'You are about to permanently delete squadron"${squadron.name}". This will remove all associated data.',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'To confirm, type the squadron name below:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.keyboard,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    confirmText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEF4444),
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: confirmController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Type squadron name here...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEF4444),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                suffixIcon: isConfirmed
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                setDialogState(() {
                                  isConfirmed = value.trim() == confirmText;
                                });
                              },
                            ),
                            if (!isConfirmed &&
                                confirmController.text.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Color(0xFFEF4444),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Squadron name does not match',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (isConfirmed)
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Name confirmed — you can now delete',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  confirmController.dispose();
                                  Navigator.pop(dialogContext);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF64748B),
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child:
                                  BlocBuilder<
                                    AllSquadronCubit,
                                    AllSquadronState
                                  >(
                                    builder: (context, state) {

                                      final isLoading =
                                          state is DeleteSquadronLoading;

                                      if (isLoading )
                                        {
                                          return ElevatedButton(
                                            onPressed: null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFEF4444,
                                              ).withOpacity(0.7),
                                              foregroundColor: Colors.white,
                                              disabledBackgroundColor:
                                              const Color(
                                                0xFFEF4444,
                                              ).withOpacity(0.7),
                                              disabledForegroundColor:
                                              Colors.white,
                                              padding:
                                              const EdgeInsets.symmetric(
                                                vertical: 14,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const SizedBox(
                                              height: 18,
                                              child:
                                             Center(
                                               child: Row(
                                                 mainAxisAlignment:
                                                 MainAxisAlignment.center,
                                                 children: [
                                                   SizedBox(
                                                     width: 20,
                                                     height: 17,
                                                     child: CircularProgressIndicator(
                                                       strokeWidth: 1.4,
                                                       valueColor:
                                                       AlwaysStoppedAnimation<
                                                           Color
                                                       >(Colors.white),
                                                     ),
                                                   ),
                                                   SizedBox(width: 10),
                                                   Text(
                                                     'Deleting...',
                                                     style: TextStyle(
                                                       fontSize: 14,
                                                       fontWeight:
                                                       FontWeight.w600,
                                                       fontFamily: 'inter',
                                                       color: Colors.white,
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                             )
                                            ),
                                          );
                                        }
                                      return ElevatedButton.icon(
                                        onPressed: isConfirmed
                                            ? () {
                                          // Navigator.pop(
                                          //   dialogContext,
                                          // );
                                          cubit.deleteSquadron(
                                            squadron.id,
                                          );
                                        }
                                            : null,
                                        icon: const Icon(
                                          Icons.delete_forever,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'Delete Forever',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFEF4444,
                                          ),
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                          Colors.grey.shade200,
                                          disabledForegroundColor:
                                          Colors.grey.shade400,
                                          padding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          elevation: 0,
                                        ),
                                      );


                                      // return isLoading
                                      //     ? ElevatedButton(
                                      //         onPressed: null,
                                      //         style: ElevatedButton.styleFrom(
                                      //           backgroundColor: const Color(
                                      //             0xFFEF4444,
                                      //           ).withOpacity(0.7),
                                      //           foregroundColor: Colors.white,
                                      //           disabledBackgroundColor:
                                      //               const Color(
                                      //                 0xFFEF4444,
                                      //               ).withOpacity(0.7),
                                      //           disabledForegroundColor:
                                      //               Colors.white,
                                      //           padding:
                                      //               const EdgeInsets.symmetric(
                                      //                 vertical: 14,
                                      //               ),
                                      //           shape: RoundedRectangleBorder(
                                      //             borderRadius:
                                      //                 BorderRadius.circular(8),
                                      //           ),
                                      //           elevation: 0,
                                      //         ),
                                      //         child: const SizedBox(
                                      //           height: 18,
                                      //           child:
                                      //               CircularProgressIndicator(
                                      //                 strokeWidth: 2,
                                      //                 color: Colors.white,
                                      //               ),
                                      //         ),
                                      //       )
                                      //     : ElevatedButton.icon(
                                      //         onPressed: isConfirmed
                                      //             ? () {
                                      //                 // Navigator.pop(
                                      //                 //   dialogContext,
                                      //                 // );
                                      //                 cubit.deleteSquadron(
                                      //                   squadron.id,
                                      //                 );
                                      //               }
                                      //             : null,
                                      //         icon: const Icon(
                                      //           Icons.delete_forever,
                                      //           size: 18,
                                      //         ),
                                      //         label: const Text(
                                      //           'Delete Forever',
                                      //           style: TextStyle(
                                      //             fontWeight: FontWeight.w600,
                                      //           ),
                                      //         ),
                                      //         style: ElevatedButton.styleFrom(
                                      //           backgroundColor: const Color(
                                      //             0xFFEF4444,
                                      //           ),
                                      //           foregroundColor: Colors.white,
                                      //           disabledBackgroundColor:
                                      //               Colors.grey.shade200,
                                      //           disabledForegroundColor:
                                      //               Colors.grey.shade400,
                                      //           padding:
                                      //               const EdgeInsets.symmetric(
                                      //                 vertical: 14,
                                      //               ),
                                      //           shape: RoundedRectangleBorder(
                                      //             borderRadius:
                                      //                 BorderRadius.circular(8),
                                      //           ),
                                      //           elevation: 0,
                                      //         ),
                                      //       );
                                    },
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total Squadrons',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernTable(
    BuildContext context,
    List<SquadronModel> squadrons,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 340,
        ),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(260),
            1: FixedColumnWidth(220),
            2: FixedColumnWidth(300),
            3: FixedColumnWidth(80),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              children: [
                _buildTableHeader('Name', Icons.badge),
                _buildTableHeader('Students Count', Icons.person),
                _buildTableHeader('Description', Icons.description),
                _buildTableHeader('Actions', Icons.settings),
              ],
            ),
            ...squadrons.asMap().entries.map((entry) {
              final index = entry.key;
              final squadron = entry.value;
              return _buildModernTableRow(context, squadron, index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: title == 'Actions'
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.blue,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildModernTableRow(
    BuildContext context,
    SquadronModel squadron,
    int index,
  ) {
    final isHovered = hoveredRowIndex == index;

    return TableRow(
      decoration: BoxDecoration(
        color: isHovered
            ? const Color(0xFF2563EB).withOpacity(0.05)
            : index.isEven
            ? Colors.white
            : const Color(0xFFF8FAFC),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: MouseRegion(
            onEnter: (_) => setState(() => hoveredRowIndex = index),
            onExit: (_) => setState(() => hoveredRowIndex = null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.airplanemode_active,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      squadron.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.people,
                    size: 14,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  squadron.studentCount.toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              squadron.description,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),

              child: AdminActionButton(
                icon: Icons.edit,
                color: const Color(0xFF2563EB),
                tooltip: 'Edit',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<AllSquadronCubit>(),
                        child: EditSquadronScreen(squadronId: squadron.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
