import 'dart:async';

import 'package:blogup_app/pages/main_page.dart';
import 'package:blogup_app/service/auth_service.dart';
import 'package:blogup_app/util/util_app.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _tfLogin = TextEditingController();
  TextEditingController _tfSenha = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  StreamController _controller = StreamController<bool>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return Builder(
      builder: (BuildContext ctx) {
        return Center(
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
            )),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 180,
                      padding: EdgeInsets.all(30.0),
                      child: Image.asset("assets/blog_logo.png"),
                    ),
                    Container(
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius:
                                0, // has the effect of softening the shadow
                            spreadRadius:
                                6, // has the effect of extending the shadow
                            offset: Offset(
                              0, // horizontal, move right 10
                              0, // vertical, move down 10
                            ),
                          )
                        ],
                      ),
                      child: Center(
                          child: Form(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              controller: _tfLogin,
                              decoration: InputDecoration(
                                labelText: "Enter e-mail",
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            TextFormField(
                              controller: _tfSenha,
                              decoration: InputDecoration(
                                labelText: "Enter password",
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            Padding(padding: const EdgeInsets.only(top: 20.0)),
                            StreamBuilder<bool>(
                              initialData: false,
                              stream: _controller.stream,
                              builder: (context, snapshot) {
                                return MaterialButton(
                                  height: 40.0,
                                  minWidth: 100.0,
                                  color: Colors.blueAccent,
                                  textColor: Colors.white70,
                                  child: snapshot.data
                                      ? CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white))
                                      : new Text("Login"),
                                  onPressed: () {
                                    _onClickLogin(ctx);
                                  },
                                  splashColor: Colors.blue,
                                );
                              },
                            )
                          ],
                        ),
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _onClickLogin(ctx) {
    _controller.add(true);
    AuthService.instance.signIn(_tfLogin.text, _tfSenha.text).then((s) {
      Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (context) {
        _controller.add(false);
        return MainPage(s);
      }));
    }).catchError((err) {
      _controller.add(false);
      Util.showErrorMessage(ctx, err);
    });
  }
}
