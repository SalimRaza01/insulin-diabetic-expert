import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/theme_provider.dart';
import '../widgets/drawer_widget.dart';
import 'package:provider/provider.dart';

import 'notification_screen.dart';
import 'privacy_policy_screen.dart';
import 'splash_screen.dart';
import 'terms&condition_screen.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool toggleDarkmode = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  File? _image;

  @override
  void initState() {
    super.initState();

    // final mapsProvider = context.read<ThemeNotifier>().isDarkMode;
    // print(mapsProvider);
    // setState(() {
    //       Provider.of<ThemeNotifier>(context, listen: false).themeMode(mapsProvider);
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void logout(BuildContext context) async {

    await _hivedb.putBool("isLoggedIn", false);
    _hivedb.putBool('isProfileCompleted', false);
    _hivedb.putBool('isDeviceSetup', false);
    _hivedb.putBool('darkMode', false);
    _hivedb.putImageFile('profileImage', _image!);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        centerTitle: true,
      ),
      drawer: AppDrawerNavigation('SETTINGSSCREEN'),
      body: Stack(
        children: [
          Container(
            height: height * 0.25,
            width: width,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Settings',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppColor.weight600,
                      fontSize: height * 0.03),
                ),
              ),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: height * 0.65,
                width: width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)
                  ),
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'General',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            fontWeight: AppColor.weight600,
                            fontSize: height * 0.015),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Column(
                        children: [
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.dark_mode,size: height * 0.03,
                                        color: Color.fromARGB(
                                            255, 170, 170, 170),
                                      ),
                                      SizedBox(
                                        width: width * 0.02,
                                      ),
                                      Text('Dark Mode',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              fontWeight:
                                                  AppColor.lightWeight,
                                              fontSize: height * 0.018)),
                                    ],
                                  ),
                                  FlutterSwitch(
                                    inactiveColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    height: 25.0,
                           width: 50.0,
                                    padding: 4.0,
                                    toggleSize: 25.0,
                                    borderRadius: 20.0,
                                    activeColor: Colors.black,
                                    value: context
                                        .read<ThemeNotifier>()
                                        .isDarkMode,
                      
                                    onToggle: (value) {
                                      setState(() {
                                        _hivedb.putBool('darkMode', value);
                                        context
                                            .read<ThemeNotifier>()
                                            .isDarkMode = value;
                                      });
                                      Provider.of<ThemeNotifier>(context,
                                              listen: false)
                                          .themeMode(value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          NotificationScreen()));
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.notifications,size: height * 0.03,
                                          color: Color.fromARGB(
                                              255, 170, 170, 170),
                                        ),
                                        SizedBox(
                                          width: width * 0.02,
                                        ),
                                        Text('Notifications',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                fontWeight:
                                                    AppColor.lightWeight,
                                                fontSize: height * 0.018))
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,size: height * 0.03,
                                      color:
                                          Color.fromARGB(255, 170, 170, 170),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Text(
                        'Policy and account terms',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            fontWeight: AppColor.weight600,
                            fontSize: height * 0.015),
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PrivacyPolicyScreen()));
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.policy,size: height * 0.03,
                                          color: Color.fromARGB(
                                              255, 170, 170, 170),
                                        ),
                                        SizedBox(
                                          width: width * 0.02,
                                        ),
                                        Text('Privacy policy',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                fontWeight:
                                                    AppColor.lightWeight,
                                                fontSize: height * 0.018))
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,size: height * 0.03,
                                      color:
                                          Color.fromARGB(255, 170, 170, 170),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TermsCondition()));
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.edit_document,size: height * 0.03,
                                          color: Color.fromARGB(
                                              255, 170, 170, 170),
                                        ),
                                        SizedBox(
                                          width: width * 0.02,
                                        ),
                                        Text('Terms and conditions',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                fontWeight:
                                                    AppColor.lightWeight,
                                                fontSize: height * 0.018))
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,size: height * 0.03,
                                      color:
                                          Color.fromARGB(255, 170, 170, 170),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => ChatBot(
                          //               chatBotConfig: chatBotConfig,
                          //             )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.support_agent,size: height * 0.03,
                                    color: Color.fromARGB(255, 170, 170, 170),
                                  ),
                                  SizedBox(
                                    width: width * 0.02,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Customer Support',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              fontWeight:
                                                  AppColor.lightWeight,
                                              fontSize: height * 0.018)),
                                      Text('Let us know',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              fontWeight:
                                                  AppColor.lightWeight,
                                              fontSize: height * 0.015)),
                                    ],
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.arrow_forward_ios,size: height * 0.03,
                                color: Color.fromARGB(255, 170, 170, 170),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      InkWell(
                        onTap: () {
                          print('hit');
                    
                          showDialog<void>(
                            barrierColor: Colors.black38,
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: Text(
                                  'Confirm Logout',
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    onPressed: () {
                                      logout(context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Splashscreen()));
                                    },
                                    child: Text(
                                      "Yes",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                      ),
                                    ),
                                  ),
                                  CupertinoDialogAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "No",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                                content: Text(
                                  'Are you sure want to logout?',
                                ),
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout,size: height * 0.03,
                                color: Color.fromARGB(255, 170, 170, 170),
                              ),
                              SizedBox(
                                width: width * 0.02,
                              ),
                              Text('Log Out',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: AppColor.lightWeight,
                                      fontSize: height * 0.018)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
