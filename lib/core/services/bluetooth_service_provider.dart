import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:INSUL/core/constants/ble_device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

final _hivedb = HiveDbHelper();

class BleManager extends ChangeNotifier {
  ValueNotifier<bool> ackNotifier = ValueNotifier(false);
  ValueNotifier<BluetoothDevice?> agvaDevice = ValueNotifier(null);
  ValueNotifier<bool> isScanningRunning = ValueNotifier(false);
  ValueNotifier<bool> isDeviceConnected = ValueNotifier(false);
  ValueNotifier<BluetoothAdapterState> adapterState =
      ValueNotifier(BluetoothAdapterState.unknown);

  // :white_tick: AES KEY and IV
  final aesKey = encrypt.Key(Uint8List.fromList([
    0x60,
    0x3d,
    0xeb,
    0x10,
    0x15,
    0xca,
    0x71,
    0xbe,
    0x2b,
    0x73,
    0xae,
    0xf0,
    0x85,
    0x7d,
    0x77,
    0x81
  ]));

  final aesIV = encrypt.IV(Uint8List.fromList([
    0xa0,
    0x88,
    0x23,
    0x2a,
    0xfa,
    0x54,
    0xa3,
    0x6c,
    0xfe,
    0x2c,
    0x39,
    0x76,
    0x17,
    0xb1,
    0x39,
    0x05
  ]));


  static final BleManager _instance = BleManager._internal();

  factory BleManager() => _instance;

  BleManager._internal();

  List<BluetoothService>? _services = [];

  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningStream;

  void initializeBluetoothListeners() {
    FlutterBluePlus.adapterState.listen((state) {
      adapterState.value = state;
      if (state == BluetoothAdapterState.on) {
        startScanIfNotScanning();
        print('[BLE] Bluetooth is on. Starting scan...');
      }
    });
  }

