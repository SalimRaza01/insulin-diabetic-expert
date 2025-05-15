import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../home_screen.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

final _hivedb = HiveDbHelper();

class SigninOTP extends StatefulWidget {
  final String controller;
  SigninOTP(this.controller);

  @override
  State<SigninOTP> createState() => _SigninOTPState();
}

class _SigninOTPState extends State<SigninOTP> {
  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late Timer _resendTimer;

  bool showerror = false;
  bool isEmail = false;
  bool resendOtp = false;
  bool isPhoneOtpVerified = false;
  int remainingTime = 59;

  @override
  void initState() {
    super.initState();
    checkForInput(widget.controller);
    startResendTimer();
    pinController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    _resendTimer.cancel();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void checkForInput(String inputText) {
    if (inputText.isEmpty) return;
    isEmail = inputText.startsWith(RegExp(r'[A-Za-z]'));
  }

  void startResendTimer() {
    remainingTime = 59;
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          resendOtp = true;
          _resendTimer.cancel();
        }
      });
    });
  }

  void handleOtpCompletion(String pin, OtpProvider otpProvider) async {
    await otpProvider.otpverify(pin);

    Future.delayed(Duration(milliseconds: 1500), () {
      if (_hivedb.getBool("isLoggedIn") == true) {
        _resendTimer.cancel();
        _hivedb.putString('loginSource', widget.controller);

        // if (_hivedb.getBool("isProfileCompleted") == true &&
        //     _hivedb.getBool('isDeviceSetup') == true) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              ModalRoute.withName('/'));
        // } else {
        //   Navigator.push(
        //       context, MaterialPageRoute(builder: (context) => SetupProfile()));
        // }
      } else {
        setState(() => showerror = true);
        Future.delayed(Duration(seconds: 2), () => setState(() => showerror = false));
      }
    });
  }

  void handleVerifyButton() {
    if (_hivedb.getBool("isLoggedIn") == true) {
      _resendTimer.cancel();
      _hivedb.putString('loginSource', widget.controller);

      // if (_hivedb.getBool("isProfileCompleted") == true) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            ModalRoute.withName('/'));
      // } else {
      //   Navigator.push(
      //       context, MaterialPageRoute(builder: (context) => SetupProfile()));
      // }
    } else {
      setState(() => showerror = true);
      Future.delayed(Duration(seconds: 2), () => setState(() => showerror = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<ResendOtp>(context);
    final otpProvider = Provider.of<OtpProvider>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(fontSize: 22, color: Colors.white),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.white.withOpacity(0.359)),
      ),
    );

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 14, 96, 164),
      body: SingleChildScrollView(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 14, 96, 164), Color.fromARGB(255, 5, 53, 93)],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 60),
              AnimatedContainer(
                height: showerror ? height * 0.05 : 0,
                duration: Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 50),
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    '${_hivedb.getString('message')}',
                    style: TextStyle(
                      fontSize: showerror ? height * 0.015 : 0.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("ENTER OTP", style: TextStyle(color: Colors.white, fontSize: height * 0.04, fontWeight: FontWeight.w200)),
                    SizedBox(height: 50),
                    Image.asset('assets/images/OTP 1.png', height: height * 0.13),
                    SizedBox(height: height * 0.02),
                    Text(
                      remainingTime > 9 ? "00:$remainingTime" : "00:0$remainingTime",
                      style: TextStyle(color: Colors.white, fontSize: height * 0.03, fontWeight: FontWeight.w200),
                    ),
                    SizedBox(height: height * 0.01),
                    GestureDetector(
                      onTap: remainingTime == 0 ? () async {
                        await authProvider.reSendOtp(widget.controller, context);
                        startResendTimer();
                      } : null,
                      child: Text(
                        "RE-SEND OTP",
                        style: TextStyle(
                          color: remainingTime == 0 ? Color.fromARGB(255, 115, 223, 119) : Colors.white.withOpacity(0.35),
                          fontSize: height * 0.015,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isEmail ? widget.controller : "+91 ${widget.controller}",
                          style: TextStyle(color: Colors.white, fontSize: height * 0.02, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: width * 0.01),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.edit, size: height * 0.019, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.03),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Pinput(
                        controller: pinController,
                        focusNode: focusNode,
                        defaultPinTheme: defaultPinTheme,
                        separatorBuilder: (index) => SizedBox(width: 8),
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) => handleOtpCompletion(pin, otpProvider),
                        onChanged: (value) => debugPrint('onChanged: $value'),
                        cursor: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 9),
                              width: 22,
                              height: 1,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: showerror ? Colors.redAccent : Colors.white),
                          ),
                        ),
                        submittedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(color: showerror ? Colors.redAccent : Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.04),
                    GestureDetector(
                      onTap: handleVerifyButton,
                      child: Container(
                        width: width / 1.5,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width: 1, color: Colors.white),
                          gradient: LinearGradient(colors: [Color.fromARGB(255, 14, 96, 164), Color.fromARGB(255, 5, 53, 93)]),
                        ),
                        child: Center(
                          child: Text("Verify", style: TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
