import 'package:flutter/material.dart';
import 'controller_page.dart';
import 'bt_connect.dart';
import 'package:flutter/services.dart'; // for portraitDown

void main() => runApp(Slider());

class Slider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Slider',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => BtConnect(),
        '/controller': (context) => ControllerPage(),
      },
    );
  }
}
