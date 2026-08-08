import '../../data/datasources/ai_remote_data_source.dart';
import '../../data/models/ai_parsed_expense_model.dart';

class ParseSmsUseCase {
  final AiRemoteDataSource remoteDataSource;

  ParseSmsUseCase(this.remoteDataSource);

  Future<AiParsedExpenseModel> execute(String rawText) async {
    return await remoteDataSource.parseSmsText(rawText);
  }
}
