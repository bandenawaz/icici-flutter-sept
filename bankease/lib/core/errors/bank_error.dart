/// Every failure the app can show the user, as one closed set of types.
/// 'sealed' means a switch over BankError must handle every case.
/// so a new error type can never be forgotten

sealed class BankError implements Exception {
  final String message;
  const BankError(this.message);

  @override
  String toString() => message;
}

/// No internet, DNS failure, server not running, or a timeout
class NetworkError extends BankError {
  const NetworkError(
      [super.message = 'No connection. Check your network and try again.']);
}

///401, no token, bad token or expired session
class SessionExpired extends BankError {
  const SessionExpired(
      [super.message = 'Your session has expired. Please log in again.']);
}

/// 400: there server rejected the fields. 'fielerrors maps field name to message.
class ValidationError extends BankError {
  final Map<String, String> fieldErrors;
  const ValidationError(super.message, this.fieldErrors);
}

/// 409/402
class BusinessError extends BankError {
  final String code;
  final Map<String, dynamic> details;
  const BusinessError(this.code, super.message, this.details);
}

/// 403,404,5XX and anything else the server returned
class ServerError extends BankError {
  final int statusCode;
  const ServerError(this.statusCode,
      [super.message = 'Service unavailable. Please try again.']);
}
