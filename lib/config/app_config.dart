class AppConfig {
  // --- API Configuration ---
  //static const String apiBaseUrl = "https://management-service-ogma.azure-api.net";
  //static const String userManagementBasePath = "/user-management";
  static const String capacityControlBaseUrl = "https://ogma-repository-hub-capacity-control.onrender.com";
  static const String equipmentRutineServiceBaseUrl = "https://ogma-repository-hub-routine-equipment.onrender.com";
  static const String bookingServiceBaseUrl = "https://ogma-repository-hub-booking-management.onrender.com";
  static const String apiBaseUrl = "https://user-management-service-wd84.onrender.com";
  static const String userManagementBasePath = "/api";
  static const String capacityControlBasePath = "/api";
  static const String bookingServiceBasePath = "/api";
  static const String equipmentServiceBasePath = "/api";

  // --- Storage Keys ---
  static const String jwtTokenKey = "jwt_token";
  static const String userIdKey = "user_id";
  static const String userEmailKey = "user_email";
  static const String appId = "1383300406";
  static const String appSign = "6926969e641294afad2b7e46200b140357f3ebaca35c961ff927218ef91a5787";

  // --- usuario creado para la IA
  static const int idEntrenadorAsignadorIa = 33; 

  // --- Métodos de utilidad para construir URLs completas ---
  static String getUserManagementUrl(String endpoint) {
    return "$apiBaseUrl$userManagementBasePath$endpoint";
  }

  static String getCapacityControlUrl(String endpoint) {
    return "$capacityControlBaseUrl$capacityControlBasePath$endpoint";
  }

  static String getBookingServiceUrl(String endpoint) {
    return "$bookingServiceBaseUrl$bookingServiceBasePath$endpoint";
  }

  static String getEquipmentRutineService(String endpoint) {
    return "$equipmentRutineServiceBaseUrl$equipmentServiceBasePath$endpoint";
  }

  static int getAppId() {
    return int.parse(appId);
  }

  static String getAppSign() {
    return appSign;
  }
}