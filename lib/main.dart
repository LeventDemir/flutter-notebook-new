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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).brightness.name == 'light'
            ? Colors.indigo
            : Colors.indigo.shade900,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(backgroundColor: Colors.indigo.shade900),
        colorSchemeSeed: Colors.indigo,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo.shade900,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: 'Home',
      routes: {
        'Home': (context) => const Home(),
        'CreateNote': (context) => const CreateNote(),
        'UpdateNote': (context) => const UpdateNote()
      },
    );
  }
}
