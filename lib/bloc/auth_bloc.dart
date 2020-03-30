import 'dart:async';
import 'package:blogup_app/model/user.dart';
import 'package:blogup_app/service/auth_service.dart';

class AuthBloc {
  StreamController _serviceController;
  StreamController _controller = StreamController<User>.broadcast();

  AuthBloc() {
    _serviceController = new StreamController<User>.broadcast();
    _serviceController.stream.listen((t) => _controller.sink.add(t));
  }

  checkUser() {
    AuthService.instance.getCurrentUser().then((user) {
      _serviceController.sink.add(user);
    }).catchError((onError) => _serviceController.sink.add(null));
  }

  signOut() {
    AuthService.instance.signOut().then((v) {
      _serviceController.sink.add(null);
    });
  }

  signIn(String email, String password) {
    AuthService.instance.signIn(email, password).then((u) {
      _serviceController.sink.add(u);
    });
  }

  get sink => _controller.sink;

  get stream => _controller.stream;

  void dispose() {
    _controller.close();
    _serviceController.close();
  }
}
