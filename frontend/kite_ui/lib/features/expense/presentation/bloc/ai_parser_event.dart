import 'package:equatable/equatable.dart';

abstract class AiParserEvent extends Equatable {
  const AiParserEvent();

  @override
  List<Object?> get props => [];
}

class ParseSmsSubmitted extends AiParserEvent {
  final String rawText;

  const ParseSmsSubmitted(this.rawText);

  @override
  List<Object?> get props => [rawText];
}

class ResetAiParserState extends AiParserEvent {
  const ResetAiParserState();
}
