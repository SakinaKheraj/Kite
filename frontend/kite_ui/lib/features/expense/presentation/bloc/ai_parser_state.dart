import 'package:equatable/equatable.dart';
import '../../data/models/ai_parsed_expense_model.dart';

abstract class AiParserState extends Equatable {
  const AiParserState();

  @override
  List<Object?> get props => [];
}

class AiParserInitial extends AiParserState {
  const AiParserInitial();
}

class AiParserLoading extends AiParserState {
  const AiParserLoading();
}

class AiParserSuccess extends AiParserState {
  final AiParsedExpenseModel parsedExpense;

  const AiParserSuccess(this.parsedExpense);

  @override
  List<Object?> get props => [parsedExpense];
}

class AiParserFailure extends AiParserState {
  final String message;

  const AiParserFailure(this.message);

  @override
  List<Object?> get props => [message];
}
