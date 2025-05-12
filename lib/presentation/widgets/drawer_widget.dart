import 'dart:io';
import 'package:INSUL/core/utils/hive_db_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import '../../core/services/bluetooth_service_provider.dart';

class AppDrawerNavigation extends StatefulWidget {
  final String screenName;

  AppDrawerNavigation(
    this.screenName,
  );

  @override
  State<AppDrawerNavigation> createState() => _AppDrawerNavigationState();
}
class _AppDrawerNavigationState extends State<AppDrawerNavigation> {
  final BleManager _bleManager = BleManager();
  final _hivedb = HiveDbHelper();
  File? _image;
  String _topModalData = "";

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    String? filepath = await _hivedb.getString('profileImage');
    print(_hivedb.getString('profileImage'));

    setState(() {
      _image = File(filepath!);
    });
  }

  Future<void> _noDeviceFoundTopModel() async {
    final value = await showTopModalSheet<String?>(
      context,
      NoDeviceFound(),
      backgroundColor: Theme.of(context).colorScheme.primary,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(20),
      ),
    );

    if (value != null) setState(() => _topModalData = value);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Drawer(
      width: width / 1.8,
      child: Container(
        color: Theme.of(context).colorScheme.secondary,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              InkWell(
                onTap: () {
                  context.go('/ProfileScreen');
                },
                child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Colors.transparent),
                    currentAccountPicture: _image == null
                        ? Image.asset(
                            'assets/images/Draweravatar.png',
                          )
                        : ClipOval(
                            child: Image.file(
                              _image!,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                    accountName: Text(
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: height * 0.018,
                            fontWeight: FontWeight.w500),
                        '${_hivedb.getString('firstName')} ${_hivedb.getString('lastName')}'),
                    accountEmail: Text(
                      'Device Id : #25254',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 222, 222, 222),
                          fontSize: height * 0.014),
                    )),
              ),
              ListTile(
                leading: Icon(
                  Icons.home,
                  color: widget.screenName == 'HOMESCREEN'
                      ? Colors.white
                      : Colors.grey,
                  size: height * 0.025,
                ),
                title: Text(
                  'HOME',
                  style: TextStyle(
                    color: widget.screenName == 'HOMESCREEN'
                        ? Colors.white
                        : Colors.grey,
                    fontSize: height * 0.018,
                  ),
                ),
                onTap: () {
                  context.go('/HomeScreen');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: widget.screenName == 'PROFILESCREEN'
                      ? Colors.white
                      : Colors.grey,
                  size: height * 0.025,
                ),
                title: Text(
                  'PROFILE',
                  style: TextStyle(
                    color: widget.screenName == 'PROFILESCREEN'
                        ? Colors.white
                        : Colors.grey,
                    fontSize: height * 0.018,
                  ),
                ),
                onTap: () {
                  context.go('/ProfileScreen');
                },
              ),
              ExpansionTile(
                trailing: SizedBox(),
                title: Row(
                  children: [
                    Icon(
                      Icons.device_hub,
                      color: widget.screenName == 'INSULIN'
                          ? Colors.white
                          : Colors.grey,
                    ),
                    SizedBox(
                      width: width * 0.04,
                    ),
                    Text(
                      'INSULIN',
                      style: TextStyle(
                        color: widget.screenName == 'INSULIN'
                            ? Colors.white
                            : Colors.grey,
                        fontSize: height * 0.018,
                      ),
                    ),
                  ],
                ),
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.track_changes_sharp,
                      color: widget.screenName == ''
                          ? Colors.white
                          : Colors.grey,
                      size: height * 0.022,
                    ),
                    title: Text('SMART BOLUS',
                        style: TextStyle(
                          color: widget.screenName == ''
                              ? Colors.white
                              : Colors.grey,
                          fontSize: height * 0.015,
                        )),
                    onTap: () {
                      if (_bleManager.isDeviceConnected.value == true) {
                        context.go('/SmartBolusScreen');
                      } else {
                        _noDeviceFoundTopModel();
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.track_changes_sharp,
                      color: widget.screenName == ''
                          ? Colors.white
                          : Colors.grey,
                      size: height * 0.022,
                    ),
                    title: Text('BOLUS WIZARD',
                        style: TextStyle(
                          color: widget.screenName == ''
                              ? Colors.white
                              : Colors.grey,
                          fontSize: height * 0.015,
                        )),
                    onTap: () {
                      context.go('/BolusWizard');
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.track_changes_sharp,
                      color: widget.screenName == ''
                          ? Colors.white
                          : Colors.grey,
                      size: height * 0.022,
                    ),
                    title: Text('BASAL WIZARD',
                        style: TextStyle(
                          color: widget.screenName == ''
                              ? Colors.white
                              : Colors.grey,
                          fontSize: height * 0.015,
                        )),
                    onTap: () {
                      context.go('/BasalWizard');
                    },
                  ),
                ],
              ),
              ListTile(
                leading: Icon(
                  Icons.bluetooth,
                  color: widget.screenName == 'DEVICES'
                      ? Colors.white
                      : Colors.grey,
                  size: height * 0.025,
                ),
                title: Text(
                  'DEVICES',
                  style: TextStyle(
                    color: widget.screenName == 'DEVICES'
                        ? Colors.white
                        : Colors.grey,
                    fontSize: height * 0.018,
                  ),
                ),
                onTap: () {
                  context.go('/DevicesScreen');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.table_view_rounded,
                  color: widget.screenName == 'REPORT'
                      ? Colors.white
                      : Colors.grey,
                  size: height * 0.025,
                ),
                title: Text(
                  'REPORT',
                  style: TextStyle(
                    color: widget.screenName == 'REPORT'
                        ? Colors.white
                        : Colors.grey,
                    fontSize: height * 0.018,
                  ),
                ),
                onTap: () {
                  context.go('/ReportScreen');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.paypal,
                  color: widget.screenName == 'PAYMENT' ? Colors.white : Colors.grey,
                  size: height * 0.025,
                ),
                title: Text(
                  'PAYMENT',
                  style: TextStyle(
                    color: widget.screenName == 'PAYMENT' ? Colors.white : Colors.grey,
                    fontSize: height * 0.018,
                  ),
                ),
                onTap: () {
                  context.go('/PaymentScreen');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: widget.screenName == 'SETTINGSSCREEN'
                      ? Colors.white
                      : Colors.grey,
                  size: height * 0.025,
                ),
                title: Text(
                  'SETTINGS',
                  style: TextStyle(
                    color: widget.screenName == 'SETTINGSSCREEN'
                        ? Colors.white
                        : Colors.grey,
                    fontSize: height * 0.018,
                  ),
                ),
                onTap: () {
                  context.go('/SettingScreen');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class NoDeviceFound extends StatelessWidget {
  TextEditingController bloodCountController = TextEditingController();
  TextEditingController bloodPressureController = TextEditingController();
  final _hivedb = HiveDbHelper();
  NoDeviceFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 196, 0, 0),
      ),
      child: Padding(
        padding: EdgeInsets.all(18.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NO DEVICE FOUND",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w300),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Icon(
                  Icons.on_device_training_outlined,
                  size: 40,
                  color: Color.fromARGB(219, 255, 255, 255),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(228, 255, 255, 255),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
