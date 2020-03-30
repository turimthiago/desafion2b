import 'package:blogup_app/auth/auth.dart';
import 'package:blogup_app/auth/auth_firebase_impl.dart';
import 'package:blogup_app/model/user.dart';

class AuthService {
  Authentication _auth = FirebaseAuthImpl();

  AuthService._privateConstructor();

  static final AuthService _instance = AuthService._privateConstructor();

  static AuthService get instance => _instance;

  Future<User> createUser(String email, String senha) async {
    return await _auth.createUserWithEmailAndPassword(email, senha);
  }

  Future<User> signIn(String email, String password) async {
    return await _auth.signIn(email, password);
  }

  Future<User> getCurrentUser() async {
    return await _auth.getCurrentUser();
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}
