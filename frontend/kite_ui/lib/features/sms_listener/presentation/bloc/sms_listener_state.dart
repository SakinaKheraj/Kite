import 'package:equatable/equatable.dart';
import '../../../expense/data/models/ai_parsed_expense_model.dart';

abstract class SmsListenerState extends Equatable {
  const SmsListenerState();

  @override
  List<Object?> get props => [];
}

class SmsListenerDisabled extends SmsListenerState {
  const SmsListenerDisabled();
}

class SmsListenerActive extends SmsListenerState {
  const SmsListenerActive();
}

class SmsListenerParsing extends SmsListenerState {
  const SmsListenerParsing();
}

class TransactionDetected extends SmsListenerState {
  final AiParsedExpenseModel parsedExpense;

  const TransactionDetected(this.parsedExpense);

  @override
  List<Object?> get props => [parsedExpense];
}

class SmsListenerFailure extends SmsListenerState {
  final String message;

  const SmsListenerFailure(this.message);

  @override
  List<Object?> get props => [message];
}
