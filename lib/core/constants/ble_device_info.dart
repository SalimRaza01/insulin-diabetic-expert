import 'package:intl/intl.dart';

class BleDeviceInfo {
  static String characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static String connectionCMD = "cm+hs";
  static String firstCMD = "cm+st";
  static String secCMD = "cm+bo";
  static String dataCMD =
      "CM+SYNC : ${DateFormat('dd-MM-yyyy - hh:mm').format(DateTime.now())}";
}
