import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF0B1957),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0B1957),
          titleTextStyle: TextStyle(
            color: Color(0xFFF8F3EA),
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(color: Color(0xFFF8F3EA)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFA9EBC),
            foregroundColor: Color(0xFF0B1957),
          ),
        ),
        listTileTheme: ListTileThemeData(
          titleTextStyle: TextStyle(color: Color(0xFFF8F3EA), fontSize: 16),
          subtitleTextStyle: TextStyle(color: Color(0xFFFFDBD1)),
        ),
        iconTheme: IconThemeData(color: Color(0xFFF8F3EA)),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFF8F3EA)),
          bodySmall: TextStyle(color: Color(0xFFFFDBD1)),
        ),
      ),
      home: MyHomePage(),
    );
  }
}







