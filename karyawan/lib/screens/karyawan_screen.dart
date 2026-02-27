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
  List<Karyawan> listKaryawan = [];

  @override
  void initState(){
    super.initState();
    loadKaryawan();
  }

  Future<void> loadKaryawan() async{
    final String response = await rootBundle.loadString('assets/karyawan.json');
    final List data = json.decode(response);

    setState(() {
      listKaryawan = data.map((json) => Karyawan.fromJson(json)).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Karyawan"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: listKaryawan.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(listKaryawan[index].nama, style: TextStyle(fontWeight: FontWeight(1000)),),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Umur: "+ listKaryawan[index].umur.toString()),
                Text("Alamat: " + listKaryawan[index].alamat.jalan + ", " + listKaryawan[index].alamat.kota + ", " + listKaryawan[index].alamat.provinsi)
              ],
            ),
          );
        },
      ),
    );
  }
}
