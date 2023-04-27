import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'BLE Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = [];
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _services = [];
  BluetoothDevice? _connectedDevice = null;
  final _writeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

/////////BUILD LIST VIEW
  ListView _buildListViewOfDevices() {
    List<Container> containers = [];
    for (BluetoothDevice device in widget.devicesList) {
      if (device.name == 'myESP32') {
        containers.add(
          Container(
            height: 100,
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child:Text(device.name,style: TextStyle(fontSize: 30,color: Colors.blue),)
                    
                  ),
                ),
                // Expanded(
                //   child: Column(
                //     children: [
                //       Expanded(
                //           child: Text(device.name == ''
                //               ? '(unknown device)'
                //               : device.name)),
                //       // Expanded(child: Text(device.id.toString())),
                //     ],
                //   ),
                // ),
                ElevatedButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 7, 94, 255)),
                    child: Text(
                      'Connect',
                      style:
                          TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                    onPressed: () async {
                      widget.flutterBlue.stopScan();
                      try {
                        await device.connect();
                      } on PlatformException catch (e) {
                        if (e.code != 'already_connected') {
                          throw e;
                        }
                      } finally {
                        _services = await device.discoverServices();
                      }
                      setState(() {
                        _connectedDevice = device;
                      });
                    }),
              ],
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        ...containers,
      ],
    );
  }

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  ListView _buildConnectDeviceView() {
    List<Container> containers = [];

    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = [];
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristic.value.listen((value) {
          print(value);
        });
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('Value: ' +
                        widget.readValues[characteristic.uuid].toString()),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(characteristic.uuid.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ..._buildReadWriteNotifyButton(characteristic),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        );
      }
      containers.add(
        Container(
          child: ExpansionTile(
              title: Text(service.uuid.toString()),
              children: characteristicsWidget),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = [];

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: TextButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 7, 94, 255)),
              child: Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  setState(() {
                    widget.readValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.read();
                sub.cancel();
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: TextButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 7, 94, 255)),
              child: Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Write"),
                        content: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _writeController,
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 7, 94, 255)),
                            child: Text("Send"),
                            onPressed: () {
                              characteristic.write(
                                  utf8.encode(_writeController.value.text));
                              Navigator.pop(context);
                            },
                          ),
                          ElevatedButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 7, 94, 255)),
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: TextButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 7, 94, 255)),
              child: Text('NOTIFY', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                characteristic.value.listen((value) {
                  widget.readValues[characteristic.uuid] = value;
                });
                await characteristic.setNotifyValue(true);
              },
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("BLE UI"),
        ),
        body: _buildView(),
      );
}
