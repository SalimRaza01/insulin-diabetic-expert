import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import '../../core/api/api_service.dart';
import '../../core/api/api_config.dart';
import '../../core/services/bluetooth_service_provider.dart';
import '../widgets/buttoms_widget.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/graph/basal_graph.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();
class BasalHistory {
  final String basal;
  final DateTime starttime;
  final DateTime endtime;

  BasalHistory(
      {required this.basal, required this.starttime, required this.endtime});

  Map<String, dynamic> toJson() => {
        'basal': basal,
        'starttime': starttime,
        'endtime': endtime,
      };

  static BasalHistory fromJson(Map<String, dynamic> json) => BasalHistory(
        basal: json['basal'],
        starttime: DateTime.parse(json['starttime']),
        endtime: DateTime.parse(json['endtime']),
      );
}

class BasalWizard extends StatefulWidget {
  BasalWizard();

  @override
  State<BasalWizard> createState() => _BasalWizardState();
}

class _BasalWizardState extends State<BasalWizard> {
  final BleManager _bleManager = BleManager();
  String char = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  String cmd = 'cm+sync';
  String basalStatus = '';
  String dosage = '';
  bool deliveryStarted = false;
  bool dosageAdded = false;
  TextEditingController dosageController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  FocusNode dosageFocusNode = FocusNode();
  List<BasalHistory> basalHistorylist = [];
  bool isDosageEditable = false;
  late TimeLinkedList timeLinkedList;
  double initialInsulinValue = 0.0;

  void toggleDosageEdit() {
    setState(() {
      isDosageEditable = !isDosageEditable;
      if (isDosageEditable) {
        FocusScope.of(context).requestFocus(dosageFocusNode);
      }
    });
  }

  Future<void> _saveInitialValue(double value) async {
    double updatedValue = initialInsulinValue + value;
    await _hivedb.setDouble('dose', updatedValue);
    print('dosage updated');
    setState(() {
      initialInsulinValue = updatedValue;
    });
  }

  void _loadInitialValue() {
    double? storedValue = _hivedb.getDouble('dose');
    setState(() {
      initialInsulinValue = storedValue ?? 0.0;
      print(initialInsulinValue);
    });
  }

