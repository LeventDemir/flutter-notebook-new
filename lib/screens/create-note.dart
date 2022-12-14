// ignore_for_file: file_names

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notebook/database/index.dart';
import 'package:notebook/models/note.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../store/theme.dart';

class CreateNote extends StatefulWidget {
  const CreateNote({super.key});

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  final _formKey = GlobalKey<FormState>();
  final _titleEditingController = TextEditingController();
  final _descriptionEditingController = TextEditingController();
  final recorder = FlutterSoundRecorder();
  final audioPlayer = FlutterSoundPlayer();
  final _picker = ImagePicker();
  late String _image = '';
  XFile? _pickedFile;
  bool isRecordReady = false;
  Duration? duration;
  int sliderPosition = 0;
  bool isAudioReady = false;
  File? audioFile;
  late ThemeProvider theme;

  @override
  void initState() {
    super.initState();

    initRecorder();
  }

  @override
  void dispose() {
    recorder.stopRecorder();

    audioPlayer.closePlayer();

    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw "Microphone permission not granted!";
    }

    await recorder.openRecorder();

    await audioPlayer.openPlayer();

    isRecordReady = true;

    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future startRecord() async {
    if (!isRecordReady) return;

    final filename = 1000 + Random().nextInt(10000);
    await recorder.startRecorder(toFile: "$filename.mp4");
  }

  Future stopRecord() async {
    if (!isRecordReady) return;

    final path = await recorder.stopRecorder();
    audioFile = File(path!);

    debugPrint(audioFile!.path.toString());
  }

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

  void create() {
    if (_formKey.currentState!.validate()) {
      DbHelper dbHelper = DbHelper();

      Note note = Note(
        audio: audioFile?.path,
        photo: _image,
        title: _titleEditingController.text,
        description: _descriptionEditingController.text,
        date: DateTime.now().toIso8601String(),
      );

      dbHelper.save(note);

      Navigator.pop(context);

      FToast fToast = FToast();
      fToast.init(context);

      fToast.showToast(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.green[400],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 12.0),
              Text(
                "Note Created",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notebook'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              theme.changeTheme();

              SharedPreferences prefs = await SharedPreferences.getInstance();

              prefs.setString('theme', theme.themeMode.name);
            },
            icon: Icon(
              theme.themeMode.name == 'light'
                  ? Icons.wb_sunny_rounded
                  : Icons.nightlight_round_sharp,
            ),
          ),
          const SizedBox(width: 5)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                onChanged: (e) => setState(() {}),
                controller: _titleEditingController,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo),
                  ),
                  labelText: 'Title',
                  labelStyle: TextStyle(
                    color: _titleEditingController.text.isEmpty
                        ? Colors.indigo.shade200
                        : Colors.indigo,
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'This field is required';

                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionEditingController,
                onChanged: (e) => setState(() {}),
                maxLines: 5,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo),
                  ),
                  labelText: 'Description',
                  labelStyle: TextStyle(
                    color: _descriptionEditingController.text.isEmpty
                        ? Colors.indigo.shade200
                        : Colors.indigo,
                  ),
                  border: const OutlineInputBorder(),
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
              SizedBox(height: _image != '' ? 25 : 10),
              isAudioReady
                  ? Card(
                      color: Colors.indigo.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          const Spacer(flex: 4),
                          IconButton(
                            onPressed: () async {
                              if (audioPlayer.isPaused) {
                                await audioPlayer.resumePlayer();
                              } else if (audioPlayer.isStopped) {
                                await audioPlayer.startPlayer(
                                  fromURI: audioFile!.path,
                                  whenFinished: () => setState(() {}),
                                );
                              }

                              setState(() {});
                            },
                            icon: Icon(
                              Icons.play_arrow,
                              size: audioPlayer.isPlaying ? 35 : 30,
                              color: audioPlayer.isPlaying
                                  ? Colors.indigo.shade400
                                  : Colors.indigo.shade800,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (audioPlayer.isPlaying) {
                                await audioPlayer.pausePlayer();
                              }
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.pause,
                              size: audioPlayer.isPaused ? 30 : 25,
                              color: audioPlayer.isPaused
                                  ? Colors.indigo.shade400
                                  : Colors.indigo.shade800,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await audioPlayer.stopPlayer();
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.stop_circle_outlined,
                              size: audioPlayer.isStopped ? 30 : 25,
                              color: audioPlayer.isStopped
                                  ? Colors.indigo.shade400
                                  : Colors.indigo.shade800,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            color: Colors.redAccent,
                            onPressed: () => {
                              audioPlayer.stopPlayer(),
                              audioFile = null,
                              setState(() => isAudioReady = false),
                            },
                            icon: const Icon(Icons.delete),
                          ),
                          const SizedBox(width: 7)
                        ],
                      ),
                    )
                  : recorder.isRecording
                      ? OutlinedButton(
                          onPressed: () async {
                            await stopRecord();

                            setState(() => isAudioReady = true);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(
                              width: 3,
                              color: Colors.redAccent.shade400,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.stop_circle_outlined,
                                color: Colors.redAccent.shade400,
                              ),
                              const SizedBox(width: 10),
                              StreamBuilder<RecordingDisposition>(
                                stream: recorder.onProgress,
                                builder: (context, snapshot) {
                                  duration = snapshot.hasData
                                      ? snapshot.data!.duration
                                      : Duration.zero;
                                  return Text(
                                    "${Duration(seconds: duration!.inSeconds).toString().split(':').removeAt(1)}:${Duration(seconds: duration!.inSeconds).toString().split(':').removeAt(2).split('.').removeAt(0)}",
                                    style: const TextStyle(fontSize: 18),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      : OutlinedButton(
                          onPressed: () async {
                            await startRecord();

                            setState(() {});
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(
                                width: 3, color: Colors.indigo),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                          ),
                          child: const Icon(Icons.mic_rounded),
                        ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                onPressed: create,
                child: const Text("Create", style: TextStyle(fontSize: 17)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
