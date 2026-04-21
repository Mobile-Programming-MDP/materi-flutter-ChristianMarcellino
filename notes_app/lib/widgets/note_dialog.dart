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
  bool _isEdit = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
      _imageBytes = base64Decode(widget.note!.imageBase64!);
      _isEdit = true;
      _base64Image = widget.note!.imageBase64!;
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

  Future<void> submit() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Semua field harus diisi"),
          backgroundColor: const Color(0xFFB71C1C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final Note note = Note(
      id: widget.note?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      imageBase64: _base64Image,
    );

    _isEdit
        ? await NoteService.updateNote(note)
        : await NoteService.addNote(note);

    _titleController.clear();
    _descriptionController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? "Data berhasil diupdate" : "Data berhasil ditambahkan",
          ),
          backgroundColor: const Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
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
          TextFormField(controller: _titleController),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text("Description"),
          ),
          TextFormField(controller: _descriptionController, maxLines: null),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text("Image: "),
          ),
          Expanded(
            child: _imageBytes != null
                ? Image.memory(_imageBytes!, fit: BoxFit.cover, height: 150)
                : Center(child: Text("No image selected")),
          ),
          ElevatedButton(
            onPressed: pickAndConvertImage,
            child: Text("Pick Image"),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              submit();
            },
            child: Text(_isEdit ? "Update" : "Simpan"),
          ),
        ],
      ),
    );
  }
}
