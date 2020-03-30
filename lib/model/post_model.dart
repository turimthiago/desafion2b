class Post {
  String id;
  String title;
  String text;
  DateTime date;
  String image;

  Post({this.id, this.title, this.text, this.date, this.image});

  factory Post.fromJson(Map<String, dynamic> json, String uid) {
    return Post(
        id: uid,
        title: json['title'],
        text: json['text'],
        date: json['date'].toDate(),
        image: json['image']);
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['id'] = id;
    map['title'] = title;
    map['text'] = text;
    map['date'] = date;
    map['image'] = image;

    return map;
  }
}
