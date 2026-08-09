import 'package:flutter/foundation.dart';
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
    debugPrint('SmsListenerBloc: Initialize check permission granted = $granted');
    if (granted) {
      _startSmsListening();
      emit(const SmsListenerActive());

      // Process any background SMS messages queued while app was closed
      final pendingList = await smsRepository.getAndClearPendingBackgroundSms();
      debugPrint('SmsListenerBloc: Found ${pendingList.length} pending background SMS messages');
      for (final item in pendingList) {
        add(IncomingSmsReceived(
          sender: item['sender'] ?? '',
          body: item['body'] ?? '',
        ));
      }
    } else {
      emit(const SmsListenerDisabled());
    }
  }

  Future<void> _onToggleSmsListener(
    ToggleSmsListener event,
    Emitter<SmsListenerState> emit,
  ) async {
    debugPrint('SmsListenerBloc: Toggle listener requested enable = ${event.enable}');
    if (event.enable) {
      final granted = await smsRepository.requestSmsPermission();
      debugPrint('SmsListenerBloc: Permission request result = $granted');
      if (granted) {
        _startSmsListening();
        emit(const SmsListenerActive());

        // Process any background SMS messages queued while app was closed
        final pendingList = await smsRepository.getAndClearPendingBackgroundSms();
        for (final item in pendingList) {
          add(IncomingSmsReceived(
            sender: item['sender'] ?? '',
            body: item['body'] ?? '',
          ));
        }
      } else {
        emit(const SmsListenerFailure('SMS permission rejected by user'));
      }
    } else {
      smsRepository.stopListening();
      emit(const SmsListenerDisabled());
    }
  }

  void _startSmsListening() {
    debugPrint('SmsListenerBloc: Starting Telephony SMS listener stream...');
    smsRepository.startListening((sender, body) {
      debugPrint('SmsListenerBloc: Event triggered from $sender: $body');
      add(IncomingSmsReceived(sender: sender, body: body));
    });
  }

  Future<void> _onIncomingSmsReceived(
    IncomingSmsReceived event,
    Emitter<SmsListenerState> emit,
  ) async {
    debugPrint('SmsListenerBloc: Processing incoming SMS from ${event.sender}: ${event.body}');

    // Rule 1: Local Privacy Filter
    final isFinancial = SmsPrivacyFilter.isFinancialSms(event.sender, event.body);
    debugPrint('SmsListenerBloc: isFinancialSms match result = $isFinancial');
    if (!isFinancial) {
      return;
    }

    // Rule 2: On-Device Sanitization
    final sanitizedText = SmsPrivacyFilter.sanitizeSmsBody(event.body);
    debugPrint('SmsListenerBloc: Sanitized text = $sanitizedText');

    emit(const SmsListenerParsing());

    try {
      final parsedExpense = await parseSmsUseCase.execute(sanitizedText);
      debugPrint('SmsListenerBloc: Parse result amount = ${parsedExpense.amount}, desc = ${parsedExpense.description}');
      if (parsedExpense.amount > 0) {
        emit(TransactionDetected(parsedExpense));
      } else {
        emit(const SmsListenerActive());
      }
    } catch (e) {
      debugPrint('SmsListenerBloc: Parse exception = $e');
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
