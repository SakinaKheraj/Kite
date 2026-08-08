import 'package:equatable/equatable.dart';

abstract class SmsListenerEvent extends Equatable {
  const SmsListenerEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSmsListener extends SmsListenerEvent {
  const InitializeSmsListener();
}

class ToggleSmsListener extends SmsListenerEvent {
  final bool enable;

  const ToggleSmsListener(this.enable);

  @override
  List<Object?> get props => [enable];
}

class IncomingSmsReceived extends SmsListenerEvent {
  final String sender;
  final String body;

  const IncomingSmsReceived({required this.sender, required this.body});

  @override
  List<Object?> get props => [sender, body];
}

class ClearDetectedTransaction extends SmsListenerEvent {
  const ClearDetectedTransaction();
}
