import 'dart:async';
import 'package:blogup_app/model/user.dart';
import 'package:blogup_app/model/post_model.dart';
import 'package:blogup_app/service/auth_service.dart';
import 'package:blogup_app/service/post_service.dart';

class PostBloc {
  StreamController _servicePost;
  StreamController _controllerPost;

  PostBloc() {
    _servicePost = StreamController<List<Post>>();
    _controllerPost = StreamController<List<Post>>();
    _servicePost.stream.listen((t) => _controllerPost.sink.add(t));
  }

  fetch() {
    PostService.instance.fetch().then((List<Post> posts) {
      _servicePost.sink.add(posts);
    });
  }

  dispose() {
    _servicePost.close();
    _controllerPost.close();
  }

  get sink => _controllerPost.sink;

  get stream => _controllerPost.stream;

  void selected(Post p) {
    if(p.id == null){
      p.date = DateTime.now();
      List<Post> list = new List<Post>();
      list.add(p);
      _servicePost.sink.add(list);
    }else{
      PostService.instance.getById(p.id).then((post) {
        List<Post> list = new List<Post>();
        list.add(post);
        _servicePost.sink.add(list);
      }).then((err) {
        _servicePost.sink.addError(err);
      });
    }
  }

  void update(Post post) {
    PostService.instance.updateData(post).then((s) {

    });
  }

  void save(Post post) {
    PostService.instance.addData(post).catchError((e)=>_servicePost.addError(e));
  }

  void remove(Post post) {
    PostService.instance.deleteData(post).catchError((e)=>_servicePost.addError(e));
  }
}
