import 'package:flutter/material.dart';
import 'package:primerflutter/screens/gestos.dart';

void main() => runApp(MiMaterialApp());

class MiMaterialApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      

      home: GestureHomeWidget(),

      debugShowCheckedModeBanner: false,
    );
  }
}