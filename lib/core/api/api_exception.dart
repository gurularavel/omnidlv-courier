/// A refusal from the server (4xx/5xx) or a network failure.
class ApiException implements Exception {
  ApiException(this.message, {this.status, this.code, this.fieldErrors = const {}, this.body});

  /// No answer at all: offline, DNS, timeout. Such actions go to the offline queue.
  factory ApiException.network(String message) => ApiException(message, code: 'network');

  final String message;
  final int? status;

  /// Stable machine code from the server, e.g. `shift_has_tasks`, `photo_required`.
  final String? code;
  final Map<String, List<String>> fieldErrors;
  final Map<String, dynamic>? body;

  bool get isNetwork => code == 'network';
  bool get isUnauthenticated => status == 401;

  String? firstError(String field) => fieldErrors[field]?.firstOrNull;

  @override
  String toString() => 'ApiException($status, $code): $message';
}
