

import 'package:jande/features/home.dart';
import 'package:jande/features/splashcreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

 void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? first_name = prefs.getString('first_name');
  runApp( MyApp(first_name:first_name));
}



class MyApp extends StatefulWidget {
  String? first_name;

  MyApp({Key? key, required this.first_name}):super(key:key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'jande',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: (widget.first_name != null && widget.first_name!.isNotEmpty)
          ? Home()
          : SplashScreen(),

    );
  }
}
