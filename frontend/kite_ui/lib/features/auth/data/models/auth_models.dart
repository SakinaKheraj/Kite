class SignupRequest {
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  SignupRequest({
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
    };
  }
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String? token;
  final String? userId;

  AuthResponse({
    required this.accessToken,
    this.token,
    this.userId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? json['access_token'] ?? '',
      token: json['token'],
      userId: json['user_id'] ?? json['userId'],
    );
  }
}
