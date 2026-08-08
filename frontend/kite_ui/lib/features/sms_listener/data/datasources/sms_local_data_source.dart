import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:another_telephony/telephony.dart';

abstract class SmsLocalDataSource {
  Future<bool> requestSmsPermission();
  Future<bool> isPermissionGranted();
  void startListening(Function(String sender, String body) onSmsReceived);
  void stopListening();
}

class SmsLocalDataSourceImpl implements SmsLocalDataSource {
  final Telephony _telephony = Telephony.instance;

  @override
  Future<bool> requestSmsPermission() async {
    if (kIsWeb) return false;
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  @override
  Future<bool> isPermissionGranted() async {
    if (kIsWeb) return false;
    return await Permission.sms.isGranted;
  }

  @override
  void startListening(Function(String sender, String body) onSmsReceived) {
    if (kIsWeb) return;
    try {
      _telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          final sender = message.address ?? '';
          final body = message.body ?? '';
          if (sender.isNotEmpty && body.isNotEmpty) {
            onSmsReceived(sender, body);
          }
        },
        listenInBackground: false,
      );
    } catch (e) {
      debugPrint('SmsLocalDataSource: Error starting SMS listener: $e');
    }
  }

  @override
  void stopListening() {
    // Telephony stops listening when disposed
  }
}
