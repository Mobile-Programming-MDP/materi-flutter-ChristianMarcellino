import 'dart:convert';
import 'dart:typed_data';

import 'package:fasum_app/models/post.dart';
import 'package:fasum_app/services/fasum_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  @override
  final TextEditingController _descriptionController = TextEditingController();
    final ImagePicker _picker = ImagePicker();
    String? _image;
    Uint8List? _imageBytes;
    List<String> categories = ["Jalan Rusak", "Lampu Jalan Mati", "Lawan Arah", "Merokok di Jalan", "Tidak Pakai Helm"];
    String? _category;
    String? _latitude;
    String? _longitude;

    Future<void> pickAndConvertThenCompressImage() async {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final bytes = await image.readAsBytes();

        var result = await FlutterImageCompress.compressWithList(
          bytes,
          quality: 80,
          minWidth: 1280,
          minHeight: 1280,
        );

        final encodedResult = base64Encode(result);

        setState(() {
          _image = encodedResult;
          _imageBytes = result;
        });
      }
    }
    
    void _showCategorySelector(){
      showModalBottomSheet(context: context, builder: (context) {
        return ListView(
          shrinkWrap: true,
          children:
            categories.map((cat) {
              return ListTile(
                title: Text(cat),
                onTap: () {
                  setState(() {
                    _category = cat;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList()
        );
      },);
    }

    Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Layanan Lokasi Tidak Aktif ")));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Akses Ditolak")));
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 10));

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });
    } catch (e) {
      debugPrint("Failed to retrieve location : $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengambil lokasi.")));
      setState(() {
        _latitude = null;
        _longitude = null;
      });
    }
  }

    Future<void> _submit () async {
    if (_image == null || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Isi gambar dan deskripsi"),
          backgroundColor: const Color(0xFFB71C1C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final fullName = FirebaseAuth.instance.currentUser?.displayName;

    try{
      await _getLocation();
      FasumService.addPost(
        Post(
          category: _category,
          description: _descriptionController.text,
          fullName: fullName,
          userId: userId,
          image: _image,
          latitude: _latitude,
          longitude: _longitude,
        )
      ).whenComplete((){
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Data berhasil ditambahkan",
          ),
          backgroundColor: const Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),  
      );
      });
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Terjadi Error : $e",
          ),
          backgroundColor: const Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    }
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        title: Text("Post Cepu"),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: _descriptionController,
          ),
          TextButton(onPressed: (){
            _showCategorySelector();
          }, child: Text("Category")),
          Expanded(
            child: _imageBytes != null
                ? Image.memory(_imageBytes!, fit: BoxFit.cover, height: 150)
                : Center(child: Text("No image selected")),
          ),
          ElevatedButton(
            onPressed: pickAndConvertThenCompressImage,
            child: Text("Pick Image"),
          ),
          ElevatedButton(
            onPressed: () async {
              _getLocation();
            },
            child: Text("Get Current Location"),
          ),
          ElevatedButton(
            onPressed: () async {
              _submit();
            },
            child: Text("Submit"),
          )
        ],
      ),
    );
  }
}