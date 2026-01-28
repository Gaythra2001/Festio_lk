class ApiConfig {
  // Base URL for the backend API
  static const String baseUrl = 'http://localhost:8000/api';
  
  // API endpoints
  static const String recommendationsEndpoint = '$baseUrl/recommendations';
  static const String interactionsEndpoint = '$baseUrl/interactions';
  static const String metricsEndpoint = '$baseUrl/metrics';
  static const String schedulerEndpoint = '$baseUrl/scheduler';
  
  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // API version
  static const String apiVersion = 'v1';
}
