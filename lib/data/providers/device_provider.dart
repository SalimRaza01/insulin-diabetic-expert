import 'package:flutter/material.dart';

class DeviceProvider extends ChangeNotifier {
  String? deviceName;
  String get getDeviceName => deviceName!;

  void updateDeviceName(String getDeviceName) {
    deviceName = getDeviceName;
    notifyListeners();
  }
}