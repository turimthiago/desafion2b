import 'dart:convert';

import 'package:blogup_app/model/user.dart';
import 'package:blogup_app/bloc/auth_bloc.dart';
import 'package:blogup_app/bloc/post_bloc.dart';
import 'package:blogup_app/model/post_model.dart';
import 'package:blogup_app/pages/login_page.dart';
import 'package:blogup_app/pages/post_page.dart';
import 'package:blogup_app/pages/splash_page.dart';
import 'package:blogup_app/service/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:date_format/date_format.dart';

class MainPage extends StatefulWidget {
  User user;
  MainPage(this.user);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  AuthBloc _authBloc;
  PostBloc _postBloc;

  @override
  initState() {
    _authBloc = AuthBloc();
    _authBloc.checkUser();

    _postBloc = PostBloc();
    _postBloc.fetch();

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: StreamBuilder<User>(
        stream: _authBloc.stream,
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return PostPage(Post());
                    })).then((e) {
                      _postBloc.fetch();
                    });
                  });
            }
          }
          return Container();
        },
      ),
      appBar: AppBar(
        title: Text("BlogUpApp"),
        actions: <Widget>[
          StreamBuilder<User>(
            stream: _authBloc.stream,
            builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != null) {
                  return FlatButton(
                    onPressed: () {
                      _authBloc.signOut();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return SplashPage();
                      }));
                    },
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Text(
                          "Sign Out",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.subdirectory_arrow_right,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  );
                }
              }
              return FlatButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }));
                },
                padding: EdgeInsets.all(10.0),
                child: Row(
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[
                    Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.subdirectory_arrow_left,
                      color: Colors.white,
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: _body(context),
    );
  }

  _body(ctx) {
    return new RefreshIndicator(
      child: Container(
        padding: EdgeInsets.all(5.0),
        child: StreamBuilder<List<Post>>(
          stream: _postBloc.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Center(
                  child: Text(
                    "Não existem posts registrados.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                  ),
                );
              }
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Post post = snapshot.data[index];
                    return _listItem(post, ctx);
                  });
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
      onRefresh: _handleRefresh,
    );
  }

  Future<Null> _handleRefresh() async {
    _postBloc.fetch();
    return null;
  }

  _listItem(Post post, ctx) {
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(ctx, MaterialPageRoute(builder: (context) {
              return PostPage(post);
            })).then((d) {
              _postBloc.fetch();
            });
          },
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  post.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.date_range,
                      size: 15,
                      color: Colors.grey,
                    ),
                    Text(
                      formatDate(post.date, [
                        ' ',
                        dd,
                        '/',
                        mm,
                        '/',
                        yyyy,
                        ' ',
                        HH,
                        ':',
                        nn,
                        ':',
                        ss
                      ]),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                post.image == null
                    ? Image.asset("assets/blog_sel_img.png")
                    : Image.memory(
                        base64Decode(post.image),
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                Text(
                  post.text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authBloc.dispose();
    super.dispose();
  }
}
