import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fasum_app/models/post.dart';

class FasumService{
  static final FirebaseFirestore _database = FirebaseFirestore.instance;
  static final CollectionReference _postsCollection = _database.collection(
    "posts",
  );

  static Future<void> addPost(Post post) async {
    Map<String, dynamic> newPost = {
      "category": post.category,
      "description": post.description,
      "image": post.image,
      "created_at": FieldValue.serverTimestamp(),
      "updated_at": FieldValue.serverTimestamp(),
      "latitude" : post.latitude,
      "longitude": post.longitude,
      "full_name" : post.fullName,
      "user_id" : post.userId
    };
    await _postsCollection.add(newPost);
  }

  static Stream<List<Post>> getNoteList() {
    return _postsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Post(
          id: doc.id,
          category: data["category"],
          description: data["description"],
          image: data["image"],
          createdAt: data["created_at"] != null
              ? data["created_at"] as Timestamp
              : null,
          updatedAt: data["updated_at"] != null
              ? data["updated_at"] as Timestamp
              : null,
          latitude: data["latitude"],
          longitude: data["longitude"],
          fullName : data["full_name"],
          userId : data["user_id"]
        );
      }).toList();
    });
  }

  static Future<void> updateNote(Post post) async {
    Map<String, dynamic> updatedPost = {
      "category": post.category,
      "description": post.description,
      "image": post.image,
      "updated_at": FieldValue.serverTimestamp(),
      "latitude" : post.latitude,
      "longitude": post.longitude,
      "full_name" : post.fullName,
      "user_id" : post.userId
    };
    await _postsCollection.doc(post.id).update(updatedPost);
  }

  static Future<void> deleteNote(Post post) async {
    await _postsCollection.doc(post.id).delete();
  }
  
}