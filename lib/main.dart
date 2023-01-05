import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notebook/screens/create-note.dart';
import 'package:notebook/screens/home.dart';
import 'package:notebook/screens/update-note.dart';
import 'package:notebook/store/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => ThemeProvider())],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeMode theme = Provider.of<ThemeProvider>(context).themeMode;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(systemNavigationBarColor: Colors.indigo.shade700),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: theme,
      theme: ThemeData(primarySwatch: Colors.indigo),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(backgroundColor: Colors.indigo.shade700),
        colorSchemeSeed: Colors.indigo,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.indigo,
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
