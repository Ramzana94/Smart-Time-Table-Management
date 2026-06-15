import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //  Signup
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  //  Login
  Future<User?> loginUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //  Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}