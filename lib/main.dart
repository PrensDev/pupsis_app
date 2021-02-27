import 'package:flutter/material.dart';

// Import Navs
import 'package:pupsis_app/navs/home.dart';
import 'package:pupsis_app/navs/student.dart';
import 'package:pupsis_app/navs/faculty.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PUP-SIS',
        color: Colors.red[700],
        theme: ThemeData(
          primaryColor: Colors.red[900],
          accentColor: Colors.redAccent[700],
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => Home(),
          '/student': (context) => Student(),
          '/faculty': (context) => Faculty(),
        },
      ),
    );
