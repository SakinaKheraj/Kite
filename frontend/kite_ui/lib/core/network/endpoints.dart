class Endpoints {
  Endpoints._();

  // Base URL pointing directly to the Ubuntu VM runtime host
  static const String baseUrl = 'http://192.168.56.101:9898';

  static const String signup = '/auth/v1/signup';
  static const String login = '/auth/v1/login';
  static const String validate = '/auth/v1/validate';
}