  Future<void> requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (statuses.values.any((status) => !status.isGranted)) {
      print('[BLE] Required permissions not granted.');
    }
  }

  void startScanIfNotScanning() async {
    await requestPermissions();

    if (!isScanningRunning.value && !isDeviceConnected.value) {
      FlutterBluePlus.startScan(timeout: Duration(seconds: 3));

      _isScanningStream = FlutterBluePlus.isScanning.listen((state) {
        isScanningRunning.value = state;
        notifyListeners();
      });

      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        _processScanResults(results);
      });
    }
  }

  void _processScanResults(List<ScanResult> results) async {
    for (ScanResult result in results) {
      if (result.device.platformName == await _hivedb.getString('device_name')) {
      // if (result.device.platformName == 'INSUL-AGVA') {
        print('[BLE] Found matching device: ${result.device.platformName}');
        connectToDevice(result.device);
        FlutterBluePlus.stopScan();
        isScanningRunning.value = false;
        notifyListeners();
        return;
      }
    }
  }

  Future<void> getBondedDevices() async {
    try {
      List<BluetoothDevice> bondedDevices = await FlutterBluePlus.bondedDevices;
      print(
          '[BLE] Bonded Devices: ${bondedDevices.map((e) => e.platformName).toList()}');
    } catch (e) {
      print('[BLE] Failed to fetch bonded devices: $e');
    }
  }

  Future<void> connectToDevice(BluetoothDevice? device) async {
    if (device == null) return;

    try {
      await device.connect();

      final bondState = await device.bondState.first;
      if (bondState != BluetoothBondState.bonded) {
        print("[BLE] Creating bond with ${device.platformName}...");

        await device.createBond(); 

      } else {
        print("[BLE] Bonding Already Done with ${device.platformName}...");
      }

      agvaDevice.value = device;
      notifyListeners();

      await discoverServices(device);
      startConnectionCheckTimer(device);
    } catch (e) {
      print('[BLE] Connection failed: $e');
    }
  }

  void disconnectDevice(BluetoothDevice? device) async {
    if (device == null) return;
    try {
      await device.disconnect();
      agvaDevice.value = null;
      isDeviceConnected.value = false;
      notifyListeners();
      startScanIfNotScanning();
    } catch (e) {
      print('[BLE] Disconnection failed: $e');
    }
  }

  Future<void> forgetDevice(BluetoothDevice? device) async {
    if (device == null) return;
    try {
      await device.disconnect();
      await device.removeBond();
      agvaDevice.value = null;
      isDeviceConnected.value = false;
      notifyListeners();
      print('[BLE] Disconnected and forgot device: ${device.platformName}');
      startScanIfNotScanning();
    } catch (e) {
      print('[BLE] Failed to forget device: $e');
    }
  }

  void startConnectionCheckTimer(BluetoothDevice device) {
    Timer.periodic(Duration(seconds: 2), (timer) async {
      try {
        var state = await device.connectionState.first;
        if (state == BluetoothConnectionState.disconnected) {
          isDeviceConnected.value = false;
          agvaDevice.value = null;
          notifyListeners();
          timer.cancel();
          startScanIfNotScanning();
        }
      } catch (e) {
        print('[BLE] Connection check failed: $e');
      }
    });
  }

  Future<void> discoverServices(BluetoothDevice device) async {
    try {
      _services = await device.discoverServices();
      if (_services != null) {
        isDeviceConnected.value = true;
        _hivedb.putBool('DeviceSetup', true);
        notifyListeners();

        readOrWriteCharacteristic(BleDeviceInfo.characteristicUuid, BleDeviceInfo.connectionCMD, true);
      }
    } catch (e) {
      print('[BLE] Service discovery failed: $e');
    }
  }

  

  Future<void> readOrWriteCharacteristic(
      String characteristicUuid, String text, bool isRead) async {



        
    try {
      BluetoothCharacteristic? characteristic =
          findCharacteristic(characteristicUuid);
      print('[BLE] Writing ');
      if (characteristic != null) {
        print('[BLE] Writing without encode $text');
        await characteristic.write(utf8.encode(text), withoutResponse: false);
           print('[BLE] Writing without encode ${utf8.encode(text)}');
        if (isRead) {
          print('[BLE] Writing 3');
          var data = await characteristic.read();

          print('[BLE] Writing 4 ${utf8.decode(data)}');
          // decryptBLEData(data);

          //          final hexString = utf8.decode(data).replaceAll(" ", "").trim();
          // print("Encrypted HEX string: $hexString");

          // final encryptedBytes = <int>[];
          // for (int i = 0; i < hexString.length; i += 2) {
          //   encryptedBytes.add(int.parse(hexString.substring(i, i + 2), radix: 16));
          // }
          // final encryptedData = Uint8List.fromList(encryptedBytes);
          // final encrypter = encrypt.Encrypter(encrypt.AES(aesKey, mode: encrypt.AESMode.cbc));
          // final decrypted = encrypter.decrypt(encrypt.Encrypted(encryptedData), iv: aesIV);
          // print(":unlock: Decrypted Data: $decrypted");
          //for non encrypted data
          // var dataDecoded = utf8.decode(data);
          // print('[BLE] Data received: $dataDecoded');



          //for encrypted data
          // final decryptedData = AesDecryptor.decrypt(Uint8List.fromList(data));
          // print('[BLE] Decrypted: $decryptedData');

//     final data = Uint8List.fromList(decryptedData);
//     final buffer = ByteData.sublistView(data);
//     final timestamp = buffer.getUint32(0, Endian.big);
          // print('[BLE] Timestamp: $timestamp');

          // ackNotifier.value = dataDecoded.contains('ACK');
          notifyListeners();
        }
      }
    } catch (e) {
      print('[BLE] Error reading/writing characteristic: $e');
    }
  }

// void decryptBLEData(List<int> bleData) {
//   // Step 1: Decode space-separated hex bytes
//   final hexString = utf8.decode(bleData).replaceAll(" ", "").trim();
//   print("Encrypted HEX string: $hexString");

//   // Step 2: Convert hex string to byte list
//   final encryptedBytes = <int>[];
//   for (int i = 0; i < hexString.length; i += 2) {
//     encryptedBytes.add(int.parse(hexString.substring(i, i + 2), radix: 16));
//   }

//   final encryptedData = encrypt.Encrypted(Uint8List.fromList(encryptedBytes));

