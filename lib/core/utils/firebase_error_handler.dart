import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorHandler {
  static String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {

      /// 🔐 Sign In / Login Errors
      case 'user-not-found':
        return "No user found with this email.";

      case 'wrong-password':
        return "Incorrect password.";

      case 'invalid-email':
        return "Invalid email address format.";

      case 'user-disabled':
        return "This account has been disabled.";

      case 'too-many-requests':
        return "Too many attempts. Try again later.";

      case 'operation-not-allowed':
        return "This sign-in method is not enabled.";

      case 'network-request-failed':
        return "Network error. Check your internet connection.";

      /// 📝 Registration Errors
      case 'email-already-in-use':
        return "Email is already registered.";

      case 'weak-password':
        return "Password should be at least 6 characters.";

      /// 🔄 Re-authentication / Sensitive Actions
      case 'requires-recent-login':
        return "Please login again to continue.";

      case 'credential-already-in-use':
        return "This credential is already linked with another account.";

      case 'invalid-credential':
        return "Invalid login credentials.";

      /// 📱 Phone Auth Errors
      case 'invalid-verification-code':
        return "Invalid OTP code.";

      case 'invalid-verification-id':
        return "Invalid verification ID.";

      case 'session-expired':
        return "Session expired. Request a new OTP.";

      case 'quota-exceeded':
        return "SMS quota exceeded. Try again later.";

      /// 🔗 Linking Providers
      case 'provider-already-linked':
        return "This provider is already linked.";

      case 'no-such-provider':
        return "Provider not found for this user.";

      /// ❌ General Errors
      case 'internal-error':
        return "Internal server error. Try again.";

      case 'invalid-action-code':
        return "Invalid or expired action code.";

      case 'expired-action-code':
        return "Action code has expired.";

      case 'missing-email':
        return "Email is required.";

      case 'missing-password':
        return "Password is required.";

      default:
        return e.message ?? "Something went wrong. Please try again.";
    }
  }
}