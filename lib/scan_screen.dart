import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  List<BluetoothDevice> devicesList = [];

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() async {
    try {
      // Start the scan
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

      // Listen for scan results
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!devicesList.contains(result.device)) {
            setState(() {
              devicesList.add(result.device);
            });
          }
        }
      });
    } catch (e) {
      print('Error starting scan: $e');
    } finally {
      FlutterBluePlus.stopScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Devices'),
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devicesList[index].name.isNotEmpty
                ? devicesList[index].name
                : devicesList[index].id.toString()),
            onTap: () {
              // Handle device connection here
            },
          );
        },
      ),
    );
  }
}
