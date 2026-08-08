import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/parse_sms_usecase.dart';
import 'ai_parser_event.dart';
import 'ai_parser_state.dart';

class AiParserBloc extends Bloc<AiParserEvent, AiParserState> {
  final ParseSmsUseCase parseSmsUseCase;

  AiParserBloc({required this.parseSmsUseCase}) : super(const AiParserInitial()) {
    on<ParseSmsSubmitted>(_onParseSmsSubmitted);
    on<ResetAiParserState>(_onResetAiParserState);
  }

  Future<void> _onParseSmsSubmitted(
    ParseSmsSubmitted event,
    Emitter<AiParserState> emit,
  ) async {
    if (event.rawText.trim().isEmpty) {
      emit(const AiParserFailure('Please paste a transaction SMS or text message'));
      return;
    }

    emit(const AiParserLoading());
    try {
      final parsedModel = await parseSmsUseCase.execute(event.rawText.trim());
      emit(AiParserSuccess(parsedModel));
    } catch (e) {
      emit(AiParserFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onResetAiParserState(
    ResetAiParserState event,
    Emitter<AiParserState> emit,
  ) {
    emit(const AiParserInitial());
  }
}
