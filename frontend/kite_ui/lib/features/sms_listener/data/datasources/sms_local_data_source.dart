import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:another_telephony/telephony.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void backGroundSmsHandler(SmsMessage message) async {
  final sender = message.address ?? '';
  final body = message.body ?? '';
  debugPrint('Background SMS Received: $sender -> $body');
  if (body.isNotEmpty) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> pending = prefs.getStringList('pending_bg_sms') ?? [];
      pending.add('$sender|||$body');
      await prefs.setStringList('pending_bg_sms', pending);
      debugPrint('Background SMS saved to pending queue successfully!');
    } catch (e) {
      debugPrint('Error saving background SMS to SharedPreferences: $e');
    }
  }
}

abstract class SmsLocalDataSource {
  Future<bool> requestSmsPermission();
  Future<bool> isPermissionGranted();
  void startListening(Function(String sender, String body) onSmsReceived);
  void stopListening();
  Future<List<Map<String, String>>> getAndClearPendingBackgroundSms();
}

class SmsLocalDataSourceImpl implements SmsLocalDataSource {
  final Telephony _telephony = Telephony.instance;

  @override
  Future<bool> requestSmsPermission() async {
    if (kIsWeb) return false;
    try {
      final bool? isGranted = await _telephony.requestPhoneAndSmsPermissions;
      debugPrint(
        'SmsLocalDataSource: Telephony request permissions = $isGranted',
      );
      if (isGranted == true) return true;
    } catch (e) {
      debugPrint('SmsLocalDataSource: Telephony permission error = $e');
    }

    final statuses = await [Permission.sms, Permission.phone].request();
    final isSmsGranted = statuses[Permission.sms]?.isGranted ?? false;
    debugPrint('SmsLocalDataSource: permission_handler status = $isSmsGranted');
    return isSmsGranted;
  }

  @override
  Future<bool> isPermissionGranted() async {
    if (kIsWeb) return false;
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  @override
  void startListening(Function(String sender, String body) onSmsReceived) {
    if (kIsWeb) return;
    try {
      debugPrint(
        'SmsLocalDataSource: Registering Telephony listenIncomingSms...',
      );
      _telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          final sender = message.address ?? '';
          final body = message.body ?? '';
          debugPrint(
            'SmsLocalDataSource: Raw SMS Caught -> Sender: "$sender", Body: "$body"',
          );
          if (body.isNotEmpty) {
            onSmsReceived(sender, body);
          }
        },
        onBackgroundMessage: backGroundSmsHandler,
        listenInBackground: true,
      );
    } catch (e) {
      debugPrint('SmsLocalDataSource: Error starting SMS listener: $e');
    }
  }

  @override
  void stopListening() {
    // Telephony stops listening when disposed
  }

  @override
  Future<List<Map<String, String>>> getAndClearPendingBackgroundSms() async {
    if (kIsWeb) return [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList('pending_bg_sms') ?? [];
      if (rawList.isEmpty) return [];

      await prefs.remove('pending_bg_sms');

      final List<Map<String, String>> result = [];
      for (final item in rawList) {
        final parts = item.split('|||');
        if (parts.length >= 2) {
          result.add({
            'sender': parts[0],
            'body': parts.sublist(1).join('|||'),
          });
        }
      }
      return result;
    } catch (e) {
      debugPrint('Error retrieving pending background SMS: $e');
      return [];
    }
  }
}
