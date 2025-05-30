// // ignore_for_file: file_names, prefer_const_literals_to_create_immutables, unnecessary_new

// import 'dart:async';
// import 'package:INSUL/presentation/widgets/blood_count.dart';
// import 'package:INSUL/presentation/widgets/device_setup_reminder.dart';
// import 'package:INSUL/presentation/widgets/profile_complete_widget.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:top_modal_sheet/top_modal_sheet.dart';
// import '../../core/services/bluetooth_service_provider.dart';
// import '../../core/theme/app_colors.dart';
// import '../widgets/bettery_widget.dart';
// import '../widgets/drawer_widget.dart';
// import '../widgets/resservoir_widget.dart';
// import '../widgets/graph/basal_graph.dart';
// import '../widgets/graph/bolus_graph.dart';
// import '../widgets/graph/glucose_graph.dart';
// import '../widgets/graph/insulin_graph.dart';
// import '../widgets/graph/smartbolu_graph.dart';
// import '../widgets/graph/curren_reading_graph.dart';
// import '../widgets/graph/weight_graph.dart';
// import 'package:INSUL/core/utils/hive_db_utils.dart';

// final _hivedb = HiveDbHelper();

// class TutorialScreen extends StatefulWidget {
//   TutorialScreen({super.key});

//   @override
//   _TutorialScreenState createState() => _TutorialScreenState();
// }

// class _TutorialScreenState extends State<TutorialScreen> {
//   final List<String> periods = ['24 Hours', 'Week', 'Month'];
//   int currentIndex = 0;

//   @override
//   void initState() {
//     Future.delayed(const Duration(seconds: 1), () {

//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   bool showBatteryInfo = false;
//   bool showPatchInfo = false;
//   String _topModalData = "";
//   String _deviceStatus = "";

//   void _notifyUserweight(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//           duration: Duration(milliseconds: 600),
//           backgroundColor: Colors.blue,
//           content: Center(
//               child: Text(
//             message,
//             style: TextStyle(fontSize: 17),
//           ))),
//     );
//   }

//   void _updateChartData() {
//     setState(() {
//       currentIndex = (currentIndex + 1) % periods.length;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.onPrimary,
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor: Theme.of(context).colorScheme.secondary,
//         actions: <Widget>[
//           InkWell(
//               onTap: () {

//               },
//               child: Icon(
//                 CupertinoIcons.barcode_viewfinder,

//               )),
//           SizedBox(
//             width: 25,
//           ),
//           Icon(
//             CupertinoIcons.rectangle_badge_checkmark,
//             color: Colors.red,
//           ),
//           SizedBox(
//             width: 25,
//           ),
//           GestureDetector(
//               onTap: _addBloodCount, child: Icon(CupertinoIcons.bell_fill)),
//           SizedBox(
//             width: 20,
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 15),
//           child: Column(
//             children: [
//               ConnectDeviceReminderCard(
//                 onConnect: () {},
//               ),
//               Visibility(
//                   visible: _hivedb.getBool('isProfileCompleted') != true,
//                   child: CompleteProfileCard()),
//               SizedBox(height: height * 0.020),
//               GestureDetector(child: TodaysStatus()),

//               SizedBox(height: height * 0.015),
//               //Avarage_Insulin_Intake_Widget

//               GestureDetector(onTap: () {}, child: SmartBolusWidget()),

//               SizedBox(height: height * 0.015),
//               GestureDetector(onTap: () {}, child: newMethod(height, width)),

//               SizedBox(height: height * 0.015),

//               GestureDetector(onTap: () {}, child: WeightChart()),

//               SizedBox(height: height * 0.015),

//               //GlucoseChart_Widget
//               GestureDetector(onTap: () {}, child: Glucosechart()),

//               SizedBox(height: height * 0.015),
//               GestureDetector(onTap: () {}, child: Insulinchart()),

//               SizedBox(height: height * 0.015),
//               //InsulinkChart_Widget
//               GestureDetector(
//                 onTap: () {},
//                 child: Basalgraph(),
//               ),
//               SizedBox(height: height * 0.015),

