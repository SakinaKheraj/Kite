import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/sms_privacy_filter.dart';
import '../../../expense/domain/usecases/parse_sms_usecase.dart';
import '../../domain/repositories/sms_repository.dart';
import 'sms_listener_event.dart';
import 'sms_listener_state.dart';

class SmsListenerBloc extends Bloc<SmsListenerEvent, SmsListenerState> {
  final SmsRepository smsRepository;
  final ParseSmsUseCase parseSmsUseCase;

  SmsListenerBloc({
    required this.smsRepository,
    required this.parseSmsUseCase,
  }) : super(const SmsListenerDisabled()) {
    on<InitializeSmsListener>(_onInitializeSmsListener);
    on<ToggleSmsListener>(_onToggleSmsListener);
    on<IncomingSmsReceived>(_onIncomingSmsReceived);
    on<ClearDetectedTransaction>(_onClearDetectedTransaction);
  }

  Future<void> _onInitializeSmsListener(
    InitializeSmsListener event,
    Emitter<SmsListenerState> emit,
  ) async {
    final granted = await smsRepository.isPermissionGranted();
    if (granted) {
      _startSmsListening();
      emit(const SmsListenerActive());
    } else {
      emit(const SmsListenerDisabled());
    }
  }

  Future<void> _onToggleSmsListener(
    ToggleSmsListener event,
    Emitter<SmsListenerState> emit,
  ) async {
    if (event.enable) {
      final granted = await smsRepository.requestSmsPermission();
      if (granted) {
        _startSmsListening();
        emit(const SmsListenerActive());
      } else {
        emit(const SmsListenerFailure('SMS permission rejected by user'));
      }
    } else {
      smsRepository.stopListening();
      emit(const SmsListenerDisabled());
    }
  }

  void _startSmsListening() {
    smsRepository.startListening((sender, body) {
      add(IncomingSmsReceived(sender: sender, body: body));
    });
  }

  Future<void> _onIncomingSmsReceived(
    IncomingSmsReceived event,
    Emitter<SmsListenerState> emit,
  ) async {
    // Rule 1: Local Privacy Filter — ignore personal phone numbers & non-financial SMS
    if (!SmsPrivacyFilter.isFinancialSms(event.sender, event.body)) {
      return;
    }

    // Rule 2: On-Device Sanitization — strip OTPs, CVVs, and account digits
    final sanitizedText = SmsPrivacyFilter.sanitizeSmsBody(event.body);

    emit(const SmsListenerParsing());

    try {
      final parsedExpense = await parseSmsUseCase.execute(sanitizedText);
      if (parsedExpense.amount > 0) {
        emit(TransactionDetected(parsedExpense));
      } else {
        emit(const SmsListenerActive());
      }
    } catch (e) {
      emit(const SmsListenerActive());
    }
  }

  void _onClearDetectedTransaction(
    ClearDetectedTransaction event,
    Emitter<SmsListenerState> emit,
  ) {
    emit(const SmsListenerActive());
  }
}
