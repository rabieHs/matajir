class Validators {
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(email);
  }

  static bool isValidUrl(String url) {
    // Simple URL validation
    final urlRegExp = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    return urlRegExp.hasMatch(url);
  }

  static bool isValidPhoneNumber(String phoneNumber) {
    // Simple phone number validation
    final phoneRegExp = RegExp(
      r'^\+?[0-9]{8,14}$',
    );
    return phoneRegExp.hasMatch(phoneNumber);
  }
}
