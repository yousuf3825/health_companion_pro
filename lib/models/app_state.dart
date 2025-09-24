enum UserRole { doctor, pharmacy }

class AppState {
  static UserRole? currentRole;
  static String? currentUserName;
  static String? currentPharmacyName;

  static void setRole(UserRole role) {
    currentRole = role;
  }

  static void setUserName(String name) {
    currentUserName = name;
  }

  static void setPharmacyName(String name) {
    currentPharmacyName = name;
  }

  static void reset() {
    currentRole = null;
    currentUserName = null;
    currentPharmacyName = null;
  }
}
