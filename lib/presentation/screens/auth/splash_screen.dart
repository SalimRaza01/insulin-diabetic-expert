import 'package:flutter/material.dart';
import 'package:INSUL/presentation/screens/auth/sign_in_screen.dart';
import 'package:INSUL/presentation/screens/home_screen.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  @override
  void initState() {
    super.initState();



    Future.delayed(Duration(seconds: 3), () {
  
      if (_hivedb.getBool('isLoggedIn') == true) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: <Color>[
              const Color.fromARGB(255, 14, 96, 164),
              const Color.fromARGB(255, 5, 53, 93)
            ])),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(),
                  Column(
                    children: [
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
                  Column(
                    children: [
                      Text(
                        "POWERED BY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: height * 0.01,
                        ),
                      ),
                      Text(
                        "D&D Healthcare",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: height * 0.02,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
