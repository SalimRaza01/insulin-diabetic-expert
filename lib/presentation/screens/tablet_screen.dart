// ignore_for_file: file_names, prefer_const_literals_to_create_immutables, unnecessary_new

import 'dart:async';
import 'package:INSUL/data/providers/device_provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../core/services/bluetooth_service_provider.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

final _hivedb = HiveDbHelper();

class HomeScreenTablet extends StatefulWidget {
  HomeScreenTablet({super.key});

  @override
  _HomeScreenTabletState createState() => _HomeScreenTabletState();
}

class _HomeScreenTabletState extends State<HomeScreenTablet> {
  final BleManager _bleManager = BleManager();
  bool isQRScanning = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      _startScanner();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Camera permission is required to scan QR codes.')),
      );
    }
  }

  void _startScanner() {
    setState(() => isQRScanning = true);
  }

  void _stopScanner() {
    setState(() => isQRScanning = false);
  }

  void _onQRDetected(Barcode barcode, BuildContext context) async {
    final deviceName = barcode.rawValue;

    if (deviceName == 'INSUL') {
      _hivedb.putString('device_name', deviceName!);
      Provider.of<DeviceProvider>(context, listen: false)
          .updateDeviceName(deviceName);
      _stopScanner();

      await Future.delayed(const Duration(seconds: 2));
      _bleManager.initializeBluetoothListeners();
      // Navigator.of(context).pop();
      // BleManager().startScanIfNotScanning();
    }
  }

  @override
  void dispose() {
//unused code as per new condition

    super.dispose();
  }

  String _topModalData = "";
  String _deviceStatus = "";

  void _notifyUserweight(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          duration: Duration(milliseconds: 600),
          backgroundColor: Colors.blue,
          content: Center(
              child: Text(
            message,
            style: TextStyle(fontSize: 17),
          ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return ValueListenableBuilder(
      valueListenable: _bleManager.isScanningRunning,
      builder: (context, isScanning, _) {
        print('is scanning in homescreen $isScanning');
        return ValueListenableBuilder(
          valueListenable: _bleManager.isDeviceConnected,
          builder: (context, isConnected, _) {
            return ValueListenableBuilder(
              valueListenable: _bleManager.agvaDevice,
              builder: (context, agvaDevice, _) {
                print('Started Listening 4 ${_bleManager.agvaDevice.value}');
                return ValueListenableBuilder(
                    valueListenable: _bleManager.adapterState,
                    builder: (context, adapterState, _) {
                      return Scaffold(
                        backgroundColor: Colors.white,
                        body: Stack(
                          children: [
                            Image.asset('assets/images/tablet.png'),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 100, top: 65),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                          // onTap: () => context.go('/tutorial'),
                                          child: Icon(
                                        CupertinoIcons.info_circle,
                                        color: Colors.white,
                                      )),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      InkWell(
                                          onTap: () async {
                                            await _requestCameraPermission();
                                            // _bleManager.initializeBluetoothListeners();
                                          },
                                          child: Icon(
                                            CupertinoIcons.barcode_viewfinder,
                                            color: Colors.white,
                                          )),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      isScanning
                                          ? Image.asset(
                                              'assets/images/BLESCAN3.gif',
                                              height: 25,
                                            )
                                          : Icon(
                                              isConnected
                                                  ? CupertinoIcons
                                                      .rectangle_badge_checkmark
                                                  : CupertinoIcons
                                                      .rectangle_badge_xmark,
                                              color: isConnected
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      GestureDetector(
                                          child: Icon(
                                        CupertinoIcons.bell_fill,
                                        color: Colors.white,
                                      )),
                                      SizedBox(
                                        width: 20,
                                      )
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => isConnected
                                      ? _bleManager.forgetDevice(agvaDevice)
                                      : null,
                                  child: AnimatedContainer(
                                    duration: Duration(seconds: 1),
                                    height: isConnected ? height * 0.078 : 0.0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 200, right: 90, top: 40),
                                      child: Container(
                                        width: width,
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                              child: Text(
                                                  'ESP CONNECTED  (Tap to Disconnect)')),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (isQRScanning)
                              Positioned.fill(
                                child: MobileScanner(
                                  controller: MobileScannerController(
                                      cameraResolution: Size(4160, 3120)),
                                  onDetect: (capture) {
                                    for (final barcode in capture.barcodes) {
                                      _onQRDetected(barcode, context);
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    });
              },
            );
          },
        );
      },
    );
  }
}
