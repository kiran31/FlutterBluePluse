import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceConnectionPage extends StatefulWidget {
  @override
  _DeviceConnectionPageState createState() => _DeviceConnectionPageState();
}

class _DeviceConnectionPageState extends State<DeviceConnectionPage> {
  // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;

  @override
  void initState() {
    super.initState();
    autoReconnect();
    scanForDevices();
  }

  void scanForDevices() {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devicesList.contains(r.device)) {
          setState(() {
            devicesList.add(r.device);
          });
        }
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
      devicesList.clear(); // Clear list to show connected device only
    });
    saveLastConnectedDevice(device);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(device)),
    );
  }

  void disconnectFromDevice(BluetoothDevice device) async {
    await device.disconnect();
    setState(() {
      connectedDevice = null;
    });
    removeLastConnectedDevice();
  }

  Future<void> saveLastConnectedDevice(BluetoothDevice device) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_device_id', device.id.toString());
  }

  Future<void> removeLastConnectedDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_device_id');
  }

  Future<void> autoReconnect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastDeviceId = prefs.getString('last_device_id');

    if (lastDeviceId != null) {
      List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
      for (BluetoothDevice device in connectedDevices) {
        if (device.id.toString() == lastDeviceId) {
          connectToDevice(device);
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connect to Device')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: scanForDevices,
            child: Text('Scan for Devices'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: connectedDevice != null ? 1 : devicesList.length,
              itemBuilder: (context, index) {
                BluetoothDevice device = connectedDevice ?? devicesList[index];
                return ListTile(
                  title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
                  subtitle: Text(device.id.toString()),
                  trailing: connectedDevice != null
                      ? ElevatedButton(
                    onPressed: () => disconnectFromDevice(device),
                    child: Text('Disconnect'),
                  )
                      : ElevatedButton(
                    onPressed: () => connectToDevice(device),
                    child: Text('Connect'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
