import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:notebook/database/index.dart';
import 'package:notebook/models/note.dart';

import '../store/theme.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ThemeProvider theme;
  List notes = [];
  DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  void getNotes() {
    var db = dbHelper.initalizeDb();
    db.then((result) {
      var noteFuture = dbHelper.getNotes();
      noteFuture.then((data) {
        // ignore: no_leading_underscores_for_local_identifiers
        List _notes = [];
        for (int i = 0; i < data!.length; i++) {
          _notes.add(Note.formString(data[i]));
        }

        setState(() => notes = _notes);
      });
    });
  }

  void remove(int id, context) {
    ValueNotifier<bool> permission = ValueNotifier<bool>(true);

    permission.addListener(() => {getNotes()});

    Future.delayed(
      const Duration(seconds: 5),
      () => {permission.value ? dbHelper.remove(id) : getNotes()},
    );

    FToast fToast = FToast();
    fToast.init(context);

    fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.red[400],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_forever_rounded, color: Colors.white),
            const SizedBox(width: 12.0),
            const Text("Note Deleted", style: TextStyle(color: Colors.white)),
            TextButton(
              onPressed: () => {
                setState(() => permission.value = false),
                fToast.removeCustomToast()
              },
              style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
              child: Text(
                '???UNDO',
                style: TextStyle(color: Colors.grey.shade200),
              ),
            )
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 4),
    );
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
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: notes.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(notes[index].id.toString()),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                Navigator.pushNamed(
                  context,
                  'UpdateNote',
                  arguments: notes[index],
                );
              } else {
                remove(notes[index].id, context);
              }
              setState(() => notes.removeAt(index));
            },
            background: const Card(
              color: Colors.green,
              elevation: 3.0,
              child: ListTile(
                leading: Icon(Icons.edit, color: Colors.white),
                contentPadding: EdgeInsets.only(top: 9, left: 10),
              ),
            ),
            secondaryBackground: const Card(
              color: Colors.red,
              elevation: 3.0,
              child: ListTile(
                trailing: Icon(Icons.delete, color: Colors.white),
                contentPadding: EdgeInsets.only(top: 9, right: 10),
              ),
            ),
            child: Card(
              elevation: 4,
              child: ListTile(
                leading: notes[index].photo == ''
                    ? null
                    : CircleAvatar(
                        backgroundImage: FileImage(File(notes[index].photo))),
                title: Text(
                  notes[index].title,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  timeago.format(DateTime.parse(notes[index].date)),
                  style: const TextStyle(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
          size: 30,
        ),
        onPressed: () => Navigator.pushNamed(context, 'CreateNote'),
      ),
    );
  }
}
