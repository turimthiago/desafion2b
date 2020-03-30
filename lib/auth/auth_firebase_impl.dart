import 'package:blogup_app/auth/auth.dart';
import 'package:blogup_app/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthImpl implements Authentication {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User> signIn(String email, String password) async {
    try {
      AuthResult auth = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return _createUser(auth.user);
    } catch (err) {
      throw (_handleError(err));
    }
  }

  Future<String> signUp(String email, String password) async {
    try {
      AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return user.uid;
    } catch (err) {
      throw (_handleError(err));
    }
  }

  Future<User> getCurrentUser() async {
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    if(firebaseUser == null){
      return null;
    }
    return _createUser(firebaseUser);
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  _createUser(FirebaseUser user) {
    return User(user.displayName, user.email, user.uid);
  }

  Future<User> createUserWithEmailAndPassword(
      String email, String senha) async {
    AuthResult auth = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: senha);
    return _createUser(auth.user);
  }

  _handleError(e) {
    switch (e.code) {
      case 'ERROR_INVALID_EMAIL':
        return 'Email inváido';
        break;
      case 'ERROR_USER_NOT_FOUND':
        return 'Usuário não encontrado';
        break;
      case 'ERROR_WRONG_PASSWORD':
        return 'Senha inválida';
        break;
      default:
        return 'Ocorreu um erro inesperado';
        break;
    }
  }
}
