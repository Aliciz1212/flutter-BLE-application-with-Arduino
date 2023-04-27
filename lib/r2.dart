import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

BluetoothDevice? myDevice;
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
  late final TextEditingController position;
  int? info = null;
  String? light = null;
  List _services = [];
  BluetoothDevice? _connectedDevice = null;
  final _writeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    position = TextEditingController();
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

  @override
  void dispose() {
    position.dispose();

    super.dispose();
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

/////////BUILD LIST VIEW
  Widget _buildListViewOfDevices() {
    List<Container> containers = [];
    for (BluetoothDevice device in widget.devicesList) {
      if (device.name == 'myESP32') {
        print("qqqqq");
        myDevice = device;
        containers.add(
          Container(
            height: 100,
            child: Row(
              children: [
                Expanded(
                  child: Center(
                      child: Text(
                    device.name,
                    style: TextStyle(fontSize: 30, color: Colors.blue),
                  )),
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
      } else {
        return Center(
            child: SizedBox(
          child: CircularProgressIndicator(
            strokeWidth: 8,
          ),
          height: 200.0,
          width: 200.0,
        ));
      }
    }

    return Scaffold(
      body: Column(children: [...containers]),
    );
  }

  Widget _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  ListView _buildConnectDeviceView() {
    BluetoothCharacteristic c1 = _services[0].characteristics[0];
    BluetoothCharacteristic c2 = _services[0].characteristics[1];
    BluetoothCharacteristic c3 = _services[0].characteristics[2];
    final double w = 100;
    final double h = 40;
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              Text(
                null == light
                    ? "Choose a wavelength"
                    : ('Wavelength ' + light.toString()),
                style: TextStyle(fontSize: 30),
              ),
              Column(
                children: [
                  SizedBox(
                    height: h,
                    width: w,
                    child: ElevatedButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 7, 94, 255)),
                      child:
                          Text('400nm', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          light = "400";
                        });
                        c1.write(utf8.encode(light.toString()));
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: h,
                    width: w,
                    child: ElevatedButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 7, 94, 255)),
                      child:
                          Text('500nm', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          light = "500";
                        });
                        c1.write(utf8.encode(light.toString()));
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: h,
                    width: w,
                    child: ElevatedButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 7, 94, 255)),
                      child:
                          Text('600nm', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          light = "600";
                        });
                        c1.write(utf8.encode(light.toString()));
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: h,
                    width: w,
                    child: ElevatedButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 7, 94, 255)),
                      child:
                          Text('700nm', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          light = "700";
                        });
                        c1.write(utf8.encode(light.toString()));
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider()
                ],
              ),
            ],
          ),
        ),
        Column(
          children: [
            TextField(
              autocorrect: false,
              enableSuggestions: false,
              controller: position,
              decoration:
                  const InputDecoration(hintText: "Enter position here"),
            ),
            Row(
              children: [
                SizedBox(
                  height: h,
                  width: w,
                  child: TextButton(
                    onPressed: () {
                      final _position = position.text;

                      c3.write(utf8.encode(_position));
                    },
                    child: const Text("move"),
                  ),
                ),
                SizedBox(
                  child: ElevatedButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 7, 94, 255)),
                    child: Text('reset', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      c1.write(utf8.encode("reset"));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(children: [
            Row(
              children: [
                Text(
                  'Absorbance:    ' + (info == null ? "unmeasured" : "$info"),
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            Row(children: <Widget>[
              Center(
                child: ButtonTheme(
                  minWidth: 10,
                  height: 20,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 7, 94, 255)),
                      child: Text('Measure',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        c2.write([1]);
                        var value = await c2.read();
                        setState(
                          () {
                            widget.readValues[c2.uuid] = value;
                            info = value[0];
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ])
          ]),
        ),
        Divider(),
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
                style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 7, 94, 255)),
                child:
                    Text('Disconnect', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  await myDevice?.disconnect();

                  setState(() {
                    info = null;
                    _connectedDevice = null;
                    widget.flutterBlue.startScan();
                  });
                }),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("BLE UI"),
        ),
        body: _buildView(),
      );
}
