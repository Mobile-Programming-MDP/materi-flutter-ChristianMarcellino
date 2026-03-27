import 'package:firebase_database/firebase_database.dart';

class ShoppingService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('shopping_list');

  Stream<Map<String, String>> getShoppingList(){
    return _database.onValue.map((e) {
      final Map<String, String> items = {};
      DataSnapshot snapshot = e.snapshot;
      if(snapshot.value != null) {
        Map<dynamic,dynamic> values = snapshot.value as Map<dynamic,dynamic>;
        values.forEach((key,value) {
          items[key] = value['name'] as String;
        });
      }
      return items;
    });
  }
// Convert to map with model later for better usage
  void addShoppingItem(String name, int harga){
    _database.push().set({'name' : name, 'harga' : harga});
  }

  Future<void> removeShoppingItem(String key) async {
    await _database.child(key).remove();
  }
}