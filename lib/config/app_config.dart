class AppConfig {
  // --- API Configuration ---
  static const String apiBaseUrl = "https://management-service-ogma.azure-api.net";
  static const String userManagementBasePath = "/user-management";
  // Podrías tener otras bases para otros microservicios
  // static const String anotherServiceBasePath = "/another-service";
  
  // --- Storage Keys ---
  static const String jwtTokenKey = "jwt_token";
  static const String userIdKey = "user_id";
  static const String userEmailKey = "user_email";
  // ... otras claves que quieras guardar

  // --- Métodos de utilidad para construir URLs completas ---
  static String getUserManagementUrl(String endpoint) {
    return "$apiBaseUrl$userManagementBasePath$endpoint";
  }

  // static String getAnotherServiceUrl(String endpoint) {
  //   return "$apiBaseUrl$anotherServiceBasePath$endpoint";
  // }
}