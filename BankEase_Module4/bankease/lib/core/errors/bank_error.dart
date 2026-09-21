/// Every failure the app can show the user, as one closed set of types.
/// `sealed` means a switch over BankError must handle every case,
/// so a new error type can never be forgotten.
sealed class BankError implements Exception {
  const BankError(this.message);
  final String message;

  @override
  String toString() => message;
}

/// No internet, DNS failure, server not running, or a timeout.
class NetworkError extends BankError {
  const NetworkError([super.message = 'No connection. Check your network and try again.']);
}

/// 401: no token, bad token or expired session.
class SessionExpired extends BankError {
  const SessionExpired([super.message = 'Your session expired. Please log in again.']);
}

/// 400: the server rejected the fields. `fieldErrors` maps field name to message.
class ValidationError extends BankError {
  const ValidationError(super.message, this.fieldErrors);
  final Map<String, String> fieldErrors;
}

/// 409 / 422: a business rule said no (insufficient funds, duplicate payee, limit).
class BusinessError extends BankError {
  const BusinessError(this.code, super.message, [this.details = const {}]);
  final String code;
  final Map<String, dynamic> details;
}

/// 403, 404, 5xx and anything else the server returned.
class ServerError extends BankError {
  const ServerError(this.statusCode, [super.message = 'Service unavailable. Please try again.']);
  final int statusCode;
}
