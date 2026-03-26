import 'package:dio/dio.dart';

class ExceptionUtils {
  static String handleException(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        return 'Connection timeout. Please check your internet.';
      }
      if (e.type == DioExceptionType.badResponse) {
        final code = e.response?.statusCode;
        if (code == 401) return 'Authentication failed. Please login again.';
        if (code == 403) return 'You do not have permission to access this.';
        if (code == 404) return 'Requested resource not found.';
        if (code == 500) return 'Server error. Please try again later.';
        return 'Server error (Code: $code).';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Network error. Please check your connection.';
      }
      return e.message ?? 'An error occurred while communicating with the server.';
    }

    if (e is Exception) {
      final str = e.toString().toLowerCase();
      if (str.contains('not authenticated')) return 'Session expired. Please log in.';
      if (str.contains('permission-denied')) return 'Access denied.';
      if (str.contains('user-not-found')) return 'User not found.';
      if (str.contains('wrong-password')) return 'Incorrect password.';
      return e.toString().replaceAll('Exception: ', '');
    }

    return e.toString();
  }
}
