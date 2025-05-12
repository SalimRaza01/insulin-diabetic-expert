// ignore_for_file: file_names, prefer_const_literals_to_create_immutables, unnecessary_new

import 'dart:async';
import 'package:INSUL/data/providers/device_provider.dart';
import 'package:INSUL/presentation/widgets/blood_count.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:INSUL/presentation/screens/glucose_screen.dart';
import 'package:INSUL/presentation/screens/smartbolus_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import '../../core/api/api_config.dart';
import '../../core/services/bluetooth_service_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/nutrition_provider.dart';
import '../animations/animation_shimmer.dart';
import '../widgets/bettery_widget.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/resservoir_widget.dart';
import '../widgets/graph/basal_graph.dart';
import '../widgets/graph/bolus_graph.dart';
import '../widgets/graph/glucose_graph.dart';
import '../widgets/graph/insulin_graph.dart';
import '../widgets/graph/smartbolu_graph.dart';
import '../widgets/graph/curren_reading_graph.dart';
import '../widgets/graph/weight_graph.dart';
import 'basal_screen.dart';
import 'bolus_screen.dart';
import 'insulin_screen.dart';
import 'nutrition_screen.dart';
import 'weight_screen.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

final _hivedb = HiveDbHelper();

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> periods = ['24 Hours', 'Week', 'Month'];
  int currentIndex = 0;
  late Future<List<ExpenseData>> chartData;
  final BleManager _bleManager = BleManager();
  bool isQRScanning = false;

  Future<void> getUserDetails() async {
    print('API HIT');
    final dio = Dio();

    final String? userId = await _hivedb.getString('userId');
    print('$getprofile/$userId');

    final response = await dio.get('$getprofile/$userId');

    if (response.statusCode == 200) {
      var data = response.data['data'];
      _hivedb.putString('firstName', data['firstName']);
      _hivedb.putString('lastName', data['lastName']);
    } else {
      throw Exception('Failed to load profile data: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();

    if (_hivedb.getBool('DeviceSetup') == true) {

      _bleManager.agvaDevice.addListener(_onDeviceFound);
    } else {}
    getUserDetails();
    chartData = _fetchChartData(periods[currentIndex]);
  }


//unused code as per new condition
  void _onDeviceFound() {
    if (_bleManager.agvaDevice.value != null) {
      popupDevice(context, _bleManager.agvaDevice.value!, _bleManager);
    }
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      _startScanner();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Camera permission is required to scan QR codes.')),
      );
    }
  }

  void _startScanner() {
    setState(() => isQRScanning = true);
  }

  void _stopScanner() {
    setState(() => isQRScanning = false);
  }

  void _onQRDetected(Barcode barcode, BuildContext context) async {
    final deviceName = barcode.rawValue;

    if (deviceName == 'INSUL-AGVA') {
      _hivedb.putString('device_name', deviceName!);
      Provider.of<DeviceProvider>(context, listen: false)
          .updateDeviceName(deviceName);
      _stopScanner();

      await Future.delayed(const Duration(seconds: 2));
      _bleManager.initializeBluetoothListeners();
      // Navigator.of(context).pop();
      // BleManager().startScanIfNotScanning();
    }
  }

  @override
  void dispose() {

//unused code as per new condition
    _bleManager.agvaDevice.removeListener(_onDeviceFound);
    super.dispose();
  }

  bool showBatteryInfo = false;
  bool showPatchInfo = false;
  String _topModalData = "";
  String _deviceStatus = "";

  void _notifyUserweight(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          duration: Duration(milliseconds: 600),
          backgroundColor: Colors.blue,
          content: Center(
              child: Text(
            message,
            style: TextStyle(fontSize: 17),
          ))),
    );
  }

  Future<List<ExpenseData>> _fetchChartData(String period) async {
    final dio = Dio();
    String filter;

    if (period == "24 Hours") {
      filter = 'today';
    } else if (period == "Week") {
      filter = 'weekly';
    } else if (period == "Month") {
      filter = 'monthly';
    } else {
      throw Exception('Invalid period');
    }

    final _hivedb = HiveDbHelper();
    final String? userId = await _hivedb.getString('userId');

    final response = await dio.get(
      '$nutritionalData/$userId',
      queryParameters: {'filter': filter},
    );
    if (response.statusCode == 200) {
      final responseData = response.data['data'] as List;
      return responseData.map((item) => ExpenseData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _updateChartData() {
    setState(() {
      currentIndex = (currentIndex + 1) % periods.length;
      chartData = _fetchChartData(periods[currentIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Consumer<NutritionChartNotifier>(
        builder: (context, nutritionNotifier, child) {
      if (nutritionNotifier.nutritionStatus == true) {
        chartData = _fetchChartData(periods[currentIndex]);
        Provider.of<NutritionChartNotifier>(context, listen: false)
            .nutritionUpdate(false);
      }

      return ValueListenableBuilder(
        valueListenable: _bleManager.isScanningRunning,
        builder: (context, isScanning, _) {
          print('is scanning in homescreen $isScanning');
          return ValueListenableBuilder(
            valueListenable: _bleManager.isDeviceConnected,
            builder: (context, isConnected, _) {
              return ValueListenableBuilder(
                valueListenable: _bleManager.agvaDevice,
                builder: (context, agvaDevice, _) {
                  print('Started Listening 4 ${_bleManager.agvaDevice.value}');
                  return ValueListenableBuilder(
                      valueListenable: _bleManager.adapterState,
                      builder: (context, adapterState, _) {
                        return Scaffold(
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          appBar: AppBar(
                            iconTheme: IconThemeData(color: Colors.white),
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            actions: <Widget>[
                              InkWell(
                                onTap: () async {
                                  if (adapterState ==
                                      BluetoothAdapterState.off) {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: height * 0.2,
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 5, 53, 93)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Bluetooth is turned off",
                                                      style: TextStyle(
                                                          fontSize:
                                                              height * 0.022,
                                                          color: Colors.white),
                                                    ),
                                                    SizedBox(
                                                      height: height * 0.02,
                                                    ),
                                                    Text(
                                                      "Please turn on your bluetooth to connect insulin ",
                                                      style: TextStyle(
                                                          fontSize:
                                                              height * 0.012,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                Icon(Icons.bluetooth_disabled,
                                                    size: height * 0.04,
                                                    color: Colors.white)
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    await _requestCameraPermission();
                                  }
                                },
                                child: Icon(CupertinoIcons.barcode_viewfinder),
                              ),
                              SizedBox(
                                width: 25,
                              ),
                            
                              isScanning
                                  ? Image.asset(
                                      'assets/images/scanning.gif',
                                      width: 20,
                                    )
                                  : Icon(isConnected
                                      ? CupertinoIcons.rectangle_badge_checkmark
                                      : CupertinoIcons.rectangle_badge_xmark),

                              SizedBox(
                                width: 25,
                              ),
                              GestureDetector(
                                  onTap: _addBloodCount,
                                  child: Icon(CupertinoIcons.bell_fill)),
                              SizedBox(
                                width: 20,
                              )
                            ],
                          ),
                          body: Stack(
                            children: [
                              SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Column(
                                    children: [
                                      //Today's_Status_Widget
                                      SizedBox(height: height * 0.020),
                                      GestureDetector(child: TodaysStatus()),

                                      SizedBox(height: height * 0.015),
                                      //Avarage_Insulin_Intake_Widget

                                      GestureDetector(
                                          onTap: () {
                                            if (isConnected) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SmartBolusScreen()));
                                            } else {
                                              _noDeviceFoundTopModel();
                                            }
                                          },
                                          child: SmartBolusWidget()),

                                      SizedBox(height: height * 0.015),
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        NutritionScreen()));
                                          },
                                          child: newMethod(height, width)),

                                      SizedBox(height: height * 0.015),

                                      GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        WeightScreen()));
                                          },
                                          child: WeightChart()),

                                      SizedBox(height: height * 0.015),

                                      //GlucoseChart_Widget
                                      GestureDetector(
                                          onTap: () {
                                            if (isConnected) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          GlucoseScreen()));
                                            } else {
                                              _noDeviceFoundTopModel();
                                            }
                                          },
                                          child: Glucosechart()),

                                      SizedBox(height: height * 0.015),
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        InsulinScreen()));
                                          },
                                          child: Insulinchart()),

                                      SizedBox(height: height * 0.015),
                                      //InsulinkChart_Widget
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BasalWizard()));
                                        },
                                        child: Basalgraph(),
                                      ),
                                      SizedBox(height: height * 0.015),

                                      GestureDetector(
                                        onTap: () async {
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BolusWizard()));
                                        },
                                        child: Bolusgraph(),
                                      ),
                                      SizedBox(height: height * 0.015),

                                      RessorvoirWidget(),

                                      SizedBox(height: height * 0.015),
                                      //Bettery_Widget
                                      BatteryStatus(),
                                      SizedBox(height: height * 0.015),
                                      //Patch_Widget
                                    ],
                                  ),
                                ),
                              ),
                              if (isQRScanning)
                                Positioned.fill(
                                  child: MobileScanner(
                                    onDetect: (capture) {
                                      for (final barcode in capture.barcodes) {
                                        _onQRDetected(barcode, context);
                                      }
                                    },
                                  ),
                                ),
                            ],
                          ),
                          drawer: AppDrawerNavigation('HOMESCREEN'),
                        );
                      });
                },
              );
            },
          );
        },
      );
    });
  }

  newMethod(double height, double width) {
    return Container(
      height: height * 0.28,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NUTRITION',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      fontSize: height * 0.015,
                      fontWeight: AppColor.weight600,
                    ),
                  ),
                  GestureDetector(
                    onTap: _updateChartData,
                    child: Text(
                      periods[currentIndex],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        fontSize: height * 0.015,
                        fontWeight: AppColor.weight600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.01),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegend('Carbs', quickWorkoutColor),
                    _buildLegend('Protein', cyclingColor),
                    _buildLegend('Fats', pilateColor),
                  ],
                ),
                FutureBuilder<List<ExpenseData>>(
                  future: chartData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ShimmereffectGraph();
                    } else if (snapshot.hasError) {
                      return _buildErrorWidget(height, 'Error found');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildErrorWidget(height, 'No Data found');
                    } else {
                      return SizedBox(
                        height: height * 0.19,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: SfCartesianChart(
                            margin: EdgeInsets.all(0),
                            plotAreaBorderWidth: 0.0,
                            legend: Legend(isVisible: false),
                            series: <CartesianSeries>[
                              StackedColumnSeries<ExpenseData, String>(
                                  borderRadius: BorderRadius.circular(50),
                                  color: quickWorkoutColor,
                                  width: periods[currentIndex] == 'Week'
                                      ? 0.2
                                      : 0.7,
                                  dataSource: snapshot.data,
                                  xValueMapper: (ExpenseData exp, _) =>
                                      exp.expenseCategory,
                                  yValueMapper: (ExpenseData exp, _) =>
                                      exp.carbs,
                                  markerSettings: MarkerSettings(
                                    isVisible: false,
                                  )),
                              StackedColumnSeries<ExpenseData, String>(
                                  borderRadius: BorderRadius.circular(50),
                                  color: cyclingColor,
                                  width: periods[currentIndex] == 'Week'
                                      ? 0.2
                                      : 0.7,
                                  dataSource: snapshot.data,
                                  xValueMapper: (ExpenseData exp, _) =>
                                      exp.expenseCategory,
                                  yValueMapper: (ExpenseData exp, _) =>
                                      exp.protein,
                                  markerSettings: MarkerSettings(
                                    isVisible: false,
                                  )),
                              StackedColumnSeries<ExpenseData, String>(
                                  borderRadius: BorderRadius.circular(50),
                                  color: pilateColor,
                                  width: periods[currentIndex] == 'Week'
                                      ? 0.2
                                      : 0.7,
                                  dataSource: snapshot.data,
                                  xValueMapper: (ExpenseData exp, _) =>
                                      exp.expenseCategory,
                                  yValueMapper: (ExpenseData exp, _) => exp.fat,
                                  markerSettings: MarkerSettings(
                                    isVisible: false,
                                  )),
                            ],
                            primaryXAxis: CategoryAxis(
                              labelAlignment: LabelAlignment.center,
                              labelPlacement: LabelPlacement.onTicks,
                              interval: 1,
                              axisLine: AxisLine(width: 0.0),
                              placeLabelsNearAxisLine: false,
                              labelStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              borderColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              majorTickLines: const MajorTickLines(width: 0),
                              majorGridLines: MajorGridLines(
                                width: 0.0,
                              ),
                            ),
                            primaryYAxis: CategoryAxis(
                              isVisible: false,
                              axisLine: AxisLine(width: 0.0),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primaryContainer,
            fontSize: 13,
            fontWeight: AppColor.weight600,
          ),
        ),
        SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(50)),
          height: 12,
          width: 12,
        ),
      ],
    );
  }

  Widget _buildErrorWidget(double height, String message) {
    return SizedBox(
      height: height * 0.15,
      child: Center(
        child: Text(
          message,
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondaryContainer),
        ),
      ),
    );
  }



