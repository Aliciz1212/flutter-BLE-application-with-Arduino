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
  ListView _buildListViewOfDevices() {
    List<Container> containers = [];
    for (BluetoothDevice device in widget.devicesList) {
      if (device.name == 'myESP32') {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 7, 94, 255),
                      shadowColor: Colors.grey,
                      elevation: 10,
                    ),
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
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromARGB(255, 7, 94, 255),
                width: 4.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Text(
                  null == light ? "請選擇波長" : ('波長 ' + light.toString() + " nm"),
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: h,
                      width: w,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 7, 94, 255),
                          shadowColor: Colors.grey,
                          elevation: 10,
                        ),
                        child: Text('400nm',
                            style: TextStyle(color: Colors.white)),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 7, 94, 255),
                          shadowColor: Colors.grey,
                          elevation: 10,
                        ),
                        child: Text('500nm',
                            style: TextStyle(color: Colors.white)),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 7, 94, 255),
                          shadowColor: Colors.grey,
                          elevation: 10,
                        ),
                        child: Text('600nm',
                            style: TextStyle(color: Colors.white)),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 7, 94, 255),
                          shadowColor: Colors.grey,
                          elevation: 10,
                        ),
                        child: Text('700nm',
                            style: TextStyle(color: Colors.white)),
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
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
              width: 4.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.fromARGB(255, 41, 41, 42),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  style: TextStyle(fontSize: 25,fontWeight:FontWeight.bold ),
                  autocorrect: false,
                  enableSuggestions: false,
                  controller: position,
                  decoration: const InputDecoration(hintText: "   輸入轉動位置"),
                ),
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  SizedBox(
                    height: h,
                    width: w,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 7, 255, 28),
                        shadowColor: Colors.grey,
                        elevation: 10,
                      ),
                      child: Text('移動',
                          style: TextStyle(color: Colors.black, fontSize: 23)),
                      onPressed: () {
                        final _position = position.text;

                        c3.write(utf8.encode(_position));
                      },
                    ),
                  ),
                  SizedBox(
                    width: w / 3,
                  ),
                  SizedBox(
                    height: h,
                    width: w,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 247, 7),
                        shadowColor: Colors.grey,
                        elevation: 10,
                      ),
                      child: Text('重置',
                          style: TextStyle(color: Colors.black, fontSize: 23)),
                      onPressed: () {
                        c1.write(utf8.encode("reset"));
                      },
                    ),
                  ),
                  
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 4.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(children: [
              Row(
                children: [
                  Row(
                    children: [
                      Text(
                        ('吸收率:   \n '),
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        (info == null ? "未測量" : "$info"),
                        style: TextStyle(fontSize: (info == null ? 40 : 80)),
                      ),
                      Text(
                        (info == null ? "" : "%"),
                        style: TextStyle(fontSize: 50),
                      ),
                    ],
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 7, 94, 255),
                          shadowColor: Colors.grey,
                          elevation: 10,
                        ),
                        child: Text('測量',
                            style:
                                TextStyle(color: Colors.white, fontSize: 23)),
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
        ),

        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 7, 94, 255),
                  shadowColor: Colors.grey,
                  elevation: 10,
                ),
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