//   // Step 3: AES key & IV (must match encryption)
//   final aesKey = encrypt.Key(Uint8List.fromList([
//     0x60, 0x3d, 0xeb, 0x10, 0x15, 0xca, 0x71, 0xbe,
//     0x2b, 0x73, 0xae, 0xf0, 0x85, 0x7d, 0x77, 0x81
//   ]));

//   final aesIV = encrypt.IV(Uint8List.fromList([
//     0xa0, 0x88, 0x23, 0x2a, 0xfa, 0x54, 0xa3, 0x6c,
//     0xfe, 0x2c, 0x39, 0x76, 0x17, 0xb1, 0x39, 0x05
//   ]));

//   // Step 4: Decrypt
//   final encrypter = encrypt.Encrypter(
//     encrypt.AES(aesKey, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
//   );

//   try {
//     final decrypted = encrypter.decrypt(encryptedData, iv: aesIV);
//     print("🔓 Decrypted (UTF-8): $decrypted");
//   } catch (e) {
//     print("⚠️ Decryption error: $e");
//     print("Maybe the result is binary, not a UTF-8 string.");

//     // Fallback: Print raw bytes
//     final raw = encrypter.decryptBytes(encryptedData, iv: aesIV);
//     print("📦 Decrypted Bytes: $raw");
//   }
// }

  void decryptBLEData(List<int> bleData) {
    final hexString = utf8.decode(bleData).replaceAll(" ", "").trim();

    final encryptedBytes = <int>[];
    for (int i = 0; i < hexString.length; i += 2) {
      encryptedBytes.add(int.parse(hexString.substring(i, i + 2), radix: 16));
    }

    final aesKey = encrypt.Key(Uint8List.fromList([
      0x60,
      0x3d,
      0xeb,
      0x10,
      0x15,
      0xca,
      0x71,
      0xbe,
      0x2b,
      0x73,
      0xae,
      0xf0,
      0x85,
      0x7d,
      0x77,
      0x81
    ]));

    final aesIV = encrypt.IV(Uint8List.fromList([
      0xa0,
      0x88,
      0x23,
      0x2a,
      0xfa,
      0x54,
      0xa3,
      0x6c,
      0xfe,
      0x2c,
      0x39,
      0x76,
      0x17,
      0xb1,
      0x39,
      0x05
    ]));

    final encrypter = encrypt.Encrypter(
      encrypt.AES(aesKey, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );

    try {
      final decryptedBytes = encrypter.decryptBytes(
        encrypt.Encrypted(Uint8List.fromList(encryptedBytes)),
        iv: aesIV,
      );
      print(":package: Decrypted Bytes: $decryptedBytes");
      final data = Uint8List.fromList(decryptedBytes);
      int offset = 0;

      int getUint32() =>
          (data[offset++] << 24) |
          (data[offset++] << 16) |
          (data[offset++] << 8) |
          data[offset++];

      int getUint8() => data[offset++];

      final timestamp = getUint32();
      final batteryHealth = getUint8();
      final batteryPercent = getUint8();
      final bolusCount = getUint8();
      final bolus1Time = getUint32();
      final bolus1Units = getUint8();
      final bolus2Time = getUint32();
      final bolus2Units = getUint8();

      print(":clock3: Timestamp: ${DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)}");
      print(":battery: Battery Health: $batteryHealth%");
      print(":battery: Battery Percent: $batteryPercent%");
      print(":syringe: Bolus Count: $bolusCount");
      print(":syringe: Bolus 1 - Time: ${DateTime.fromMillisecondsSinceEpoch(bolus1Time * 1000)}, Units: $bolus1Units");
      print(":syringe: Bolus 2 - Time: ${DateTime.fromMillisecondsSinceEpoch(bolus2Time * 1000)}, Units: $bolus2Units");



    } catch (e) {
      print(":x: Decryption failed: $e");
    }
  }

  BluetoothCharacteristic? findCharacteristic(String characteristicUuid) {
    for (BluetoothService service in _services!) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() == characteristicUuid) {
          return characteristic;
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningStream.cancel();
    super.dispose();
  }
}
