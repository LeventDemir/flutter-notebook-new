import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notebook/screens/create-note.dart';
import 'package:notebook/screens/home.dart';
import 'package:notebook/screens/update-note.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.indigo,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: 'Home',
      routes: {
        'Home': (context) => const Home(),
        'CreateNote': (context) => const CreateNote(),
        'UpdateNote': (context) => const UpdateNote()
      },
    );
  }
}
