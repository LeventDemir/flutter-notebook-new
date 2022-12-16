import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:notebook/database/index.dart';
import 'package:notebook/models/note.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List notes = [];
  DbHelper dbHelper = new DbHelper();

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
        List _notes = [];
        for (int i = 0; i < data!.length; i++) {
          _notes.add(Note.formString(data[i]));
        }

        setState(() => notes = _notes);
      });
    });
  }

  void remove(int id, context) {
    dbHelper.remove(id);

    setState(() => notes);

    FToast fToast = FToast();
    fToast.init(context);

    fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.red[400],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.delete_forever_rounded, color: Colors.white),
            SizedBox(width: 12.0),
            Text(
              "Note Deleted",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    getNotes();
    return Scaffold(
      appBar: AppBar(title: const Text('Notebook'), centerTitle: true),
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
                leading: notes[index].photo == null
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