  Future<void> _loadbasalHistory() async {
    final String? doseHistoryString = _hivedb.getString('basalHistorylist');
    if (doseHistoryString != null) {
      final List<dynamic> doseHistoryJson = jsonDecode(doseHistoryString);
      print('history $doseHistoryString');
      setState(() {
        basalHistorylist =
            doseHistoryJson.map((json) => BasalHistory.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveBasalHistory() async {
    final String doseHistoryString =
        jsonEncode(basalHistorylist.map((entry) => entry.toJson()).toList());
    await _hivedb.putString('basalHistorylist', doseHistoryString);
  }

  Future<void> _deleteSharedPreference() async {
    await _hivedb.remove('basalHistorylist');
    _notifyUser('History Deleted');
  }

  void _notifyUser(String message) {
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

  @override
  void initState() {
    super.initState();
    getBasalData;
    _loadbasalHistory();
    _loadInitialValue();
    timeLinkedList = TimeLinkedList((bool status) {
      setState(() {
        deliveryStarted = status;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      timeLinkedList.callFunctionsBetween(
          DateTime.now(), DateTime.now().add(Duration(hours: 24)));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Duration calculateTime() {
    return endtime!.difference(starttime!);
  }

  // void addInterval(DateTime startTime, DateTime endTime)  {
  //   String dosage = dosageController.text;
  //   timeLinkedList.insert(startTime, endTime, dosage);

  // }

  void startResendTimer() {
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
          print('Delivering Basal Unit $dosage');
        } else {
          print('Basal Delivered');
          timer.cancel();
        }
      });
    });
  }

  late Timer _resendTimer;
  int remainingTime = 0;
  DateTime? starttime;
  DateTime? endtime;
  DateTime? writingStartTime;
  DateTime? writingEndTime;
  DateTime dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return ValueListenableBuilder(
        valueListenable: _bleManager.isDeviceConnected,
        builder:
            (BuildContext context, dynamic isDeviceConnected, Widget? child) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            drawer: AppDrawerNavigation('INSULIN'),
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              // actions: <Widget>[
              //   IconButton(
              //     icon: Icon(
              //       size: 30,
              //       Icons.history,
              //       color: Colors.white,
              //     ),
              //     tooltip: 'History',
              //     onPressed: () {
              //       _loadbasalHistory();
              //       basalHistorylist.isNotEmpty
              //           ? showModalBottomSheet(
              //               context: context,
              //               builder: (context) {
              //                 return Popover(
              //                   height: height * 0.6,
              //                   child: StatefulBuilder(
              //                     builder: (BuildContext context, setState) {
              //                       return Padding(
              //                         padding: const EdgeInsets.all(5.0),
              //                         child: Column(
              //                           children: [
              //                             SizedBox(
              //                               height: height * 0.01,
              //                             ),
              //                             Row(
              //                               mainAxisAlignment:
              //                                   MainAxisAlignment.spaceBetween,
              //                               children: [
              //                                 Text(
              //                                   "Basal History",
              //                                   style: TextStyle(
              //                                       color: Theme.of(context)
              //                                           .colorScheme
              //                                           .onInverseSurface,
              //                                       fontWeight: FontWeight.bold,
              //                                       fontSize: height * 0.02),
              //                                 ),
              //                                 IconButton(
              //                                   onPressed: () {
              //                                     setState(
              //                                       () {
              //                                         _deleteSharedPreference();
              //                                       },
              //                                     );
              //                                     Navigator.pop(context);
              //                                   },
              //                                   icon: Icon(
              //                                     Icons.delete,
              //                                     color: Theme.of(context)
              //                                         .colorScheme
              //                                         .onInverseSurface,
              //                                   ),
              //                                 )
              //                               ],
              //                             ),
              //                             SizedBox(
              //                               height: height * 0.01,
              //                             ),
              //                             // if (basalHistorylist.isNotEmpty)
              //                             Row(
              //                               mainAxisAlignment:
              //                                   MainAxisAlignment.spaceAround,
              //                               children: [
              //                                 Text(
              //                                   'Dosage',
              //                                   style: TextStyle(
              //                                     color: Theme.of(context)
              //                                         .colorScheme
              //                                         .onInverseSurface,
              //                                   ),
              //                                 ),
              //                                 SizedBox(
              //                                   width: width * 0.02,
              //                                 ),
              //                                 Text(
              //                                   'Start Time',
              //                                   style: TextStyle(
              //                                     color: Theme.of(context)
              //                                         .colorScheme
              //                                         .onInverseSurface,
              //                                   ),
              //                                 ),
              //                                 Text(
              //                                   'End Time',
              //                                   style: TextStyle(
              //                                     color: Theme.of(context)
              //                                         .colorScheme
              //                                         .onInverseSurface,
              //                                   ),
              //                                 )
              //                               ],
              //                             ),
              //                             SizedBox(
              //                               height: height * 0.012,
              //                             ),
              //                             SizedBox(
              //                               width: width,
              //                               child: Divider(
              //                                 thickness: 1,
              //                                 color: Colors.grey,
              //                               ),
              //                             ),
              //                             Container(
              //                               height: height * 0.375,
              //                               width: width * 0.813,
              //                               child: ListView.builder(
              //                                 itemCount: basalHistorylist.length,
              //                                 itemBuilder: (BuildContext context,
              //                                     int index) {
              //                                   final entry =
              //                                       basalHistorylist[index];
              //                                   final formattedstartTime =
              //                                       DateFormat('HH:mm')
              //                                           .format(entry.starttime);
              //                                   final formattedendTime =
              //                                       DateFormat('HH:mm ')
              //                                           .format(entry.endtime);
              //                                   return ListTile(
              //                                     trailing: Text(
              //                                       "${formattedstartTime}               ${formattedendTime}",
              //                                       style: TextStyle(
              //                                           color: Colors.green,
              //                                           fontSize: 15),
              //                                     ),
              //                                     title: Text(
              //                                       "${entry.basal} Unit",
              //                                       style: TextStyle(
              //                                         color: Theme.of(context)
              //                                             .colorScheme
              //                                             .onInverseSurface,
              //                                       ),
              //                                     ),
              //                                   );
              //                                 },
              //                               ),
              //                             )
              //                           ],
              //                         ),
              //                       );
              //                     },
              //                   ),
              //                 );
              //               },
              //             )
              //           : _notifyUser('No History Found');
              //     },
              //   ),
              // ],
              backgroundColor: Theme.of(context).colorScheme.secondary,
              bottom: isDeviceConnected == false
                  ? PreferredSize(
                      preferredSize: Size.fromHeight(35),
                      child: Container(
                        height: 35,
                        color: Colors.redAccent,
                        child: Center(
                          child: Text(
                            'DEVICE NOT CONNECTED',
                            style: TextStyle(
                              fontSize: height * 0.015,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                      ),
                    )
                  : PreferredSize(
                      preferredSize: Size.fromHeight(0),
                      child: deliveryStarted
                          ? Stack(
                              children: <Widget>[
                                SizedBox(
                                  height: 20,
                                  child: LinearProgressIndicator(
                                    backgroundColor:
                                        const Color.fromARGB(255, 239, 179, 0),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.yellow),
                                  ),
                                ),
                                Align(
                                  child: Text(
                                    "BASAL DELIVERING..",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  alignment: Alignment.topCenter,
                                ),
                              ],
                            )
                          : SizedBox()),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basal Wizard',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: height * 0.03),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Basalgraph(),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        SizedBox(
                          child: Text(
                            'Basal Wizard automatically calculate the recommended dosage of insulin based on your meal intake',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontSize: height * 0.012),
                          ),
                          width: width * 0.8,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    AnimatedContainer(
                      height: dosageAdded ? height * 0.045 : height * 0.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green,
                      ),
                      duration: Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              basalStatus,
                              style: TextStyle(
                                fontSize: dosageAdded ? height * 0.015 : 0.0,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            // Text(
                            //   'Dose $dosage units',
                            //   style: TextStyle(
                            //       fontSize: dosageAdded ? height * 0.015 : 0.0),
                            // ),
                            // Text(
                            //     'Time : ${startTimeController.text} to ${endTimeController.text}'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    isDeviceConnected == true
                        ? GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    height: 350,
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      endTimeController.clear();
                                                    },
                                                    child: Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                    )),
                                                Text(
                                                  "SELECT START TIME",
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 15),
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        startTimeController
                                                                .text =
                                                            "${starttime!.hour}:${starttime!.minute}";
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: Icon(Icons.done,
                                                        color: Colors.green)),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 320,
                                            child: Divider(
                                              thickness: 1,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Container(
                                            height: 200,
                                            child: CupertinoDatePicker(
                                            initialDateTime: DateTime.now(),
                                                mode: CupertinoDatePickerMode
                                                    .time,
                                                use24hFormat: true,
                                                showDayOfWeek: true,
                                                minimumDate: DateTime.now(),
                                                onDateTimeChanged:
                                                    (DateTime newDate) {
                                                  starttime = newDate;
                                                }),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                                height: height * 0.055,
                                width: width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Start Time',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            fontSize: height * 0.018),
                                      ),
                                      Icon(
                                        Icons.info_outline,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                      SizedBox(
                                          width: width * 0.3,
                                          child: Center(
                                            child: Text(
                                              startTimeController.text.isEmpty
                                                  ? '0.0'
                                                  : startTimeController.text,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface,
                                                  fontSize: height * 0.02),
                                            ),
                                          )),
                                      // Container(
                                      //   height: double.infinity,
                                      //   width: width * 0.001,
                                      //   color: Colors.grey,
                                      // ),
                                      // SizedBox(
                                      //   child: Icon(
                                      //     Icons.edit,
                                      //     color: Theme.of(context)
                                      //         .colorScheme
                                      //         .tertiary,
                                      //   ),
                                      //   height: height * 0.01,
                                      // ),
                                    ],
                                  ),
                                )),
                          )
                        : inActiveTextFields(context, 'Start Time', height),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    isDeviceConnected == true
                        ? InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    height: 350,
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      endTimeController.clear();
                                                    },
                                                    child: Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                    )),
                                                Text(
                                                  "SELECT END TIME",
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 15),
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        // setDate = endtime;
                                                        endTimeController.text =
                                                            "${endtime!.hour}:${endtime!.minute}";
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: Icon(Icons.done,
                                                        color: Colors.green)),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 320,
                                            child: Divider(
                                              thickness: 1,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Container(
                                            height: 200,
                                            child: CupertinoDatePicker(
                                                initialDateTime: DateTime.now(),
                                                mode: CupertinoDatePickerMode
                                                    .time,
                                                use24hFormat: true,
                                                showDayOfWeek: true,
                                                minimumDate: DateTime.now(),
                                                onDateTimeChanged:
                                                    (DateTime newDate) {
                                                  endtime = newDate;
                                                }),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                                height: height * 0.055,
                                width: width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'End Time ',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            fontSize: height * 0.018),
                                      ),
                                      Icon(
                                        Icons.info_outline,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                      SizedBox(
                                          width: width * 0.3,
                                          child: Center(
                                            child: Text(
                                              endTimeController.text.isEmpty
                                                  ? '0.0'
                                                  : endTimeController.text,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface,
                                                  fontSize: height * 0.02),
                                            ),
                                          )),
                                      // Container(
                                      //   height: double.infinity,
                                      //   width: width * 0.001,
                                      //   color: Colors.grey,
                                      // ),
                                      // SizedBox(
                                      //   child: Icon(
                                      //     Icons.edit,
                                      //     color: Theme.of(context)
                                      //         .colorScheme
                                      //         .tertiary,
                                      //   ),
                                      //   height: height * 0.02,
                                      // ),
                                    ],
                                  ),
                                )),
                          )
                        : inActiveTextFields(context, 'End Time', height),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    isDeviceConnected == true
                        ? Container(
                            height: height * 0.055,
                            width: width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Dosage    ',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        fontSize: height * 0.018),
                                  ),
                                  Icon(
                                    Icons.info_outline,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary,
                                  ),
                                  SizedBox(
                                    width: width * 0.3,
                                    child: TextField(
                                      cursorColor: Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface,
                                      selectionControls:
                                          CupertinoTextSelectionControls(),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onInverseSurface),
                                      focusNode: dosageFocusNode,
                                      controller: dosageController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                  
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '0.0',
                                          hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onInverseSurface,
                                          )),
                                    ),
                                  ),
                                  // Container(
                                  //   height: double.infinity,
                                  //   width: width * 0.001,
                                  //   color: Colors.grey,
                                  // ),
                                  // GestureDetector(
                                  //   onTap: () {
                        
                                  //   },
                                  //   child: SizedBox(
                                  //     child: Icon(
                                  //       Icons.edit,
                                  //       color:
                                  //           Theme.of(context).colorScheme.tertiary,
                                  //     ),
                                  //     height: height * 0.02,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ))
                        : inActiveTextFields(context, 'Dosage', height),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Center(
                      child: isDeviceConnected == true && startTimeController.text.isNotEmpty && endTimeController.text.isNotEmpty && dosageController.text.isNotEmpty
                          ? Buttons(
                              action: () async {
                                DateTime writingStartTime =
                                    DateTime.parse(starttime.toString());
                                DateTime writingEndTime =
                                    DateTime.parse(endtime.toString());

                                _bleManager.readOrWriteCharacteristic(
                                    char, cmd, false);

                                await addBasal(endTimeController.text,
                                    dosageController.text, context);

                                _saveInitialValue(
                                    double.parse(dosageController.text));

                                Future.delayed(Duration(seconds: 2), () {
                                  print('wrriting into BLE');
                                  _bleManager.readOrWriteCharacteristic(
                                      char, cmd, true);

                                  print('wrriting into BLE 2');

                                  timeLinkedList.insert(
                                      writingStartTime, writingEndTime, dosage);

                                  timeLinkedList.callFunctionsBetween(
                                      writingStartTime, writingEndTime);
                                });

                                setState(() {
                                  basalHistorylist.add(BasalHistory(
                                      basal: dosage,
                                      starttime: writingStartTime,
                                      endtime: writingEndTime));
                                });

                                _saveBasalHistory();

                                setState(() {
                                  dosageAdded = true;
                                  dosage = dosageController.text;
                                });

                                if (dosageAdded == true) {
                                  Future.delayed(Duration(seconds: 1), () {
                                    setState(() {
                                      basalStatus =
                                          'Basal Delivery Added to Queue';
                                    });
                                  });

                                  Future.delayed(Duration(seconds: 3), () {
                                    final int minutesUntilNextDelivery =
                                        writingStartTime
                                            .difference(DateTime.now())
                                            .inMinutes;
                                    setState(() {
                                      basalStatus =
                                          'Next basal delivery in $minutesUntilNextDelivery minutes';
                                    });
                                  });

                                  Future.delayed(Duration(seconds: 5), () {
                                    setState(() {
                                      dosageAdded = false;
                                      basalStatus = '';
                                    });
                                  });
                                  startTimeController.clear();
                                  endTimeController.clear();
                                  dosageController.clear();
                            
                                }
                              },
                              title: 'SUBMIT',
                            )
                          : Container(
                              height: height * 0.06,
                              width: width * 0.6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromARGB(76, 158, 158, 158),
                              ),
                              child: Center(
                                  child: Text(
                                'SUBMIT',
                                style: TextStyle(
                                    color: Color.fromARGB(77, 255, 255, 255),
                                    fontSize: height * 0.02),
                              )),
                            ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  inActiveTextFields(BuildContext context, String title, double height) {
    return Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(76, 158, 158, 158),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: Color.fromARGB(77, 255, 255, 255), fontSize: 16),
              ),
              Icon(
                Icons.info_outline,
                color: Color.fromARGB(77, 255, 255, 255),
              ),
              SizedBox(
                width: 100,
                height: 30,
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  height: 40,
                  width: 2,
                  color: Color.fromARGB(77, 255, 255, 255),
                ),
              ),
              SizedBox(
                child: Icon(
                  Icons.edit,
                  color: Color.fromARGB(77, 255, 255, 255),
                ),
              ),
            ],
          ),
        ));
  }
}

