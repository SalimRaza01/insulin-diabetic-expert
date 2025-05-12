import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../core/api/api_config.dart';
import '../../presentation/screens/otp_screen.dart';

import 'package:INSUL/core/utils/hive_db_utils.dart';
  final _hivedb = HiveDbHelper();
  
class AuthProvider with ChangeNotifier {
  Future<void> login(String controller, BuildContext context) async {
    try {
      Response response =
          await post(Uri.parse(signInApi), body: {'userId': controller});

      if (response.statusCode == 200) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SigninOTP(controller)));

        print('successfull');
      } else {
        print(response.body);
        print('failed');

        return null;
      }
    } catch (e) {
      print(e.toString());

      return null;
    }
  }
}

class ResendOtp with ChangeNotifier {
  Future<void> reSendOtp(String controller, BuildContext context) async {
    try {
      Response response =
          await post(Uri.parse(signInApi), body: {'userId': controller});
      print('asda');
      if (response.statusCode == 200) {
        print('successfull');
      } else {
        print('failed');

        return null;
      }
    } catch (e) {
      print(e.toString());

      return null;
    }
  }
}

class OtpProvider with ChangeNotifier {


  Future<void> otpverify(
    String otpFields,
  ) async {
    try {
      Response response =
          await post(Uri.parse(getotp), body: {'otp': otpFields});
      print('asda');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("login response $data");
        String id = data["data"]["_id"];
        bool isProfileCompleted = data['data']['isProfileCompleted'];
        bool isDeviceSetup = data['data']['isDeviceSetup'];

        _hivedb.putString('userId', id);
        _hivedb.putBool("isLoggedIn", true);
        _hivedb.putBool('isProfileCompleted', isProfileCompleted);
        _hivedb.putBool('isDeviceSetup', isDeviceSetup);
        _hivedb.putString('weight', data['data']['weight']);

        print('successfull');
      } else {
        var data = jsonDecode(response.body);
        String message = data["message"];

        _hivedb.putString('message', message);

        print(message);
        print('failed');
      }
    } catch (e) {
      print(e.toString());

      return null;
    }
  }
}
