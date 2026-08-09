import '../../domain/repositories/sms_repository.dart';
import '../datasources/sms_local_data_source.dart';

class SmsRepositoryImpl implements SmsRepository {
  final SmsLocalDataSource localDataSource;

  SmsRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> requestSmsPermission() async {
    return await localDataSource.requestSmsPermission();
  }

  @override
  Future<bool> isPermissionGranted() async {
    return await localDataSource.isPermissionGranted();
  }

  @override
  void startListening(Function(String sender, String body) onSmsReceived) {
    localDataSource.startListening(onSmsReceived);
  }

  @override
  void stopListening() {
    localDataSource.stopListening();
  }

  @override
  Future<List<Map<String, String>>> getAndClearPendingBackgroundSms() async {
    return await localDataSource.getAndClearPendingBackgroundSms();
  }
}
