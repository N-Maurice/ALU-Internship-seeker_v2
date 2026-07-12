import 'package:firebase_auth/firebase_auth.dart';

import 'failure.dart';

/// Translates Firebase/platform exceptions into a [Failure] with a message
/// safe to show directly in the UI.
Failure mapExceptionToFailure(Object error) {
  if (error is FirebaseAuthException) return Failure(_authMessage(error));
  if (error is FirebaseException) return Failure(_firestoreMessage(error));
  return const Failure('Something went wrong. Please try again.');
}

String _authMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'That email address looks invalid.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Incorrect email or password.';
    case 'email-already-in-use':
      return 'An account already exists with this email.';
    case 'weak-password':
      return 'Choose a stronger password (at least 8 characters).';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a moment and try again.';
    case 'network-request-failed':
      return 'No internet connection. Check your network and try again.';
    case 'invalid-api-key':
    case 'app-not-authorized':
    case 'configuration-not-found':
      return 'The app is not connected to a Firebase project yet.';
    default:
      return e.message ?? 'Authentication failed. Please try again.';
  }
}

String _firestoreMessage(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return "You don't have permission to do that.";
    case 'unavailable':
      return 'Service is temporarily unavailable. Please try again.';
    case 'not-found':
      return 'The requested data could not be found.';
    default:
      return e.message ?? 'Could not reach the server. Please try again.';
  }
}
