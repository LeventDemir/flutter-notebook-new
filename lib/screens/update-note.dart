import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notebook/database/index.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:notebook/models/note.dart';

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
  final recorder = FlutterSoundRecorder();
  final audioPlayer = FlutterSoundPlayer();
  late String _image = '';
  XFile? _pickedFile;
  Note? note;
  bool isRecordReady = false;
  Duration? duration;
  double sliderPosition = 0;
  bool isAudioReady = false;
  File? audioFile;
  String? audioPath;

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

  void update() {
    if (_formKey.currentState!.validate()) {
      DbHelper dbHelper = DbHelper();

      Note x = Note(
        id: note!.id,
        title: _titleEditingController.text,
        description: _descriptionEditingController.text,
        photo: _image,
        audio: audioFile!.path,
        date: note!.date,
      );

      dbHelper.update(x);

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
    if (_formKey.currentState == null) {
      note = ModalRoute.of(context)!.settings.arguments as Note;

      _image = note!.photo!;
      _titleEditingController.text = note!.title;
      _titleEditingController.text = note!.title;
      _descriptionEditingController.text = note!.description!;

      if (note!.audio != null) {
        audioPath = note!.audio;
        isAudioReady = true;
      }
    }

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
              SizedBox(height: _image != '' ? 25 : 10),
              isAudioReady
                  ? Card(
                      color: Colors.indigo.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 2),
                          IconButton(
                            onPressed: () async {
                              if (audioPlayer.isPlaying) {
                                await audioPlayer.pausePlayer();
                              } else if (audioPlayer.isPaused) {
                                await audioPlayer.resumePlayer();
                              } else {
                                await audioPlayer.startPlayer(
                                  fromURI: audioFile?.path ?? audioPath,
                                  whenFinished: () => setState(() {}),
                                );
                              }
                              setState(() {});
                            },
                            icon: Icon(
                              audioPlayer.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 30,
                              color: Colors.indigo.shade800,
                            ),
                          ),
                          IconButton(
                            color: Colors.redAccent,
                            onPressed: () => {
                              audioFile = null,
                              setState(() => isAudioReady = false),
                            },
                            icon: const Icon(Icons.delete),
                          ),
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
                            primary: Colors.redAccent.shade400,
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
                                    Duration(seconds: duration!.inSeconds)
                                            .toString()
                                            .split(':')
                                            .removeAt(1)
                                            .toString() +
                                        ":" +
                                        Duration(seconds: duration!.inSeconds)
                                            .toString()
                                            .split(':')
                                            .removeAt(2)
                                            .split('.')
                                            .removeAt(0)
                                            .toString(),
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
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                child: const Text("Update", style: TextStyle(fontSize: 17)),
                onPressed: update,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
