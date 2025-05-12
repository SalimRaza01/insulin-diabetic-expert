import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../data/providers/auth_provider.dart';
import 'home_screen.dart';
import 'setup_profile_screen.dart';
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
  bool showerror = false;
  late String controller = '';
  late Timer _resendTimer;
  int remainingTime = 59;
  bool isEmail = false;
  bool resendOtp = false;
  bool isPhoneOtpVerified = false;

  @override
  void initState() {
    checkForInput(widget.controller);
    startResendTimer();
    pinController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _resendTimer.cancel();
    pinController.dispose();
    focusNode.dispose();

    super.dispose();
  }

  void checkForInput(String inputText) {
    if (inputText.isEmpty) {
      print("No input provided");
      return;
    }
    if (inputText.startsWith(RegExp(r'[A-Za-z]'))) {
      isEmail = true;
      print("Sent OTP on email");
    } else if (inputText
        .startsWith(RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]'))) {
      isEmail = false;
      print("Sent OTP on phone number");
    } else {
      print("Invalid input");
    }
  }

  startResendTimer() {
    print('time is running');
    remainingTime = 59;
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      print('time is running 1');
      setState(() {
        if (remainingTime > 0) {
          print('time is running 2');
          remainingTime--;
        } else if (remainingTime == 0) {
          resendOtp = true;
          _resendTimer.cancel();
          timer.cancel();
        } else {
          timer.cancel();
        }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    Color? focusedBorderColor = Color.fromRGBO(255, 255, 255, 1);
    Color? fillColor = Color.fromRGBO(255, 255, 255, 0);
    Color? borderColor = Color.fromRGBO(255, 255, 255, 0.359);
      Color? errorfocusedBorderColor = Colors.redAccent;
    Color? errorfillColor =Colors.redAccent;
    Color? errorborderColor = Colors.redAccent;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle:  TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(255, 255, 255, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    final authProvider = Provider.of<ResendOtp>(context);
    final otpProvider = Provider.of<OtpProvider>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 14, 96, 164),
      body: SingleChildScrollView(
        child: Container(
          height: height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: <Color>[
            Color.fromARGB(255, 14, 96, 164),
            Color.fromARGB(255, 5, 53, 93)
          ])),
          child: Column(
            children: [
              SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: AnimatedContainer(
                  height: showerror ? height * 0.05 : height * 0.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.red,
                  ),
                  duration: Duration(seconds: 1),
                  curve: Curves.fastOutSlowIn,
                  child: Padding(
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
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "ENTER OTP",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                        fontSize: height * 0.04,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Center(
                        child: Image.asset(
                      'assets/images/OTP 1.png',
                      height: height * 0.13,
                    )),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Text(
                      remainingTime > 9
                          ? "00:$remainingTime"
                          : "00:0$remainingTime",
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: height * 0.03,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await authProvider.reSendOtp(
                            widget.controller, context);
                        await startResendTimer();
                      },
                      child: Text(
                        "RE-SEND OTP",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: height * 0.015,
                            color: remainingTime == 0
                                ? const Color.fromARGB(255, 115, 223, 119)
                                : const Color.fromARGB(90, 255, 255, 255)),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isEmail
                              ? "${widget.controller}"
                              : "+91 ${widget.controller}",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: height * 0.02,
                              color: Colors.white),
                        ),
                        SizedBox(
                          width: width * 0.01,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.edit,
                            size: height * 0.019,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Pinput(
                        controller: pinController,

                        focusNode: focusNode,
                        defaultPinTheme: defaultPinTheme,

                        separatorBuilder: (index) => const SizedBox(width: 8),
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) async {
                          await otpProvider.otpverify(pin);

                         Future.delayed(Duration(milliseconds: 1500),(){
                           if (_hivedb.getBool("isLoggedIn") == true) {
                            if (_resendTimer.isActive) {
                              _resendTimer.cancel();
                              print("timer cancelled");
                            }
                            _hivedb.putString('loginSource', widget.controller);
                            if (_hivedb.getBool("isProfileCompleted") == true && _hivedb.getBool('isDeviceSetup') == true) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()),
                                  ModalRoute.withName('/'));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SetupProfile()));
                            }
                          } else {
                            setState(() {
                              showerror = true;
                            });
                            Future.delayed(Duration(seconds: 2), () {
                              setState(() {
                                showerror = false;
                              });
                            });
                          }
                         });
                        },
                        onChanged: (value) {
                          debugPrint('onChanged: $value');
                        },
                        cursor: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 9),
                              width: 22,
                              height: 1,
                              color: focusedBorderColor,
                            ),
                          ],
                        ),
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: showerror ? errorfocusedBorderColor : focusedBorderColor),
                          ),
                        ),
                        submittedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: showerror ? errorfocusedBorderColor : focusedBorderColor),
                          ),
                        ),
                        // errorPinTheme: showerror ? defaultPinTheme.copyBorderWith(
                        //   border: Border.all(color: Colors.redAccent),
                        // ) : null
                      ),
                    ),
                    SizedBox(
                      height: height * 0.04,
                    ),
                    GestureDetector(
                      onTap: () async {
                        // await otpProvider.otpverify();

                        if (_hivedb.getBool("isLoggedIn") == true) {
                          if (_resendTimer.isActive) {
                            _resendTimer.cancel();
                            print("timer cancelled");
                          }
                          _hivedb.putString('loginSource', widget.controller);
                          if (_hivedb.getBool("isProfileCompleted") == true) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()),
                                ModalRoute.withName('/'));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SetupProfile()));
                          }
                        } else {
                          setState(() {
                            showerror = true;
                          });
                          Future.delayed(Duration(seconds: 2), () {
                            setState(() {
                              showerror = false;
                            });
                          });
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.5,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(width: 1, color: Colors.white),
                            gradient: LinearGradient(colors: <Color>[
                              const Color.fromARGB(255, 14, 96, 164),
                              const Color.fromARGB(255, 5, 53, 93)
                            ])),
                        child: Center(
                          child: Text(
                            "Verify",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
