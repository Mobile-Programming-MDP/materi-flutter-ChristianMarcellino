 import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karyawan/models/karyawan.dart';

class KaryawanScreen extends StatefulWidget {
  const KaryawanScreen({super.key});

  @override
  State<KaryawanScreen> createState() => _KaryawanScreenState();
}

class _KaryawanScreenState extends State<KaryawanScreen> {

  @override
  void initState(){
    super.initState();
    loadKaryawan();
  }

  Future<List<Karyawan>> loadKaryawan() async{
    final String response = await rootBundle.loadString('assets/karyawan.json');
    final List data = json.decode(response);

    return data.map((json) => Karyawan.fromJson(json)).toList();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Karyawan"),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
        future : loadKaryawan(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                    title: Text(snapshot.data![index].nama, style: TextStyle(fontWeight: FontWeight(1000)),),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Umur: "+ snapshot.data![index].umur.toString()),
                        Text("Alamat: " + snapshot.data![index].alamat.jalan + ", " + snapshot.data![index].alamat.kota + ", " + snapshot.data![index].alamat.provinsi)
                      ],
                    )
                );
              },
            );
          }else if(snapshot.hasError){
            return Center(
              child: Text("Error : ${snapshot.error}")
            );
          }else{
            return Center(
            child : CircularProgressIndicator()
            );
          }
        }
      ),
    );
  }
}
