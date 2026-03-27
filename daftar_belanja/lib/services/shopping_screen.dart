import 'package:daftar_belanja/screens/shopping_service.dart';
import 'package:flutter/material.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  final ShoppingService _shoppingService = ShoppingService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Belanja"),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(8.0), 
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      hintText: "Masukkan Nama Barang"
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                     _shoppingService.addShoppingItem(_namaController.text, int.parse(_hargaController.text));
                     _namaController.clear();
                     _hargaController.clear();
                  }, 
                  icon: Icon(Icons.add)
                ),
              ],
            ),
            Expanded(
              child:
                StreamBuilder<Map<String,String>>(
                  stream: _shoppingService.getShoppingList(), 
                  builder:(context, snapshot) {
                    if(snapshot.hasData){
                      Map<String, String> items = snapshot.data!;
                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                        final key = items.keys.elementAt(index);
                        final data = items[key];
                        return ListTile(
                          title: Text(data!),
                          trailing: IconButton(onPressed: (){
                            _shoppingService.removeShoppingItem(key);
                          }, icon:Icon(Icons.delete)),
                        );
                      },);
                    }else if (snapshot.hasError){
                      return Center(
                        child: Text("Error : ${snapshot.error}"),
                      );
                    }else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
            ) 
          ],
        ),),
    );
  }
}