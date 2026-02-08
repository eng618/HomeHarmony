import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'logger.dart';

/// Maps error codes and types to user-friendly messages.
/// Logs detailed errors to console for debugging while returning safe messages to users.

class ErrorMessageMapper {
  // Auth error mappings - Firebase Auth exceptions
  static const Map<String, String> _authErrorMessages = {
    'invalid-email': 'Please enter a valid email address.',
    'user-disabled': 'This account has been disabled.',
    'user-not-found': 'Account not found. Please check your credentials.',
    'wrong-password': 'Incorrect password. Please try again.',
    'email-already-in-use': 'An account with this email already exists.',
    'weak-password': 'Password is too weak. Please use a stronger password.',
    'operation-not-allowed': 'This sign-in method is not allowed.',
    'account-exists-with-different-credential': 'Account exists with a different sign-in method.',
    'requires-recent-login': 'Please sign in again to perform this action.',
    'too-many-requests': 'Too many requests. Please try again later.',
  };

  // Firestore error mappings - Firebase exceptions
  static const Map<String, String> _firestoreErrorMessages = {
    'permission-denied': 'Access denied. Please check your permissions.',
    'not-found': 'The requested data could not be found.',
    'already-exists': 'This item already exists.',
    'resource-exhausted': 'Too many requests. Please try again later.',
    'failed-precondition': 'Operation cannot be performed at this time.',
    'aborted': 'The operation was cancelled.',
    'unavailable': 'Service temporarily unavailable. Please try again.',
    'deadline-exceeded': 'Request timed out. Please try again.',
  };

  // Generic fallback messages
  static const String _genericErrorMessage = 'An unexpected error occurred. Please try again.';
  static const String _networkErrorMessage = 'Network connection issue. Please check your connection.';

  /// Maps an error to a user-friendly message while logging details.
  /// Returns a safe message for users without exposing technical details.
  static String mapError(dynamic error, {StackTrace? stackTrace}) {
    // Log the full error for debugging
    log.e('Error occurred:', error: error, stackTrace: stackTrace);

    if (error is FirebaseAuthException) {
      return _authErrorMessages[error.code] ?? _genericErrorMessage;
    }

    if (error is FirebaseException) {
      return _firestoreErrorMessages[error.code] ??
             (error.message?.toLowerCase().contains('network') ?? false
                 ? _networkErrorMessage
                 : _genericErrorMessage);
    }

    if (error is Exception) {
      final String errorString = error.toString().toLowerCase();
      if (errorString.contains('socketexception') ||
          errorString.contains('network') ||
          errorString.contains('timeout')) {
        return _networkErrorMessage;
      }
    }

    // Default to generic message for unknown errors
    return _genericErrorMessage;
  }

  /// Convenience method for catching blocks - map and return error message.
  static String catchError(Object error, {StackTrace? stackTrace}) {
    return mapError(error, stackTrace: stackTrace);
  }
}
