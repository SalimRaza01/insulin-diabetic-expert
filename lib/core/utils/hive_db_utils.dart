import 'dart:convert';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';

class HiveDbHelper {
  static final HiveDbHelper _instance = HiveDbHelper._internal();
  factory HiveDbHelper() => _instance;
  HiveDbHelper._internal();

  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('appDataBox');
  }

  Future<void> putString(String key, String value) async {
    await _box.put(key, value);
  }

  String? getString(String key) {
    return _box.get(key) as String?;
  }

  Future<void> putStringList(String key, List<String> value) async {
    await _box.put(key, value);
  }

  List<String>? getStringList(String key) {
    final data = _box.get(key);
    return data != null ? List<String>.from(data) : [];
  }

  Future<void> putInt(String key, int value) async {
    await _box.put(key, value);
  }

  int? getInt(String key) {
    return _box.get(key) as int?;
  }

  Future<void> putBool(String key, bool value) async {
    await _box.put(key, value);
  }

  bool? getBool(String key) {
    return _box.get(key) as bool?;
  }

  Future<void> setDouble(String key, double value) async {
    await _box.put(key, value);
  }

  double? getDouble(String key) {
    return _box.get(key) as double?;
  }

  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  /// Store image file as base64 string
  Future<void> putImageFile(String key, File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64String = base64Encode(bytes);
    await _box.put(key, base64String);
  }

  /// Retrieve image file from base64 string
  File? getImageFile(String key, String filePath) {
    final base64String = _box.get(key) as String?;
    if (base64String == null) return null;

    final bytes = base64Decode(base64String);
    final file = File(filePath)..writeAsBytesSync(bytes);
    return file;
  }
}