//               GestureDetector(
//                 onTap: () {},
//                 child: Bolusgraph(),
//               ),
//               SizedBox(height: height * 0.015),

//               RessorvoirWidget(),

//               SizedBox(height: height * 0.015),
//               //Bettery_Widget
//               BatteryStatus(),
//               SizedBox(height: height * 0.015),
//               //Patch_Widget
//             ],
//           ),
//         ),
//       ),
//       drawer: AppDrawerNavigation('HOMESCREEN'),
//     );
//   }

//   newMethod(double height, double width) {
//     return Container(
//       height: height * 0.28,
//       width: width,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Theme.of(context).colorScheme.primary,
//       ),
//       child: Padding(
//         padding: EdgeInsets.only(top: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'NUTRITION',
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.primaryContainer,
//                       fontSize: height * 0.015,
//                       fontWeight: AppColor.weight600,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: _updateChartData,
//                     child: Text(
//                       periods[currentIndex],
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.primaryContainer,
//                         fontSize: height * 0.015,
//                         fontWeight: AppColor.weight600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: height * 0.01),
//             Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildLegend('Carbs', quickWorkoutColor),
//                     _buildLegend('Protein', cyclingColor),
//                     _buildLegend('Fats', pilateColor),
//                   ],
//                 ),
//                 SizedBox(
//                   height: height * 0.19,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 30),
//                     child: SfCartesianChart(
//                       margin: EdgeInsets.all(0),
//                       plotAreaBorderWidth: 0.0,
//                       legend: Legend(isVisible: false),
//                       series: <CartesianSeries>[
//                         StackedColumnSeries<ExpenseData, String>(
//                             borderRadius: BorderRadius.circular(50),
//                             color: quickWorkoutColor,
//                             width: periods[currentIndex] == 'Week' ? 0.2 : 0.7,
//                             // dataSource: snapshot.data,
//                             xValueMapper: (ExpenseData exp, _) =>
//                                 exp.expenseCategory,
//                             yValueMapper: (ExpenseData exp, _) => exp.carbs,
//                             markerSettings: MarkerSettings(
//                               isVisible: false,
//                             )),
//                         StackedColumnSeries<ExpenseData, String>(
//                             borderRadius: BorderRadius.circular(50),
//                             color: cyclingColor,
//                             width: periods[currentIndex] == 'Week' ? 0.2 : 0.7,
//                             // dataSource: snapshot.data,
//                             xValueMapper: (ExpenseData exp, _) =>
//                                 exp.expenseCategory,
//                             yValueMapper: (ExpenseData exp, _) => exp.protein,
//                             markerSettings: MarkerSettings(
//                               isVisible: false,
//                             )),
//                         StackedColumnSeries<ExpenseData, String>(
//                             borderRadius: BorderRadius.circular(50),
//                             color: pilateColor,
//                             width: periods[currentIndex] == 'Week' ? 0.2 : 0.7,
//                             // dataSource: snapshot.data,
//                             xValueMapper: (ExpenseData exp, _) =>
//                                 exp.expenseCategory,
//                             yValueMapper: (ExpenseData exp, _) => exp.fat,
//                             markerSettings: MarkerSettings(
//                               isVisible: false,
//                             )),
//                       ],
//                       primaryXAxis: CategoryAxis(
//                         labelAlignment: LabelAlignment.center,
//                         labelPlacement: LabelPlacement.onTicks,
//                         interval: 1,
//                         axisLine: AxisLine(width: 0.0),
//                         placeLabelsNearAxisLine: false,
//                         labelStyle: TextStyle(
//                             color:
//                                 Theme.of(context).colorScheme.primaryContainer),
//                         borderColor:
//                             Theme.of(context).colorScheme.primaryContainer,
//                         majorTickLines: const MajorTickLines(width: 0),
//                         majorGridLines: MajorGridLines(
//                           width: 0.0,
//                         ),
//                       ),
//                       primaryYAxis: CategoryAxis(
//                         isVisible: false,
//                         axisLine: AxisLine(width: 0.0),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLegend(String label, Color color) {
//     return Row(
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: Theme.of(context).colorScheme.primaryContainer,
//             fontSize: 13,
//             fontWeight: AppColor.weight600,
//           ),
//         ),
//         SizedBox(width: 10),
//         Container(
//           decoration: BoxDecoration(
//               color: color, borderRadius: BorderRadius.circular(50)),
//           height: 12,
//           width: 12,
//         ),
//       ],
//     );
//   }

