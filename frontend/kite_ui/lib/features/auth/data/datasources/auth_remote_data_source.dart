import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> signup(SignupRequest request);
  Future<AuthResponse> login(LoginRequest request);
  Future<bool> validateToken(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  String _extractErrorMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is String && data.trim().isNotEmpty) {
        final str = data.trim();
        // Ignore generic HTML error pages
        if (!str.contains("<html>") && !str.contains("<!DOCTYPE") && !str.contains("Internal Server Error")) {
          return str;
        }
      } else if (data is Map) {
        if (data['message'] != null) return data['message'].toString();
        if (data['error'] != null) return data['error'].toString();
      }
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 401 || statusCode == 403 || statusCode == 404 || statusCode == 500) {
      return "Account not found or password incorrect. Please tap 'Sign Up' to create an account.";
    }

    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return "Server waking up (~30s). Please tap Sign In again in a few seconds!";
    }

    return "Account not found or server error. Please tap 'Sign Up' to create an account.";
  }

  @override
  Future<AuthResponse> signup(SignupRequest request) async {
    try {
      final response = await apiClient.post(Endpoints.signup, data: request.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Signup failed');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await apiClient.post(Endpoints.login, data: request.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Invalid credentials');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<bool> validateToken(String token) async {
    try {
      final response = await apiClient.get(Endpoints.validate);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
