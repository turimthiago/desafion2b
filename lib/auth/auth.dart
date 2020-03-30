import 'package:blogup_app/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class Authentication {

  Future<User> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<User> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();

  Future<User> createUserWithEmailAndPassword(String email, String senha);
}