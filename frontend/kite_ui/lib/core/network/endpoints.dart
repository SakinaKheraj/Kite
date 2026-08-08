class Endpoints {
  Endpoints._();

  // Primary Base URL: Host VM IP address (or 10.0.2.2 for Android Emulator)
  static const String baseUrl = 'http://192.168.56.101:9898';

  static const String signup = '/auth/v1/signup';
  static const String login = '/auth/v1/login';
  static const String validate = '/auth/v1/validate';
}
