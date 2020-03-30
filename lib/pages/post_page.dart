import 'dart:async';
import 'dart:convert';

import 'package:blogup_app/auth/auth.dart';
import 'package:blogup_app/model/user.dart';
import 'package:blogup_app/bloc/auth_bloc.dart';
import 'package:blogup_app/bloc/post_bloc.dart';
import 'package:blogup_app/model/post_model.dart';
import 'package:blogup_app/service/auth_service.dart';
import 'package:blogup_app/service/post_service.dart';
import 'package:blogup_app/util/util_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PostPage extends StatefulWidget {
  Post post;
  User user;

  PostPage(this.post);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  TextEditingController _tfTitulo = TextEditingController();
  TextEditingController _tfTexto = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthBloc _authBloc;
  PostBloc _postBloc;
  bool isEditing = false;

  @override
  void initState() {
    _authBloc = AuthBloc();
    _authBloc.checkUser();

    _postBloc = PostBloc();
    if (widget.post != null) {
      _postBloc.selected(widget.post);
    }

    isEditing = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        child: StreamBuilder(
          stream: _authBloc.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                  ),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
                title: Text("Post"),
                actions: widget.user ?? _actionsAppBar(widget.post),
              );
            }
            return AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(
                  Icons.chevron_left,
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              title: Text("Post"),
            );
          },
        ),
      ),
      body: StreamBuilder<List<Post>>(
        stream: _postBloc.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            if (snapshot.data[0].id == null || isEditing) {
              return _editPostLayout(snapshot.data[0]);
            } else {
              return _viewPostLayout(snapshot.data[0]);
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  /*
  Layout para exibição de Post (sem edição)
   */
  _viewPostLayout(Post post) {
    return Container(
      padding: EdgeInsets.all(5.0),
      child: SingleChildScrollView(
        child: Card(
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  post.title,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.date_range,
                      size: 17,
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
                SizedBox(
                  height: 10,
                ),
                Text(
                  post.text,
                  style: TextStyle(fontSize: 17),
                  textAlign: TextAlign.justify,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*
  Layout para alteração do Post (com edição)
   */
  _editPostLayout(Post post) {
    widget.post = post;
    _tfTitulo.text = post.title;
    _tfTexto.text = post.text;
    return Container(
        padding: EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          child: Card(
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Informe o título do Post';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Título",
                      ),
                      controller: _tfTitulo,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.date_range,
                          size: 17,
                          color: Colors.grey,
                        ),
                        Text(
                          formatDate(
                              post == null ? DateTime.now() : post.date, [
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
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    post.image == null
                        ? GestureDetector(
                            onTap: () {
                              _getImage();
                            }, // handle your image tap here
                            child: Image.asset("assets/blog_sel_img.png"),
                          )
                        : GestureDetector(
                            onTap: () {
                              _getImage();
                            }, // handle your image tap here
                            child: Image.memory(
                              base64Decode(post.image),
                              height: 300,
                              width: 300,
                              fit: BoxFit.cover,
                            )),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Informe o texto do Post';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Texto",
                      ),
                      controller: _tfTexto,
                      style: TextStyle(fontSize: 17),
                      textAlign: TextAlign.justify,
                      maxLines: 12,
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  /*
  Seleciona imagem
   */
  _getImage() {
    Util.checkAndRequestCameraPermissions().then((b) {
      if (b) {
        ImagePicker.pickImage(
                source: ImageSource.gallery, maxHeight: 450.0, maxWidth: 450.0)
            .then((s) {
          setState(() {
            widget.post.image = base64Encode(s.readAsBytesSync());
          });
        });
      }
    });
  }

  /*
  Cria App Var botões para exclusão, alteração e deleção
   */
  _actionsAppBar(Post post) {
    return <Widget>[
      IconButton(
        icon: Icon(
          Icons.edit,
          color: Colors.white,
        ),
        onPressed: () {
          isEditing = true;
          _postBloc.selected(widget.post);
        },
      ),
      IconButton(
        icon: Icon(
          Icons.delete,
          color: Colors.white,
        ),
        onPressed: isEditing && post.id != null
            ? () {}
            : () {
                _delete(widget.post);
              },
      ),
      IconButton(
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            widget.post.text = _tfTexto.text;
            widget.post.title = _tfTitulo.text;
            if (widget.post.id == null) {
              _save(widget.post);
            } else {
              _update(widget.post);
            }
          }
        },
      )
    ];
  }

  /*
  Salva Post novo
   */
  void _save(Post post) {
    _postBloc.save(post);
    Navigator.pop(context, true);
  }

  /*
  Delete Post
   */
  void _delete(Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("BlogUp"),
          content: new Text("Remover Post?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Não"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Sim"),
              onPressed: () {
                _postBloc.remove(widget.post);
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  /*
  Altera Post
   */
  _update(Post post) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              new Text("Loading"),
            ],
          ),
        );
      },
    );
    PostService.instance.updateData(post).then((s) {
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    });
  }
}
