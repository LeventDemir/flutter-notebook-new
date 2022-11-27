import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateNote extends StatefulWidget {
  const UpdateNote({super.key});

  @override
  State<UpdateNote> createState() => _UpdateNoteState();
}

class _UpdateNoteState extends State<UpdateNote> {
  final _formKey = GlobalKey<FormState>();
  final _titleEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();
  final _picker = ImagePicker();
  late String _image = '';
  XFile? _pickedFile;

  Future<void> _showPhotoSources() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ElevatedButton.icon(
                  label: const Text('Camera'),
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Gallery'),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _pickImage(source) async {
    Navigator.pop(context);

    _pickedFile = await _picker.pickImage(source: source);

    _image = _pickedFile?.path != null ? _pickedFile!.path : '';

    setState(() => _image);
  }

  Future<void> _showPhoto() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(child: Image.file(File(_image))),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notebook'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleEditingController,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo),
                  ),
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'This field is required';

                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionEditingController,
                maxLines: 5,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo),
                  ),
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: _showPhotoSources,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: const BorderSide(width: 3, color: Colors.indigo),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
                child: const Icon(Icons.add_a_photo),
              ),
              const SizedBox(height: 10),
              _image != ''
                  ? Row(
                      children: [
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: _showPhoto,
                          child: const Text(
                            'open image',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          child: const Text(
                            'remove image',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () => setState(() => _image = ''),
                        ),
                        const SizedBox(width: 5),
                      ],
                    )
                  : const SizedBox(height: 0),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                child: const Text("Update", style: TextStyle(fontSize: 17)),
                onPressed: () => {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}