class PhoneAuthException implements Exception {
  PhoneAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