//   Widget _buildErrorWidget(double height, String message) {
//     return SizedBox(
//       height: height * 0.15,
//       child: Center(
//         child: Text(
//           message,
//           style: TextStyle(
//               color: Theme.of(context).colorScheme.secondaryContainer),
//         ),
//       ),
//     );
//   }

// //unused code as per new condition
//   Future<void> popupDevice(
//       BuildContext context, BluetoothDevice device, BleManager bleManager) {
//     print('POPUP Showen');
//     return showModalBottomSheet<void>(
//         context: context,
//         isDismissible: false,
//         builder: (BuildContext context) {
//           final height = MediaQuery.of(context).size.height;
//           final width = MediaQuery.of(context).size.width;
//           return Container(
//             height: height * 0.42,
//             decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(35),
//                     topRight: Radius.circular(35))),
//             child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: width * 0.06,
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(top: 10),
//                           child: Text(
//                             _hivedb.getString('device_name')!,
//                             style: TextStyle(
//                               fontSize: height * 0.035,
//                               fontWeight: FontWeight.w300,
//                               color: const Color.fromARGB(150, 0, 0, 0),
//                               // fontFamily: 'Adventure',
//                             ),
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () async {
//                             Navigator.pop(context);
//                           },
//                           child: Image.asset(
//                             'assets/images/ic_remove.png',
//                             width: width * 0.06,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Container(
//                         height: height * 0.25,
//                         width: width * 0.7,
//                         child: Image.asset(
//                           'assets/images/insulin4D.gif',
//                           // fit: BoxFit.cover,
//                         )),
//                     Center(
//                       child: GestureDetector(
//                         onTap: () {
//                           bleManager.discoverServices(device);
//                           print('AGVA DEVICE $device');

//                           Navigator.pop(context);
//                         },
//                         child: Container(
//                           height: height * 0.05,
//                           width: width * 0.7,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: AppColor.backgroundColor,
//                             border: Border.all(
//                               color: Color.fromARGB(255, 255, 255, 255),
//                             ),
//                           ),
//                           child: Center(
//                               child: Text(
//                             'Connect',
//                             style: TextStyle(
//                                 color: const Color.fromARGB(150, 0, 0, 0),
//                                 fontSize: height * 0.02),
//                           )),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )),
//           );
//         });
//   }

//   void showPopupMenu(BuildContext context) {
//     showMenu(
//       context: context,
//       position: RelativeRect.fromLTRB(80, 180, 20, 0),
//       items: [
//         PopupMenuItem(
//           child: Text(
//             'Battery Info',
//             style: TextStyle(
//               color: Theme.of(context).colorScheme.primary,
//               // fontSize: 14,
//             ),
//           ),
//           onTap: () {
//             setState(() {
//               showBatteryInfo = true;
//             });
//           },
//         ),
//         PopupMenuItem(
//           child: Text(
//             'Insulin Patch',
//             style: TextStyle(
//               color: Theme.of(context).colorScheme.primary,
//               // fontSize: 14,
//             ),
//           ),
//           onTap: () {
//             setState(() {
//               showPatchInfo = true;
//             });
//           },
//         ),
//       ],
//       elevation: 8.0,
//       color: Theme.of(context).colorScheme.secondary,
//     );
//   }

//   Future<void> _addBloodCount() async {
//     final value = await showTopModalSheet<String?>(
//       context,
//       BloodCount(),
//       backgroundColor: Theme.of(context).colorScheme.primary,
//       borderRadius: const BorderRadius.vertical(
//         bottom: Radius.circular(20),
//       ),
//     );

//     if (value != null) setState(() => _topModalData = value);
//   }

//   Future<void> _noDeviceFoundTopModel() async {
//     final value = await showTopModalSheet<String?>(
//       context,
//       NoDeviceFound(),
//       backgroundColor: Theme.of(context).colorScheme.primary,
//       borderRadius: const BorderRadius.vertical(
//         bottom: Radius.circular(20),
//       ),
//     );

//     if (value != null) setState(() => _topModalData = value);
//   }

//   Future<void> _insulintopModel() async {
//     final value = await showTopModalSheet<String?>(
//       context,
//       InsulinTopModel(),
//       backgroundColor: Theme.of(context).colorScheme.primary,
//       borderRadius: const BorderRadius.vertical(
//         bottom: Radius.circular(20),
//       ),
//     );

//     if (value != null) setState(() => _topModalData = value);
//   }
// }

// class InsulinTopModel extends StatelessWidget {
//   const InsulinTopModel({Key? key}) : super(key: key);

//   static const _values = ["CF Cruz Azul", "Monarcas FC"];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(color: const Color.fromARGB(255, 204, 16, 2)),
//       child: Padding(
//         padding: const EdgeInsets.all(18.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               SizedBox(
//                 height: 30,
//               ),
//               Text(
//                 "Insulin battery remaining",
//                 style: TextStyle(
//                     fontSize: 20, color: Theme.of(context).colorScheme.primary),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Text(
//                 "10 %",
//                 style: TextStyle(
//                     fontSize: 35,
//                     color: Theme.of(context).colorScheme.primary,
//                     fontWeight: FontWeight.bold),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 "updated at 10:30 AM ",
//                 style: TextStyle(
//                     fontSize: 15, color: Theme.of(context).colorScheme.primary),
//               ),
//             ]),
//             Icon(
//               Icons.warning_rounded,
//               size: 70,
//               color: Theme.of(context).colorScheme.primary,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// final pilateColor = const Color.fromARGB(255, 255, 0, 92); // Fat
// final cyclingColor = const Color.fromARGB(255, 0, 156, 156); // Protein
// final quickWorkoutColor = const Color.fromARGB(255, 236, 170, 0); // Carbs
// final betweenSpace = 0.2;

// class ExpenseData {
//   ExpenseData(this.expenseCategory, this.carbs, this.protein, this.fat);
//   final String expenseCategory;
//   final num carbs;
//   final num protein;
//   final num fat;

//   factory ExpenseData.fromJson(Map<String, dynamic> json) {
//     return ExpenseData(
//       json['time'],
//       num.parse(json['Carbs']),
//       num.parse(json['Protein']),
//       num.parse(json['Fat']),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int count = 1;

  void increaseCount() {
    if (count < 7) {
      setState(() {
        count++;
      });
    } else {
      context.go('/HomeScreen');
    }
  }

  void decreaseCount() {
    if (count > 1) {
      setState(() {
        count--;
      });
    }   else {
      context.go('/HomeScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(212, 54, 54, 54),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                count == 1
                    ? 'assets/images/1.png'
                    : count == 2
                        ? 'assets/images/2.png'
                        : count == 3
                            ? 'assets/images/3.png'
                            : count == 4
                                ? 'assets/images/4.png'
                                : count == 5
                                    ? 'assets/images/5.png'
                                    : count == 6
                                        ? 'assets/images/6.png'
                                        : count == 7
                                            ? 'assets/images/7.png'
                                            : 'assets/images/7.png',
                height: height * 0.9,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            backgroundColor: const Color.fromARGB(234, 255, 255, 255),
            onPressed: decreaseCount,
            label: Text(
              'Back',
              style: TextStyle(color: Colors.black),
            ),
            icon: Icon(
              CupertinoIcons.arrow_left,
              color: Colors.black,
            ),
          ),
          SizedBox(
            width: 25,
          ),
          FloatingActionButton.extended(
            backgroundColor: const Color.fromARGB(234, 255, 255, 255),
            onPressed: increaseCount,
            label: Text(
              'Next',
              style: TextStyle(color: Colors.black),
            ),
            icon: Icon(
              CupertinoIcons.arrow_right,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
