import 'package:blogup_app/model/post_model.dart';
import 'package:blogup_app/service/service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostService implements Service<Post>{
  PostService._privateConstructor();

  static final PostService _instance = PostService._privateConstructor();

  static PostService get instance => _instance;


  Future<Post> addData(Post post) async {
    try {
      DocumentReference documentReference =
          await Firestore.instance.collection('posts').add(post.toMap());

      post.id = documentReference.documentID;
      return post;
    } catch (err) {
      throw (err);
    }
  }

  Future<List<Post>> fetch() async {
    try {
      var result = await Firestore.instance.collection("posts").getDocuments();
      List<Post> posts = result.documents
          .map((d) => Post.fromJson(d.data, d.documentID))
          .toList();

      return posts;
    } catch (err) {
      throw (err);
    }
  }

  Future<void> updateData(Post post) async {
    try {
       return await Firestore.instance
          .collection('posts')
          .document(post.id)
          .updateData(post.toMap());
    } catch (err) {
      throw (err);
    }
  }

  Future<void> deleteData(Post post) {
    try {
      return Firestore.instance.collection('posts').document(post.id).delete();
    } catch (err) {
      throw (err);
    }
  }

  Future<Post> getById(String id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await Firestore.instance.collection("posts").document(id).get();

      return Post.fromJson(documentSnapshot.data, documentSnapshot.documentID);
    } catch (err) {
      throw (err);
    }
  }
}
