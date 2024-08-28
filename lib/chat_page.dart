import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice device;

  ChatPage(this.device);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  BluetoothCharacteristic? chatCharacteristic;
  List<Map<String, String>> messages = [];
  TextEditingController controller = TextEditingController();
  String lastSentMessage = "";

  @override
  void initState() {
    super.initState();
    discoverServices();
  }
  Future<void> discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      service.characteristics.forEach((characteristic) {
        if (characteristic.properties.write && characteristic.properties.read) {
          setState(() {
            chatCharacteristic = characteristic;
          });
          chatCharacteristic?.setNotifyValue(true); // Enable notifications
          chatCharacteristic?.value.listen((value) { // Listen for incoming messages
            String receivedMessage = utf8.decode(value);
            if (receivedMessage != lastSentMessage) {
              setState(() {
                messages.add({'sender': widget.device.name, 'text': receivedMessage});
              });
            }
          });
        }
      });
    });
  }

/*
  Future<void> discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      service.characteristics.forEach((characteristic) {
        if (characteristic.properties.write && characteristic.properties.read) {
          setState(() {
            chatCharacteristic = characteristic;
          });
          chatCharacteristic?.setNotifyValue(true);
          chatCharacteristic?.value.listen((value) {
            String receivedMessage = utf8.decode(value);
            if (receivedMessage != lastSentMessage) {
              setState(() {
                messages.add({'sender': widget.device.name, 'text': receivedMessage});
              });
            }
          });
        }
      });
    });
  }
*/

  void sendMessage(String text) {
    if (chatCharacteristic != null && text.isNotEmpty) {
      chatCharacteristic?.write(utf8.encode(text));
      setState(() {
        messages.add({'sender': 'Me', 'text': text});
        lastSentMessage = text;
      });
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.device.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    messages[index]['text']!,
                    style: TextStyle(
                      color: messages[index]['sender'] == 'Me' ? Colors.blue : Colors.black,
                      fontWeight: messages[index]['sender'] == 'Me' ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: messages[index]['sender'] == 'Me' ? TextAlign.right : TextAlign.left,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: 'Enter message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => sendMessage(controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