//unused code as per new condition
  Future<void> popupDevice(
      BuildContext context, BluetoothDevice device, BleManager bleManager) {
    print('POPUP Showen');
    return showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        builder: (BuildContext context) {
          final height = MediaQuery.of(context).size.height;
          final width = MediaQuery.of(context).size.width;
          return Container(
            height: height * 0.42,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35))),
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width * 0.06,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            _hivedb.getString('device_name')!,
                            style: TextStyle(
                              fontSize: height * 0.035,
                              fontWeight: FontWeight.w300,
                              color: const Color.fromARGB(150, 0, 0, 0),
                              // fontFamily: 'Adventure',
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            _bleManager.disconnectDevice(device);
                          },
                          child: Image.asset(
                            'assets/images/ic_remove.png',
                            width: width * 0.06,
                          ),
                        ),
                      ],
                    ),
                    Container(
                        height: height * 0.25,
                        width: width * 0.7,
                        child: Image.asset(
                          'assets/images/insulin4D.gif',
                          // fit: BoxFit.cover,
                        )),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          bleManager.discoverServices(device);
                          print('AGVA DEVICE $device');

                          Navigator.pop(context);
                        },
                        child: Container(
                          height: height * 0.05,
                          width: width * 0.7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColor.backgroundColor,
                            border: Border.all(
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          child: Center(
                              child: Text(
                            'Connect',
                            style: TextStyle(
                                color: const Color.fromARGB(150, 0, 0, 0),
                                fontSize: height * 0.02),
                          )),
                        ),
                      ),
                    ),
                  ],
                )),
          );
        });
  }

  void showPopupMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(80, 180, 20, 0),
      items: [
        PopupMenuItem(
          child: Text(
            'Battery Info',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              // fontSize: 14,
            ),
          ),
          onTap: () {
            setState(() {
              showBatteryInfo = true;
            });
          },
        ),
        PopupMenuItem(
          child: Text(
            'Insulin Patch',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              // fontSize: 14,
            ),
          ),
          onTap: () {
            setState(() {
              showPatchInfo = true;
            });
          },
        ),
      ],
      elevation: 8.0,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  Future<void> _addBloodCount() async {
    final value = await showTopModalSheet<String?>(
      context,
      BloodCount(),
      backgroundColor: Theme.of(context).colorScheme.primary,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(20),
      ),
    );

    if (value != null) setState(() => _topModalData = value);
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

  Future<void> _insulintopModel() async {
    final value = await showTopModalSheet<String?>(
      context,
      InsulinTopModel(),
      backgroundColor: Theme.of(context).colorScheme.primary,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(20),
      ),
    );

    if (value != null) setState(() => _topModalData = value);
  }
}

