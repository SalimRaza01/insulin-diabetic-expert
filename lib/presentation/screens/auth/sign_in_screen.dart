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
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0E60A4),
                  Color(0xFF05355D),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Header Branding
          Padding(
            padding: EdgeInsets.only(top: height * 0.12,),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "INSUL",
                    style: TextStyle(
                      fontSize: height * 0.06,
                      fontFamily: 'Suissnord',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "YOUR PERSONAL DIABETIC EXPERT",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: height * 0.015,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Login Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.65,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // TextField Input
                    TextField(
                      onChanged: (value) {
                        String emailPattern = r'^[\w-\.]+@gmail\.com$';
                        String phonePattern = r'^[0-9]{10}$';
                        RegExp emailRegExp = RegExp(emailPattern);
                        RegExp phoneRegExp = RegExp(phonePattern);

                        if (value.isEmpty) {
                          setState(() => showerror = 'Please enter email or phone');
                        } else if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                          if (!phoneRegExp.hasMatch(value)) {
                            setState(() => showerror = 'Invalid phone number');
                          } else {
                            setState(() => showerror = null);
                          }
                        } else {
                          if (!emailRegExp.hasMatch(value)) {
                            setState(() => showerror = 'Invalid email');
                          } else {
                            setState(() => showerror = null);
                          }
                        }
                      },
                      controller: controller,
                      cursorColor: Colors.black87,
                      style: const TextStyle(color: Colors.black87),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                            controller.text.contains(RegExp(r'[a-zA-Z]')) ? 50 : 10),
                      ],
                      decoration: InputDecoration(
                        labelText: "Email / Phone",
                        labelStyle: const TextStyle(
                          color: Color(0xFF134E7E),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: const Icon(Icons.person, color: Color(0xFF134E7E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF0E60A4)),
                        ),
                        errorText: showError || controller.text.isNotEmpty ? showerror : null,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Sign In Button
                    GestureDetector(
                      onTap: () async {
                        if (controller.text.isNotEmpty) {
                          await authProvider.login(controller.text.trim(), context);
                          controller.clear();
                        } else {
                          setState(() => showError = true);
                        }
                      },
                      child: Container(
                        height: height * 0.06,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0E60A4),
                              Color(0xFF05355D),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "SIGN IN",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: height * 0.021,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "We'll never share your information",
                      style: TextStyle(
                        fontSize: height * 0.013,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
