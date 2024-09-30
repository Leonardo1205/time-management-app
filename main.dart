import 'package:flutter/material.dart';
import 'screens/tela_login.dart';

void main() => runApp(TimeManagementApp());

class TimeManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Tempo',
      theme: ThemeData(
        primaryColor: Color(0xFF1c0b2b),
        scaffoldBackgroundColor: Color(0xFF301c41),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF5c65c0),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
