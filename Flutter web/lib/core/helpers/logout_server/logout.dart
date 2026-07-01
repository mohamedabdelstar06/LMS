


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lms/features/screens/auth/Verify_email/view.dart';
import 'package:lms/main.dart';

import '../../cons/api_helper_resources/api_resources.dart';
import '../../cons/context/navigation_key.dart';
import '../cach_helper/shared_pref_helper.dart';

class LogoutServer {
  
  static Future<void> logout() async {
    final token = await TokenStorageHelper.getTokenSecure();

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('No token found. Please log in first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: navigatorKey.currentContext!,
      builder: (ctx) => _ConfirmLogoutDialog(
        onConfirmed: () async {
          Navigator.of(ctx).pop();
          await _showLoadingAndHandleLogout(token);
        },
      ),
    );
  }
  static Future<void> _showLoadingAndHandleLogout(String token) async {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      ),
    );

    final result = await _performLogoutRequest(token);

    if (Navigator.canPop(navigatorKey.currentContext!)) Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();

    if (result.containsKey('error')) {
      final err = result['error'];
      debugPrint('Error is => " $err');
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text(
            'Error:- Check Your Connection',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final response = result['response'] as Response;
    if (response.statusCode == 200) {
      await TokenStorageHelper.clearToken();
      ChatFabController.hide();

      final message = (response.data is Map && response.data['message'] != null)
          ? response.data['message'].toString()
          : 'Logout successful';


      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          duration: const Duration(seconds: 3),
          elevation: 6,
        ),



      );

      await Future.delayed(const Duration(milliseconds: 600));

      Navigator.pushAndRemoveUntil(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (_) => const VerifyScreen()),
            (route) => false,
      );
    } else {
      final statusMsg = response.statusMessage ?? 'Logout failed';
      String serverMsg = '';
      try {
        if (response.data is Map && response.data['message'] != null) {
          serverMsg = response.data['message'].toString();
        }
      } catch (_) {}
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(serverMsg.isNotEmpty ? serverMsg : statusMsg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  static Future<Map<String, dynamic>> _performLogoutRequest(String token) async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      const String endpoint = '${ApiResources.apiUrl}${ApiResources.logoutEndPoint}';

      final response = await dio.post(
        endpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'response': response};
    } on DioException catch (e) {
      String err = 'Network error';
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          err = data['message'].toString();
        } else if (e.response?.statusMessage != null) {
          err = e.response!.statusMessage!;
        }
      } else if (e.message != null && e.message!.isNotEmpty) {
        err = e.message!;
      }
      return {'error': err};
    } catch (e) {
      return {'error': e.toString()};
    }
  }



  static Future<void> clearAll() async {
    await TokenStorageHelper.clearToken();
  }
}




class _DialogColors {
  
  static const blue600 = Color(0xFF1570EF);
 

  
  static const red400 = Color(0xFFF97066);
  static const red500 = Color(0xFFF04438);
  static const red600 = Color(0xFFD92D20);
  static const red700 = Color(0xFFB42318);

  
  static const surfaceCard  = Color(0xFF2A2A2E);
  static const surfaceHeader= Color(0xFF232327);
  static const border       = Color(0x17FFFFFF);
  static const borderStrong = Color(0x26FFFFFF);
}

class _ConfirmLogoutDialog extends StatefulWidget {
  final VoidCallback onConfirmed;
  // ignore: sort_constructors_first
  const _ConfirmLogoutDialog({required this.onConfirmed});

  @override
  State<_ConfirmLogoutDialog> createState() => _ConfirmLogoutDialogState();
}

class _ConfirmLogoutDialogState extends State<_ConfirmLogoutDialog> {
  final _controller = TextEditingController();
  bool _isMatch = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final match = _controller.text.trim().toLowerCase() == 'logout';
      if (match != _isMatch) setState(() => _isMatch = match);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 440,
        decoration: BoxDecoration(
          color: _DialogColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _DialogColors.borderStrong),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: _DialogColors.surfaceHeader,
                border: Border(bottom: BorderSide(color: _DialogColors.border)),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: _DialogColors.red500.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _DialogColors.red500.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.logout, color: _DialogColors.red400, size: 17),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Confirm logout',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                        Text('This will end your current session',
                            style: TextStyle(color: Color(0xFF98A2B3), fontSize: 12)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Color(0xFF98A2B3), size: 18),
                  ),
                ],
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: _DialogColors.red500.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _DialogColors.red500.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: _DialogColors.red400, size: 15),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(fontSize: 13, color: Color(0xFFFFCBC8), height: 1.55),
                              children: [
                                const TextSpan(text: 'Type '),
                                WidgetSpan(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: _DialogColors.red500.withValues(alpha: 0.3)),
                                    ),
                                    child: const Text('logout',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          color: _DialogColors.red400,
                                        )),
                                  ),
                                ),
                                const TextSpan(text: ' to confirm you want to end this session.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  
                  const Text('CONFIRMATION PHRASE',
                      style: TextStyle(fontSize: 11, color: Color(0xFF98A2B3), letterSpacing: 0.5)),
                  const SizedBox(height: 6),

                  
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type logout here...',
                      hintStyle: const TextStyle(color: Color(0x44FFFFFF), fontFamily: 'monospace'),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _DialogColors.borderStrong),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _isMatch
                              ? _DialogColors.red500
                              : _DialogColors.blue600.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD0D5DD),
                            side: const BorderSide(color: _DialogColors.borderStrong),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isMatch ? widget.onConfirmed : null,
                          icon: const Icon(Icons.logout, size: 15),
                          label: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _DialogColors.red600,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _DialogColors.red700.withValues(alpha: 0.4),
                            disabledForegroundColor: Colors.white30,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
