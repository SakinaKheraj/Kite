abstract class SmsRepository {
  Future<bool> requestSmsPermission();
  Future<bool> isPermissionGranted();
  void startListening(Function(String sender, String body) onSmsReceived);
  void stopListening();
  Future<List<Map<String, String>>> getAndClearPendingBackgroundSms();
}
