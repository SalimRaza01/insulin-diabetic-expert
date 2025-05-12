import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../core/services/bluetooth_service_provider.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/graph/basal_graph.dart';
import '../widgets/graph/bolus_graph.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();
class InsulinScreen extends StatefulWidget {
  const InsulinScreen({super.key, BluetoothDevice? agvaDevice});

  @override
  State<InsulinScreen> createState() => _InsulinScreenState();
}

class _InsulinScreenState extends State<InsulinScreen> {
    final BleManager _bleManager = BleManager();
  bool showgraph = false;
  DateTime selectedDate = DateTime.now();
  String formattedstartTime = '';
  Color? activeColor;
  String _selectedText = 'Insulin';
  double? totalBasalunit;
  double? totalBolusunit;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  double? totalDeliveredValue;
  @override
  void initState() {
    super.initState();
    totalBasalunit = double.parse(_hivedb.getString('totalbasalvalue')!);
    totalBolusunit = double.parse(_hivedb.getString('totalbolusvalue')!);
    print(totalBasalunit);
    print(totalBolusunit);

    totalDeliveredValue =
        totalBasalunit! + totalBolusunit!;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, 'refresh');
          },
        ),
      ),
      body: SingleChildScrollView(
        child:Container(
              child: Column(
                children: [
                  Container(
                    width: width,
                    height: height * 0.17,
                    color: Theme.of(context).colorScheme.secondary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            "My Diary",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: height * 0.04,
                                fontWeight: AppColor.weight600),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.04,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            selectedBTN('Meal'),
                            selectedBTN('Insulin'),
                            selectedBTN('Sports'),
                          ],
                        ),
                 
                      ],
                    ),
                  ),
                     
                
                  SizedBox(height: height * 0.03),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(
                            'assets/images/drop.png',
                            height: height * 0.09,
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _bleManager.isDeviceConnected.value == true
                                        ? Icons.check
                                        : Icons.close,
                                    color:             _bleManager.isDeviceConnected.value == true
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                         _bleManager.isDeviceConnected.value == true
                                        ? 'Insulin Pump: Active'
                                        : 'Insulin Pump: Inactive',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        fontSize: height * 0.023,
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.dock_sharp,
                                    size: 30,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                 totalDeliveredValue == null ? '0.0 U' : '${totalDeliveredValue!.toStringAsFixed(2)} U ' ,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        fontSize: height * 0.021,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(width: width * 0.001),
                                  Text('Total Delivered',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                          fontSize: height * 0.020,
                                          fontWeight: FontWeight.w500))
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showgraph = false;
                            });
                          },
                          child: Container(
                            height: height * 0.12,
                            width: width * 0.40,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                border: !showgraph
                                    ? Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      )
                                    : Border.all(
                                        width: 0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(9),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bolus',
                                    style: TextStyle(
                                      fontSize: height * 0.02,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                                  Text(
                                    '${totalBolusunit?.toStringAsFixed(2)} U',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        fontSize: height * 0.025,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    '43%',
                                    style: TextStyle(
                                      fontSize: height * 0.015,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showgraph = true;
                            });
                          },
                          child: Container(
                            height: height * 0.12,
                            width: width * 0.40,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                border: showgraph
                                    ? Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      )
                                    : Border.all(
                                        width: 0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(9),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Basal',
                                    style: TextStyle(
                                      fontSize: height * 0.02,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                                  Text(
                                    '${totalBasalunit?.toStringAsFixed(2)} U',
                                    style: TextStyle(
                                      fontSize: height * 0.025,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    '57%',
                                    style: TextStyle(
                                      fontSize: height * 0.015,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  if (showgraph)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Basalgraph(),
                    ),
                  if (!showgraph)
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Bolusgraph()),
                ],
              ),
            )
      ),
    );
  }

  GestureDetector selectedBTN(text) {
    if (_selectedText == text) {
      activeColor = Colors.green;
    } else {
      activeColor = Colors.transparent;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedText = text;
          print(
              'this is my text $text and this is my selected text $_selectedText');
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: activeColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
          child: Text(
            text,
            style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.height * 0.02,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
