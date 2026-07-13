const String defaultErrorMessage = 'Lo sentimos, hubo un error. Por favor, intenta de nuevo.';

/// Sanitizes any error for user display. No technical details should ever leak.
String sanitizeErrorForUser(dynamic e) {
  if (e is String) {
    return _sanitize(e);
  }
  return defaultErrorMessage;
}

String _sanitize(String msg) {
  final lower = msg.toLowerCase();
  
  if (lower.contains('socketexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('network_error') ||
      lower.contains('connection failed') ||
      lower.contains('connection refused') ||
      lower.contains('xmlhttprequest')) {
    return 'No se pudo conectar al servidor. Por favor, verifica tu conexión a internet.';
  }

  if (lower.contains('jwt') ||
      lower.contains('token') ||
      lower.contains('signature') ||
      lower.contains('credentials')) {
    return 'Tu sesión ha expirado. Por favor, vuelve a iniciar sesión.';
  }

  if (lower.contains('exception:') ||
      lower.contains('graphqlerror') ||
      lower.contains('serverexception') ||
      lower.contains('typeerror') ||
      lower.contains('syntaxerror') ||
      lower.contains('attributeerror') ||
      lower.contains('doesnotexist') ||
      lower.contains('internal server error') ||
      lower.contains('database') ||
      lower.contains('django') ||
      lower.contains('graphene') ||
      lower.contains('null') ||
      lower.contains('stacktrace') ||
      lower.contains('traceback') ||
      lower.contains('serverfailure') ||
      msg.contains('{') ||
      msg.contains('[') ||
      msg.contains('http') ||
      msg.length > 120) {
    return defaultErrorMessage;
  }

  if (msg.startsWith('Exception: ')) {
    return _sanitize(msg.substring(11));
  }

  return msg;
}
