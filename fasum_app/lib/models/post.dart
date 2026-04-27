import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  String? id;
  String? image;
  String? description;
  String? category;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  String? latitude;
  String? longitude;
  String? userId;
  String? fullName;

  Post({
    this.id,
    this.image,
    this.description,
    this.category,
    this.createdAt,
    this.fullName,
    this.latitude,
    this.longitude,
    this.updatedAt,
    this.userId,
  });

  factory Post.fromDocument(DocumentSnapshot doc){
    Map<String, dynamic> data = doc.data() as Map<String,dynamic>;
    return Post(
      id:doc.id,
      category: data["category"],
      description: data["description"],
      image: data["image"],
      latitude: data["latitude"],
      longitude: data["longitude"],
      fullName: data["fullName"],
      createdAt: data["createdAt"] as Timestamp,
      updatedAt: data["updatedAt"] as Timestamp,
      userId: data["userId"],
    );
  }

  Map<String, dynamic> toDocument(){
    return {
      "description" : description,
      "image" : image,
      "category" : category,
      "latitude" : latitude,
      "longitude" : longitude,
      "fullName" : fullName,
      "createdAt" : createdAt,
      "updatedAt" : updatedAt,
      "userId" : description,
    };
  }
}