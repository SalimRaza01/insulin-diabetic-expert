import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:INSUL/data/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? showerror;
  bool showError = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: <Color>[
              const Color.fromARGB(255, 14, 96, 164),
              const Color.fromARGB(255, 5, 53, 93)
            ])),
            child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 18),
              child: Column(
                children: [
                  
                  SizedBox(
                    height: height * 0.15,
                  ),
                  Text(
                        "INSUL",
                        style: TextStyle(
                            fontSize: height * 0.055,
                            fontFamily: 'Suissnord',
                            color: Colors.white),
                      ),
                      Text(
                        "YOUR PERSONAL DIABETIC EXPERT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: height * 0.013,
                        ),
                      ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.65,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: TextField(
                          onChanged: (value) {
                            String emailPattern = r'^[\w-\.]+@gmail\.com$';

                            String phonePattern = r'^[0-9]{10}$';

                            RegExp emailRegExp = RegExp(emailPattern);
                            RegExp phoneRegExp = RegExp(phonePattern);

                            if (value.isEmpty) {
                              setState(() {
                                showerror = 'Please enter your email or phone';
                              });
                            } else if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                              if (!phoneRegExp.hasMatch(value)) {
                                setState(() {
                                  showerror = 'Invalid phone number';
                                });
                              } else {
                                setState(() {
                                  showerror = null;
                                });
                              }
                            } else {
                              if (!emailRegExp.hasMatch(value)) {
                                setState(() {
                                  showerror = 'Invalid email';
                                });
                              } else {
                                setState(() {
                                  showerror = null;
                                });
                              }
                            }
                          },
                          cursorColor:
                              Theme.of(context).colorScheme.onInverseSurface,
                          selectionControls: CupertinoTextSelectionControls(),
                          style:
                              TextStyle(color: Color.fromARGB(255, 49, 49, 49)),
                          controller: controller,
                          inputFormatters: controller.text.contains(RegExp(r'[a-z]'))
                              ? [LengthLimitingTextInputFormatter(50)] // Set max length for phone number
                              : [LengthLimitingTextInputFormatter(10)],
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      // color: Theme.of(context)
                                      //     .colorScheme
                                      //     .onInverseSurface,
                                      color: Colors.grey)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey
                                      // color: Theme.of(context)
                                      //     .colorScheme
                                      //     .onInverseSurface,
                                      )),
                              errorText: showError || controller.text.isNotEmpty
                                  ? showerror
                                  : null,
                              suffixIcon: Icon(Icons.person,
                                  color:
                                      const Color.fromARGB(255, 19, 78, 126)),
                              label: Text(
                                "Email / Phone",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 19, 78, 126),
                                  fontWeight: FontWeight.w400,
                                ),
                              )),
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                      GestureDetector(
                        onTap: () async {
                          if (controller.text.isNotEmpty) {
                            print('sign in button');
                            await authProvider.login(
                                controller.text.toString(), context);
                            controller.clear();
                          } else {
                            setState(() {
                              showError = true;
                            });
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.8,
                          height: height * 0.06,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(colors: <Color>[
                                const Color.fromARGB(255, 14, 96, 164),
                                const Color.fromARGB(255, 5, 53, 93)
                              ])),
                          child: Center(
                            child: Text(
                              "SIGN IN",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: height * 0.022),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
