import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/services/note_service.dart';

class NoteDialog extends StatefulWidget {
  final Note? note;
  const NoteDialog({super.key, this.note});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _base64Image;
  Uint8List? _imageBytes;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    if(widget.note!=null){
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
    }
    super.initState();
  }

  Future<void> pickAndConvertImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();

      final base64Str = base64Encode(bytes);

      final decodedBytes = base64Decode(base64Str);

      setState(() {
        _base64Image = base64Str;
        _imageBytes = decodedBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Add Notes' : 'Update Notes'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Title"),
          TextFormField(
            controller: _titleController,
          ),
          const Padding(padding: EdgeInsets.only(top:20), child: Text("Description"),),
          TextFormField(
            controller: _descriptionController,
            maxLines: null,
          ),
          const Padding(padding: EdgeInsets.only(top:20), child: Text("Image: "),),
          Expanded(
            child: _imageBytes != null
                ? Image.memory(
                    _imageBytes!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Center(child: Text("No image selected")),
          ),
          ElevatedButton(
            onPressed: pickAndConvertImage,
            child: Text("Pick Image"),
          ),
          ElevatedButton(onPressed: (){
            NoteService.addNote(note)
          }, child: child)
        ],
      ),
    );
  }
}