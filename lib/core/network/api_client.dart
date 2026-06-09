// ApiClient is not used; Firebase is used directly.
class ApiClient {
  ApiClient._();

  factory ApiClient() => _instance;
  static final ApiClient _instance = ApiClient._();
}
