import 'package:flutter/material.dart';
import 'package:primerflutter/screens/FormularioEje1.dart';
import 'package:primerflutter/screens/FormularioEje2.dart';
import 'package:primerflutter/screens/columnas.dart';
import 'package:primerflutter/screens/gestos.dart';
import 'package:primerflutter/screens/pruebaG1.dart';
import 'package:primerflutter/screens/pruebaG2.dart';
import 'package:primerflutter/screens/pruebaG3.dart';
import 'package:primerflutter/screens/pruebaG5.dart';
import 'package:primerflutter/screens/pruebaG6.dart';
import 'package:primerflutter/screens/pruebaG4.dart';
import 'package:primerflutter/screens/pruebaG7.dart';

void main() => runApp(MiMaterialApp());

class MiMaterialApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
       //home: FormularioPage(),
       //home: FormularioPage2() ,
       //home: GestureHomeWidget2(),
       //home: TapGameWidget(),
      //home: DragGameWidget(),
     // home: StarTapGame(),
     // home: LongPressGame(),
      //home: DoubleTapGame(),
       home: DragShapesGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}