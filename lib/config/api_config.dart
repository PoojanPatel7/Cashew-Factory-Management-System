/// API configuration — loaded from environment / settings
class ApiConfig {
  final String apiBaseUrl;
  final String encryptEngineUrl;
  final Duration timeout;

  const ApiConfig({
    this.apiBaseUrl = 'http://localhost:4000/api',
    this.encryptEngineUrl = 'http://localhost:3100/api/v1',
    this.timeout = const Duration(seconds: 30),
  });

  /// Create from server URL (factory owner sets this during first setup)
  factory ApiConfig.fromServerUrl(String serverUrl) {
    final base = serverUrl.endsWith('/') 
        ? serverUrl.substring(0, serverUrl.length - 1) 
        : serverUrl;
    return ApiConfig(
      apiBaseUrl: '$base:4000/api',
      encryptEngineUrl: '$base:3100/api/v1',
    );
  }
}
