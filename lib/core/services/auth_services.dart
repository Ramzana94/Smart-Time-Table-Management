import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Signup
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      log("Signup Error: ${e.toString()}");
      return null;
    }
  }

  // 🔹 Login
  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      log("Login Error: $e");
      return null;
    }
  }

  // 🔹 Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Logout Error: $e");
    }
  }
  Future<void> forgotPasswordWithEmail(String email)async{
try{
  await _auth.sendPasswordResetEmail(email: email);
  log("Password reset Email send");
}catch(e){
  log("forgot Password error: $e");
  rethrow;
}
  }
}