class TimeNode {
  final DateTime startTime;
  final DateTime endTime;
  final String dosage;
  TimeNode? next;

  TimeNode(this.startTime, this.endTime, this.dosage);
}

class TimeLinkedList {
  TimeNode? head;
  late Timer _resendTimer;
  int remainingTime = 0;

  // Add a callback function to update state
  final Function(bool) updateStatusCallback;

  TimeLinkedList(this.updateStatusCallback);

  void insert(DateTime startTime, DateTime endTime, String dosage) {
    print('Calling 22');
    TimeNode newNode = TimeNode(startTime, endTime, dosage);
    if (head == null) {
      head = newNode;
    } else {
      TimeNode current = head!;
      while (current.next != null) {
        current = current.next!;
      }
      current.next = newNode;
    }
    updateStatusCallback(false); // Use callback to update state
  }

  void callFunctionsBetween(DateTime rangeStart, DateTime rangeEnd) {
    print('Calling 1');
    TimeNode? current = head;
    while (current != null) {
      DateTime now = DateTime.now();
      Duration initialDelay =
          rangeStart.isAfter(now) ? rangeStart.difference(now) : Duration.zero;

      Timer(initialDelay, () {
        print('Basal Delivery Started');
        updateStatusCallback(true);

        Timer.periodic(Duration(seconds: 1), (Timer timer) {
          print('Delivering Basal Unit');
          DateTime currentTime = DateTime.now();
          if (currentTime.isAfter(rangeEnd)) {
            timer.cancel();
            updateStatusCallback(false);
            print('Basal Delivery Ended');
          }
          return;
        });
      });
      current = current.next;
    }
  }
}