class InsulinTopModel extends StatelessWidget {
  const InsulinTopModel({Key? key}) : super(key: key);

  static const _values = ["CF Cruz Azul", "Monarcas FC"];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color.fromARGB(255, 204, 16, 2)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 30,
              ),
              Text(
                "Insulin battery remaining",
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).colorScheme.primary),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "10 %",
                style: TextStyle(
                    fontSize: 35,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "updated at 10:30 AM ",
                style: TextStyle(
                    fontSize: 15, color: Theme.of(context).colorScheme.primary),
              ),
            ]),
            Icon(
              Icons.warning_rounded,
              size: 70,
              color: Theme.of(context).colorScheme.primary,
            )
          ],
        ),
      ),
    );
  }
}

final pilateColor = const Color.fromARGB(255, 255, 0, 92); // Fat
final cyclingColor = const Color.fromARGB(255, 0, 156, 156); // Protein
final quickWorkoutColor = const Color.fromARGB(255, 236, 170, 0); // Carbs
final betweenSpace = 0.2;

class ExpenseData {
  ExpenseData(this.expenseCategory, this.carbs, this.protein, this.fat);
  final String expenseCategory;
  final num carbs;
  final num protein;
  final num fat;

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      json['time'],
      num.parse(json['Carbs']),
      num.parse(json['Protein']),
      num.parse(json['Fat']),
    );
  }
}
