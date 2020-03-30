import 'package:blogup_app/pages/login_page.dart';
import 'package:blogup_app/pages/main_page.dart';
import 'package:blogup_app/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  initState() {
    AuthService.instance.getCurrentUser().then((user) {
      Future.delayed(Duration(seconds: 4)).then((_) {
        Navigator.of(context).pushReplacement(_createRoute(user));
      });
    }).then((err) {
      print(err);
    });

    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  Route _createRoute(user) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MainPage(user),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.fastOutSlowIn;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
                colors: [
                  Color(0xFF175570),
                  Color(0xFF72d8ff),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset("assets/blog_logo.png"),
                SizedBox(
                  height: 20,
                ),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              ],
            )),
      ),
    );
  }
}
