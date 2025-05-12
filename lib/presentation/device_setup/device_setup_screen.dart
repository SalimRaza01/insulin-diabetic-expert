import 'dart:async';
import 'package:INSUL/core/utils/hive_db_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:INSUL/presentation/screens/home_screen.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import '../../core/api/api_service.dart';
import '../../core/services/bluetooth_service_provider.dart';
import '../../core/utils/snackbar_utils.dart';

class DeviceSetupScreen extends StatefulWidget {
  const DeviceSetupScreen({Key? key, this.adapterState}) : super(key: key);

  final BluetoothAdapterState? adapterState;

  @override
  State<DeviceSetupScreen> createState() => _DeviceSetupScreenState();
}

class _DeviceSetupScreenState extends State<DeviceSetupScreen> {
  final _hivedb = HiveDbHelper();
  List<BluetoothService> _services = [];
  final BleManager _bleManager = BleManager();
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  bool status = false;
  bool gif = false;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;
  String finalString = 'cm+sync';
  String characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  bool connecting = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  late StreamSubscription<bool> _connectedDevicesSubscription;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  bool requestedForKey = false;


  @override
  void initState() {
    super.initState();

    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _adapterState = state;
      });
      if (state == BluetoothAdapterState.on) {
        onRefresh();
        print('toggle butoon ');
        setState(() {
          status = true;

          // _toggleBluetooth(status);
        });
      } else {
        print('bluetooth is off');
      }

      print("adopter State $state");
    });

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _scanResults = results;
        print('available devices $_scanResults');
      });

      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      setState(() {
        _isScanning = state;
      });
      if (mounted) {
        setState(() {});
      }
    });

  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  void onConnectPressed(BluetoothDevice device) async {
    setState(() {
      _bleManager.agvaDevice.value = device;
    });
    await _bleManager.connectToDevice(_bleManager.agvaDevice.value!);
    print('Connecting Device');
    _bleManager.discoverServices(device);
    setState(() {
      connecting = true;
    });

    _bleManager.isDeviceConnected.addListener(() {
      print('Connecting Device 2');

      if (_bleManager.isDeviceConnected.value == true) {
        print('Connecting Device 3 ${_bleManager.ackNotifier.value}');

        Future.delayed(Duration(seconds: 2),(){
          if (_bleManager.ackNotifier.value == true) {
          print('Connecting Device 5');
          deviceSetup(true, context);
          print('Connecting Device 6');
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
          _bleManager.ackNotifier.value = false;
          print('written code');
        } else {
          print('services are null');
          _bleManager.ackNotifier.value = false;
        }
        });
      } else {
        print('device is not connected ');
        setState(() {
          connecting = false;
          _bleManager.isDeviceConnected.value = false;
          _bleManager.agvaDevice.value = null;
        });
      }
    });
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(Duration(milliseconds: 500));
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map((r) => ScanResultTile(
              result: r,
              onTap: () {
                onConnectPressed(r.device);
              },
              requestedForKey: requestedForKey,
            ))
        .where((r) => r.result.device.platformName.contains('AgVa'))
        .toList();
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  void _toggleBluetooth(status) async {
    print('inside toggle button $status');
    if (status) {
      await FlutterBluePlus.turnOn();
    } else {
      await FlutterBluePlus.turnOff();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: status
          ? Theme.of(context).colorScheme.primary
          : Color.fromARGB(255, 31, 29, 87),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: <Color>[
          const Color.fromARGB(255, 14, 96, 164),
          const Color.fromARGB(255, 5, 53, 93)
        ])),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (_adapterState == BluetoothAdapterState.off)
                    Container(
                      height: 600,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bluetooth,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 120,
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Please turn on Bluetooth',
                                style: TextStyle(
                                    fontWeight: FontWeight.w200,
                                    fontSize: 20,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255)),
                              ),
                              FlutterSwitch(
                                inactiveColor: Colors.black,
                                height: 25.0,
                                width: 55.0,
                                padding: 4.0,
                                toggleSize: 15.0,
                                borderRadius: 20.0,
                                activeColor: Colors.black,
                                value: status,
                                onToggle: _toggleBluetooth,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 30,
                  ),
                  if (_adapterState == BluetoothAdapterState.on)
                    Column(
                      children: [
                        Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.bluetooth,
                                color: Theme.of(context).colorScheme.primary,
                                size: 60,
                              ),
                            ),
                            if (_isScanning)
                              RippleAnimation(
                                  color: Theme.of(context).colorScheme.primary,
                                  delay: Duration(milliseconds: 400),
                                  repeat: true,
                                  minRadius: 100,
                                  ripplesCount: 3,
                                  duration: Duration(milliseconds: 6 * 300),
                                  child: Container(
                                    height: 60,
                                  )),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        if (_isScanning)
                          Text(
                            connecting ? ' Connecting..' : 'Looking for ${_hivedb.getString('device_name')}',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        if (!_isScanning)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                connecting ? 'Connected' : 'Refresh',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              IconButton(
                                onPressed: () {
                                  onRefresh();
                                  setState(() {
                                    requestedForKey = false;
                                  });
                                },
                                icon: Icon(
                                  Icons.replay_circle_filled_sharp,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        if (_isScanning)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: LinearProgressIndicator(
                              minHeight: 2,
                              color: Color.fromARGB(255, 117, 186, 255),
                            ),
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Make sure your device is powered on and nearby.',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  if (_adapterState == BluetoothAdapterState.on)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: height * 0.7,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 248, 248, 248),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30))),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              if (status) ..._buildScanResultTiles(context),
                              SizedBox(
                                height: height * 0.04,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    gif = !gif;
                                  });
                                },
                                child: Text(
                                  'How to connect',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 12),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              if (gif)
                                Image.asset(
                                  'assets/images/Connection.gif',
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanResultTile extends StatefulWidget {
  const ScanResultTile(
      {Key? key,
      required this.result,
      this.onTap,
      required this.requestedForKey})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;
  final bool requestedForKey;

  @override
  State<ScanResultTile> createState() => _ScanResultTileState();
}

class _ScanResultTileState extends State<ScanResultTile> {
  late VoidCallback? onTap;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();
    print('inside scan result screen ');
    onTap = widget.onTap;

    _connectionStateSubscription =
        widget.result.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

//device here
  @override
  Widget build(BuildContext context) {
    var adv = widget.result.advertisementData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Devices",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            )),
        SizedBox(
          height: 15,
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 0.2,
              ),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.on_device_training_outlined),
                  SizedBox(
                    width: 20,
                  ),
                  if (!widget.requestedForKey)
                    Text(
                      widget.result.device.platformName,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  if (widget.requestedForKey)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.result.device.platformName,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Requesting for pairing key',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w300),
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// class DeviceScreen extends StatefulWidget {
//   final BluetoothDevice device;

//   const DeviceScreen({Key? key, required this.device}) : super(key: key);

//   @override
//   State<DeviceScreen> createState() => _DeviceScreenState();
// }

// class _DeviceScreenState extends State<DeviceScreen> {
//   int? _rssi;
//   int? _mtuSize;
//   BluetoothConnectionState _connectionState =
//       BluetoothConnectionState.disconnected;
//   List<BluetoothService> _services = [];
//   bool _isDiscoveringServices = false;
//   bool _isConnecting = false;
//   bool _isDisconnecting = false;

//   late StreamSubscription<BluetoothConnectionState>
//       _connectionStateSubscription;
//   late StreamSubscription<bool> _isConnectingSubscription;
//   late StreamSubscription<bool> _isDisconnectingSubscription;
//   late StreamSubscription<int> _mtuSubscription;

//   @override
//   void initState() {
//     super.initState();
//     print('inside device screen ');
//     Timer(Duration(seconds: 2), onDiscoverServicesPressed);
//     _connectionStateSubscription =
//         widget.device.connectionState.listen((state) async {
//       _connectionState = state;
//       if (state == BluetoothConnectionState.connected) {
//         _services = []; // must rediscover services
//       }
//       if (state == BluetoothConnectionState.connected && _rssi == null) {
//         _rssi = await widget.device.readRssi();
//       }
//       if (mounted) {
//         setState(() {});
//       }
//     });

//     _mtuSubscription = widget.device.mtu.listen((value) {
//       _mtuSize = value;
//       if (mounted) {
//         setState(() {});
//       }
//     });

//     _isConnectingSubscription = widget.device.isConnecting.listen((value) {
//       _isConnecting = value;
//       if (mounted) {
//         setState(() {});
//       }
//     });

//     _isDisconnectingSubscription =
//         widget.device.isDisconnecting.listen((value) {
//       _isDisconnecting = value;
//       if (mounted) {
//         setState(() {});
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _connectionStateSubscription.cancel();
//     _mtuSubscription.cancel();
//     _isConnectingSubscription.cancel();
//     _isDisconnectingSubscription.cancel();
//     super.dispose();
//   }

//   bool get isConnected {
//     return _connectionState == BluetoothConnectionState.connected;
//   }

//   Future onConnectPressed() async {
//     try {
//       await widget.device.connectAndUpdateStream();
//       onDiscoverServicesPressed();
//       Snackbar.show(ABC.c, "Connect: Success", success: true);
//     } catch (e) {
//       if (e is FlutterBluePlusException &&
//           e.code == FbpErrorCode.connectionCanceled.index) {
//         // ignore connections canceled by the user
//       } else {
//         Snackbar.show(ABC.c, prettyException("Connect Error:", e),
//             success: false);
//       }
//     }
//   }

//   Future onCancelPressed() async {
//     try {
//       await widget.device.disconnectAndUpdateStream(queue: false);
//       Snackbar.show(ABC.c, "Cancel: Success", success: true);
//     } catch (e) {
//       Snackbar.show(ABC.c, prettyException("Cancel Error:", e), success: false);
//     }
//   }

//   Future onDisconnectPressed() async {
//     try {
//       await widget.device.disconnectAndUpdateStream();
//       Snackbar.show(ABC.c, "Disconnect: Success", success: true);
//     } catch (e) {
//       Snackbar.show(ABC.c, prettyException("Disconnect Error:", e),
//           success: false);
//     }
//   }

//   Future onDiscoverServicesPressed() async {
//     if (mounted) {
//       setState(() {
//         _isDiscoveringServices = true;
//       });
//     }
//     try {
//       _services = await widget.device.discoverServices();
//       Snackbar.show(ABC.c, "Discover Services: Success", success: true);
//     } catch (e) {
//       Snackbar.show(ABC.c, prettyException("Discover Services Error:", e),
//           success: false);
//     }
//     if (mounted) {
//       setState(() {
//         _isDiscoveringServices = false;
//       });
//     }
//   }

//   Future onRequestMtuPressed() async {
//     try {
//       await widget.device.requestMtu(223, predelay: 0);
//       Snackbar.show(ABC.c, "Request Mtu: Success", success: true);
//     } catch (e) {
//       Snackbar.show(ABC.c, prettyException("Change Mtu Error:", e),
//           success: false);
//     }
//   }

//   List<Widget> _buildServiceTiles(BuildContext context, BluetoothDevice d) {
//     return _services
//         .map(
//           (s) => ServiceTile(
//             service: s,
//             characteristicTiles: s.characteristics
//                 .map((c) => _buildCharacteristicTile(c))
//                 .toList(),
//           ),
//         )
//         .toList();
//   }

//   CharacteristicTile _buildCharacteristicTile(BluetoothCharacteristic c) {
//     return CharacteristicTile(
//       characteristic: c,
//     );
//   }

//   Widget buildSpinner(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(14.0),
//       child: AspectRatio(
//         aspectRatio: 1.0,
//         child: CircularProgressIndicator(
//           backgroundColor: Colors.black12,
//           color: Colors.black26,
//         ),
//       ),
//     );
//   }

//   Widget buildRemoteId(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text('${widget.device.remoteId}'),
//     );
//   }

//   Widget buildRssiTile(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         isConnected
//             ? const Icon(Icons.bluetooth_connected)
//             : const Icon(Icons.bluetooth_disabled),
//         Text(((isConnected && _rssi != null) ? '${_rssi!} dBm' : ''),
//             style: Theme.of(context).textTheme.bodySmall)
//       ],
//     );
//   }

//   Widget buildGetServices(BuildContext context) {
//     return IndexedStack(
//       index: (_isDiscoveringServices) ? 1 : 0,
//       children: <Widget>[
//         TextButton(
//           child: const Text("Get Services"),
//           onPressed: onDiscoverServicesPressed,
//         ),
//       ],
//     );
//   }

//   Widget buildMtuTile(BuildContext context) {
//     return ListTile(
//         title: const Text('MTU Size'),
//         subtitle: Text('$_mtuSize bytes'),
//         trailing: IconButton(
//           icon: const Icon(Icons.edit),
//           onPressed: onRequestMtuPressed,
//         ));
//   }

//   Widget buildConnectButton(BuildContext context) {
//     return Row(children: [
//       if (_isConnecting || _isDisconnecting) buildSpinner(context),
//       TextButton(
//           onPressed: _isConnecting
//               ? onCancelPressed
//               : (isConnected ? onDisconnectPressed : onConnectPressed),
//           child: Text(
//             _isConnecting ? "CANCEL" : (isConnected ? "DISCONNECT" : "CONNECT"),
//             style: Theme.of(context)
//                 .primaryTextTheme
//                 .labelLarge
//                 ?.copyWith(color: Colors.black),
//           ))
//     ]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScaffoldMessenger(
//       key: Snackbar.snackBarKeyC,
//       child: Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           title: Text(widget.device.platformName),
//           actions: [
//             buildConnectButton(context),
//           ],
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//               buildRemoteId(context),
//               ListTile(
//                 leading: buildRssiTile(context),
//                 title: Text(
//                     'Device is ${_connectionState.toString().split('.')[1]}.'),
//                 // trailing: buildGetServices(context),
//               ),
//               buildMtuTile(context),
//               ..._buildServiceTiles(context, widget.device),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CharacteristicTile extends StatefulWidget {
//   final BluetoothCharacteristic characteristic;

//   const CharacteristicTile({Key? key, required this.characteristic})
//       : super(key: key);

//   @override
//   State<CharacteristicTile> createState() => _CharacteristicTileState();
// }

// class _CharacteristicTileState extends State<CharacteristicTile> {
//   TextEditingController inpuValueController = TextEditingController();

//   List<int> _value = [];
//   String ecn = '';

//   late StreamSubscription<List<int>> _lastValueSubscription;

//   @override
//   void initState() {
//     super.initState();
//     print('inside char tile screen ');

//     _lastValueSubscription =
//         widget.characteristic.lastValueStream.listen((value) {
//       _value = value;
//       if (mounted) {
//         setState(() {});
//       }
//     });
//   }

//   @override
//   void dispose() {
//     onListen();
//     _lastValueSubscription.cancel();
//     super.dispose();
//   }

//   BluetoothCharacteristic get c => widget.characteristic;

//   Future<void> onListenPressed() async {
//     try {
//       while (true) {
//         // Log to verify the loop is running
//         print("Waiting for 2 seconds...");
//         await Future.delayed(const Duration(seconds: 2));
//         print("Calling onListen...");

//         await onListen();
//       }
//     } catch (e) {
//       print("Error in onListenPressed: $e");
//     }
//   }

//   Future<void> onListen() async {
//     try {
//       print("onListen called");
//       var enco = await c.read();

//       if (enco.isNotEmpty) {
//         String decodedData = utf8.decode(enco);
//         print("CHECK DATA RECEIVED HERE $decodedData");
//         ecn = decodedData;
//         var finalString = ecn.substring(2, ecn.length - 1);
//         var abc = finalString.split(",");
//         print("LISTING OF VALUES ${abc.toList()}");
//         print("HERE FINAL STRING IS ${finalString}");
//         buildbleValu(context, inpuValueController.text, finalString);
//         print('Decoded data: $ecn');

//         // Filter integer values
//         RegExp exp = RegExp(r'\d+');
//         Iterable<Match> matches = exp.allMatches(ecn);
//         List<int> numbers = matches.map((m) => int.parse(m.group(0)!)).toList();
//         var a = numbers[0];
//         var b = numbers[1];
//         var c = numbers[2];
//         var d = numbers[3];
//         var e = numbers[4];
//         print(a);
//         print(b);
//         print(c);
//         print(d);
//         print(e);
//         print('Filtered integers: $numbers');
//       } else {
//         print("No data received");
//       }
//     } catch (e) {
//       // print("Error in onListen: $e");
//     }
//   }

//   // Future onWritePressed(String text) async {
//   //   try {
//   //     await c.write(utf8.encode(text),
//   //         withoutResponse: false);
//   //     Snackbar.show(ABC.c, "Write: Success", success: true);
//   //     if (c.properties.read) {
//   //       await c.read();
//   //     }
//   //   } catch (e) {
//   //     Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
//   //   }
//   // }

//   Future onWritePressed(String text) async {
//     const int chunkSize = 20; // Max data length for BLE characteristic write

//     // Convert the text to UTF-8 encoded bytes
//     Uint8List data = Uint8List.fromList(utf8.encode(text));

//     try {
//       for (int offset = 0; offset < data.length; offset += chunkSize) {
//         // Calculate the end index of the current chunk
//         int end = (offset + chunkSize < data.length)
//             ? offset + chunkSize
//             : data.length;

//         // Extract the chunk from the data
//         Uint8List chunk = data.sublist(offset, end);

//         // Write the chunk to the characteristic
//         await c.write(chunk, withoutResponse: false);

//         // Optionally, add a delay to ensure smooth transmission
//         await Future.delayed(Duration(milliseconds: 100));
//       }

//       Snackbar.show(ABC.c, "Write: Success", success: true);

//       if (c.properties.read) {
//         await c.read();
//       }
//     } catch (e) {
//       Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
//     }
//   }

//   Future onSubscribePressed() async {
//     try {
//       String op = c.isNotifying == false ? "Subscribe" : "Unubscribe";
//       await c.setNotifyValue(c.isNotifying == false);
//       Snackbar.show(ABC.c, "$op : Success", success: true);
//       if (c.properties.read) {
//         await c.read();
//       }
//       if (mounted) {
//         setState(() {});
//       }
//     } catch (e) {
//       Snackbar.show(ABC.c, prettyException("Subscribe Error:", e),
//           success: false);
//     }
//   }

//   Widget buildUuid(BuildContext context) {
//     String uuid = '0x${widget.characteristic.uuid.str.toUpperCase()}';
//     return Text(uuid, style: TextStyle(fontSize: 13));
//   }

//   Widget buildValue(BuildContext context) {
//     String data = _value.toString();
//     return Text(data, style: TextStyle(fontSize: 13, color: Colors.grey));
//   }

//   Widget buildbleValu(BuildContext context, text, enco) {
//     print('this is enco $enco');

//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Sent Value : ',
//                   style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold)),
//               Text(text,
//                   style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold)),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Received Value : ',
//                   style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold)),
//               Text(enco,
//                   style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildSubscribeButton(BuildContext context) {
//     bool isNotifying = widget.characteristic.isNotifying;
//     return TextButton(
//         child: Text(isNotifying ? "Unsubscribe" : "Subscribe"),
//         onPressed: () async {
//           await onSubscribePressed();
//           if (mounted) {
//             setState(() {});
//           }
//         });
//   }

//   Widget buildButtonRow(BuildContext context) {
//     bool notify = widget.characteristic.properties.notify;
//     bool indicate = widget.characteristic.properties.indicate;
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         ElevatedButton(
//             onPressed: () {
//               print('this is write button');
//               setState(() {
//                 showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: TextField(
//                         controller: inpuValueController,
//                         textAlign: TextAlign.center,
//                         decoration: InputDecoration(
//                             // border: InputBorder.none,
//                             hintStyle: TextStyle(
//                           color: Theme.of(context).colorScheme.secondary,
//                         )),
//                       ),
//                       actions: [
//                         ElevatedButton(
//                             onPressed: () {
//                               onWritePressed(inpuValueController.text);
//                               Navigator.pop(context);
//                             },
//                             child: Text('Write'))
//                       ],
//                     );
//                   },
//                 );
//               });
//             },
//             child: Text(
//               "Input",
//             )),
//         if (notify || indicate) buildSubscribeButton(context),
//         ElevatedButton(
//             onPressed: () {
//               onListenPressed();
//             },
//             child: Text(
//               "Listen",
//             ))
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       title: ListTile(
//         title: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             const Text('Characteristic'),
//             buildUuid(context),
//             // buildValue(context),
//             buildbleValu(context, inpuValueController.text, ecn),
//           ],
//         ),
//         subtitle: buildButtonRow(context),
//         contentPadding: const EdgeInsets.all(0.0),
//       ),
//     );
//   }
// }

// class ServiceTile extends StatelessWidget {
//   final BluetoothService service;
//   final List<CharacteristicTile> characteristicTiles;

//   const ServiceTile(
//       {Key? key, required this.service, required this.characteristicTiles})
//       : super(key: key);

//   Widget buildUuid(BuildContext context) {
//     String uuid = '0x${service.uuid.str.toUpperCase()}';
//     return Text(uuid, style: TextStyle(fontSize: 13));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return characteristicTiles.isNotEmpty
//         ? ExpansionTile(
//             title: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 const Text('Service', style: TextStyle(color: Colors.blue)),
//                 buildUuid(context),
//               ],
//             ),
//             children: characteristicTiles,
//           )
//         : ListTile(
//             title: const Text('Service'),
//             subtitle: buildUuid(context),
//           );
//   }
// }
