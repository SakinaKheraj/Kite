import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/ai_parsed_expense_model.dart';

abstract class AiRemoteDataSource {
  Future<AiParsedExpenseModel> parseSmsText(String rawText);
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final ApiClient apiClient;

  AiRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AiParsedExpenseModel> parseSmsText(String rawText) async {
    try {
      final url = '${Endpoints.dsBaseUrl}${Endpoints.parseSms}';
      final response = await apiClient.post(
        url,
        data: {'text': rawText, 'message': rawText},
      );

      if (response.statusCode == 200 && response.data != null) {
        return AiParsedExpenseModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to parse SMS with AI');
    } on DioException catch (e) {
      final msg = e.response?.data?['detail'] ?? e.message ?? 'AI Service connection error';
      throw Exception(msg);
    }
  }
}
