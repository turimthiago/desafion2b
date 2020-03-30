
import 'package:blogup_app/model/post_model.dart';

abstract class Service<T>{

  Future<T> addData(T object);

  Future<List<T>> fetch();

  Future<void> updateData(T object);

  Future<void> deleteData(T object);

  Future<Post> getById(String id);
}