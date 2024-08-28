import 'package:ble_chat/connection_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DeviceConnectionPage(),
    );
  }
}
