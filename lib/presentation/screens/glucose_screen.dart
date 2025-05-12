import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:INSUL/data/models/nutrition_donut_model.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';
import '../../core/api/api_service.dart';
import '../../core/api/nutrition_middleware.dart';
import '../../core/api/api_config.dart';
import '../../core/services/bluetooth_service_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/glucose_provider.dart';
import 'home_screen.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();
class ChartDataInfo {
  ChartDataInfo(this.time, this.value, [this.color]);

  final String time;
  final double value;
  final Color? color;
}

final List<ChartDataInfo> data24Hours = List.generate(
  24,
  (index) => ChartDataInfo(
      index.toString(), (index + 1) * 5.0, AppColor.glucoseChartColor),
);

class GlucoseScreen extends StatefulWidget {

  @override
  State<GlucoseScreen> createState() => _GlucoseScreenState();
}

class _GlucoseScreenState extends State<GlucoseScreen> {
  TextEditingController enterBgcontroller = TextEditingController();
  Future<List<NutritionDonutDataItem>>? _nutritionDonutData;
  final BleManager _bleManager = BleManager();
  String currentView = "enterbg";
  bool navigate = false;
  bool deviceStatus = false;
  String glucose = '2.0';
  String _selectedtext = 'Day';
  Color? activeColor;
  String selected = 'Day';
  int touchedIndex = -1;
  bool show = true;

  @override
  void initState() {
    super.initState();
    _nutritionDonutData = fetchNutritionDonutData('TODAY');
  }

  FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    enterBgcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            Visibility(
              visible: show,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: height * 0.032,
                        width: width * 0.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.green,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: Text(
                              'INSUL CONNECTED',
                              style: TextStyle(
                                fontSize: height * 0.015,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Visibility(
                      visible: currentView != 'enterbg',
                      child: Center(
                        child: Text(
                          'Nutrition Data',
                          style: TextStyle(fontSize: 25, color: Colors.white),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: currentView != 'enterbg',
                      child: FutureBuilder<List<NutritionDonutDataItem>>(
                          future: _nutritionDonutData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return emptyUi(height, width);
                            } else if (snapshot.hasError) {
                              return emptyUi(height, width);
                            } else if (!snapshot.hasData) {
                              return emptyUi(height, width);
                            } else {
                              final items = snapshot.data!;

                              return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    for (var item in snapshot.data!)
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            height: height * 0.23,
                                            width: width * 0.35,
                                            child: PieChart(
                                              PieChartData(
                                                pieTouchData: PieTouchData(
                                                  touchCallback:
                                                      (FlTouchEvent event,
                                                          pieTouchResponse) {
                                                    setState(() {
                                                      if (!event
                                                              .isInterestedForInteractions ||
                                                          pieTouchResponse ==
                                                              null ||
                                                          pieTouchResponse
                                                                  .touchedSection ==
                                                              null) {
                                                        touchedIndex = -1;
                                                        return;
                                                      }
                                                      touchedIndex =
                                                          pieTouchResponse
                                                              .touchedSection!
                                                              .touchedSectionIndex;
                                                    });
                                                  },
                                                ),
                                                borderData: FlBorderData(
                                                  show: false,
                                                ),
                                                sectionsSpace: 0,
                                                centerSpaceRadius:
                                                    height * 0.06,
                                                sections: List.generate(4, (i) {
                                                  final isTouched =
                                                      i == touchedIndex;
                                                  final fontSize =
                                                      isTouched ? 0.0 : 0.0;
                                                  final radius =
                                                      isTouched ? 30.0 : 25.0;
                                                  const shadows = [
                                                    Shadow(
                                                        color: Colors.black,
                                                        blurRadius: 2)
                                                  ];
                                                  switch (i) {
                                                    case 0:
                                                      return PieChartSectionData(
                                                        color:
                                                            AppColor.fatColor,
                                                        value: item.totalFat!
                                                            .toDouble(),
                                                        // title: '10%',
                                                        radius: radius,
                                                        titleStyle: TextStyle(
                                                          fontSize: fontSize,
                                                          color:
                                                              AppColor.fatColor,
                                                        ),
                                                      );
                                                    case 1:
                                                      return PieChartSectionData(
                                                        color:
                                                            AppColor.carbsColor,
                                                        value: item.totalCarbs!
                                                            .toDouble(),
                                                        // title: '45%',
                                                        radius: radius,
                                                        titleStyle: TextStyle(
                                                          fontSize: fontSize,
                                                          color: AppColor
                                                              .carbsColor,
                                                        ),
                                                      );
                                                    case 2:
                                                      return PieChartSectionData(
                                                        color: AppColor
                                                            .proteinColor,
                                                        value: item
                                                            .totalProtein!
                                                            .toDouble(),
                                                        // title: '25%',
                                                        radius: radius,
                                                        titleStyle: TextStyle(
                                                          fontSize: fontSize,
                                                          color: AppColor
                                                              .proteinColor,
                                                        ),
                                                      );
                                                    case 3:
                                                      return PieChartSectionData(
                                                        color:
                                                            AppColor.kcalColor,
                                                        value: item
                                                            .totalCalories!
                                                            .toDouble(),
                                                        // title: '20%',
                                                        radius: radius,
                                                        titleStyle: TextStyle(
                                                          fontSize: fontSize,
                                                          color: AppColor
                                                              .kcalColor,
                                                        ),
                                                      );
                                                    default:
                                                      throw Error();
                                                  }
                                                }),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '${item.totalCalories.toString()}',
                                                style: TextStyle(
                                                  fontSize: height * 0.025,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                'Total kcal',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: height * 0.015,
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    for (var item in snapshot.data!)
                                      SizedBox(
                                        height: height * 0.2,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            DataContainer(
                                                color: AppColor.kcalColor,
                                                title: 'Calories',
                                                percentage: item.totalCalories
                                                    .toString()),
                                            DataContainer(
                                                color: AppColor.proteinColor,
                                                title: 'Protein',
                                                percentage: item.totalProtein
                                                    .toString()),
                                            DataContainer(
                                                color: AppColor.fatColor,
                                                title: 'Fats',
                                                percentage:
                                                    item.totalFat.toString()),
                                            DataContainer(
                                                color: AppColor.carbsColor,
                                                title: 'Carbs',
                                                percentage:
                                                    item.totalCarbs.toString())
                                          ],
                                        ),
                                      )
                                  ]);
                            }
                          }),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: currentView == "enterbg" ? height * 0.65 : height * 0.45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: currentView == "enterbg"
                      ? enterbg(height, width, context)
                      : calculatedInsulValue(height, width, context),
                ),
              ),
            ),
          ],
        ),
      );
  }

  Row emptyUi(double height, double width) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: height * 0.23,
            width: width * 0.35,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: height * 0.06,
                sections: List.generate(4, (i) {
                  final isTouched = i == touchedIndex;
                  final fontSize = isTouched ? 0.0 : 0.0;
                  final radius = isTouched ? 30.0 : 25.0;
                  const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
                  switch (i) {
                    case 0:
                      return PieChartSectionData(
                        color: Color.fromARGB(255, 188, 188, 188),
                        value: 100,
                        // title: '10%',
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          color: Colors.white,
                        ),
                      );
                    case 1:
                      return PieChartSectionData(
                        color: const Color.fromARGB(255, 234, 181, 24),
                        value: 0,
                        // title: '45%',
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          color: const Color.fromARGB(255, 234, 181, 24),
                        ),
                      );
                    case 2:
                      return PieChartSectionData(
                        color: Color.fromARGB(255, 51, 147, 226),
                        value: 0,
                        // title: '25%',
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          color: Color.fromARGB(255, 51, 147, 226),
                        ),
                      );
                    case 3:
                      return PieChartSectionData(
                        color: Color.fromARGB(255, 233, 110, 255),
                        value: 0,
                        // title: '20%',
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          color: Color.fromARGB(255, 233, 110, 255),
                        ),
                      );
                    default:
                      throw Error();
                  }
                }),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                '0.0',
                style: TextStyle(
                  fontSize: height * 0.025,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Total kcal',
                style: TextStyle(
                  fontSize: height * 0.015,
                  color: Colors.white,
                ),
              )
            ],
          )
        ],
      ),
      SizedBox(
        height: height * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DataContainer(
                color: AppColor.kcalColor, title: 'Calories', percentage: '0'),
            DataContainer(
                color: AppColor.proteinColor,
                title: 'Protein',
                percentage: '0'),
            DataContainer(
                color: AppColor.fatColor, title: 'Fats', percentage: '0'),
            DataContainer(
                color: AppColor.carbsColor, title: 'Carbs', percentage: '0'),
          ],
        ),
      )
    ]);
  }

  Widget enterbg(double height, double width, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'BLOOD GLUCOSE',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w200,
                    color: Color.fromARGB(255, 59, 58, 58),
                  ),
                ),
                SizedBox(height: height * 0.04),
                Image.asset(
                  'assets/images/BG.png',
                  height: 100,
                ),
                Container(
                  height: height * 0.05,
                  width: width * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromARGB(255, 242, 242, 247),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      focusNode: _focusNode,
                      style: TextStyle(color: Color.fromARGB(255, 59, 58, 58)),
                      controller: enterBgcontroller,
                       readOnly: true,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        suffixText: 'mg/dl',
                        border: InputBorder.none,
                        hintText: 'ENTER BG VALUE',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: Color.fromARGB(255, 59, 58, 58),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.03),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        // navigate = true;
                        currentView = "calculatedInsulValue";
                      });
                    },
                    child: Container(
                      height: height * 0.05,
                      width: width * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 5, 53, 93),
                      ),
                      child: Center(
                          child: Text(
                        'NEXT',
                        style: TextStyle(
                            color: Colors.white, fontSize: height * 0.015),
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
            ),
            child: VirtualKeyboard(
               height: height * 0.25,
                //width: 500,
                textColor: Colors.black,
                textController: enterBgcontroller,
                //customLayoutKeys: _customLayoutKeys,
                defaultLayouts: [
                  VirtualKeyboardDefaultLayouts.Arabic,
                  VirtualKeyboardDefaultLayouts.English
                ],
                //reverseLayout :true,
                type: VirtualKeyboardType.Numeric,
              ),
          )
        ],
      ),
    );
  }

  Widget calculatedInsulValue(
      double height, double width, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: () {
                    setState(() {
                      currentView = 'enterbg';
                    });
                  },
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Color.fromARGB(255, 100, 100, 100),
                  )),
              Text(
                'INSULIN VALUE',
                style: TextStyle(
                  fontSize: height * 0.03,
                  fontWeight: FontWeight.w200,
                  color: Color.fromARGB(255, 59, 58, 58),
                ),
              ),
              SizedBox(
                height: height * 0.02,
              ),
            ],
          ),
          Image.asset(
            'assets/images/drop.png',
            height: height * 0.12,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: '2.0',
                    style: TextStyle(
                        fontSize: height * 0.04,
                        color: Color.fromARGB(255, 100, 100, 100),
                        fontWeight: AppColor.weight600)),
                TextSpan(
                    text: " unit",
                    style:
                        TextStyle(color: Colors.black, fontSize: height * 0.02))
              ],
            ),
          ),
          SizedBox(
            height: height * 0.01,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  show = false;
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainScreenGlucose()));
              },
              child: Container(
                height: height * 0.05,
                width: width * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 5, 53, 93),
                  border: Border.all(
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                child: Center(
                    child: Text(
                  'NEXT',
                  style:
                      TextStyle(color: Colors.white, fontSize: height * 0.015),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataContainer extends StatelessWidget {
  final Color color;
  final String title;
  final String percentage;
  dynamic mediaQuery;

  DataContainer({
    required this.color,
    required this.title,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        // border: Border.all(
        //   color: Colors.grey,
        //   width: 0.2,
        // ),
      ),
      height: height * 0.025,
      width: width * 0.40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.circle,
                color: color,
                size: 10,
              ),
              SizedBox(
                width: width * 0.01,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: height * 0.02,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(
            width: width * 0.02,
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: height * 0.02,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}

class MainScreenGlucose extends StatefulWidget {
  const MainScreenGlucose({super.key});

  @override
  State<MainScreenGlucose> createState() => _MainScreenGlucoseState();
}

class _MainScreenGlucoseState extends State<MainScreenGlucose> {
  TextEditingController enterBgcontroller = TextEditingController();
  Future<List<NutritionDonutDataItem>>? _nutritionDonutData;
  String currentView = "enterbg";
  bool navigate = false;
  String _selectedtext = 'Day';
  Color? activeColor;
  String selected = 'Day';
  int touchedIndex = -1;
  String glucose = '4.0';
  List<ChartDataInfo> chartData = [];
  int currentIndex = 0;
  String? totaldeliveredDosage;
  double initialInsulinValue = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchChartData('Day');
    _loadInitialValue();
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
      print('initial value $initialInsulinValue');
    });
  }

  Future<void> _fetchChartData(String period) async {
    final dio = Dio();
    String? filter;

    if (period == "Day") {
      filter = 'today';
    } else if (period == "Month") {
      filter = '30days-data';
    } else if (period == "Year") {
      filter = '12month-data';
    }

    print(period.toLowerCase());
    final String? userId = await _hivedb.getString('userId');
    print(userId);
    final response = await dio.get(
      '$gluCoseData/$userId',
      queryParameters: {'filter': filter},
    );
    print(response);
    if (response.statusCode == 200) {
      final data = response.data['data'];

      setState(() {
        chartData = data.map<ChartDataInfo>((item) {
          return ChartDataInfo(
            item['time'],
            double.parse(item['unit']),
            AppColor.glucoseChartColor,
          );
        }).toList();

        double deliveredDosage =
            chartData.fold(0, (sum, item) => sum + item.value);
        print('this is my Basal units $deliveredDosage');
        _hivedb.putString(
            'totalDeliveredDosage', deliveredDosage.toString());

        totaldeliveredDosage =
            _hivedb.getString('totalDeliveredDosage');
      });
    } else {
      print('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
            height: height,
            width: width,
            color: Theme.of(context).colorScheme.onPrimary,
            child: Column(children: [
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30))),
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("My Glucose",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: height * 0.03)),
                          Image.asset(
                            'assets/images/heart.png',
                            height: height * 0.05,
                            // width: width * 0.1,
                            // height: 50,
                          )
                        ],
                      ),
                      SizedBox(height: height * 0.02),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                selectedBUtton('Day'),
                                selectedBUtton('Month'),
                                selectedBUtton('Year'),
                              ],
                            ),
                            SizedBox(height: height * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (selected == 'Day')
                                  Text("06:20 pm",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: height * 0.03)),
                                if (selected == 'Month' || selected == 'Year')
                                  Text("Highest",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: height * 0.03)),
                                Text("Average",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: height * 0.03)),
                              ],
                            ),
                            SizedBox(height: height * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      if (selected == 'Day')
                                        TextSpan(
                                            text: "5.7",
                                            style: TextStyle(
                                                fontSize: height * 0.04,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      if (selected == 'Month' ||
                                          selected == 'Year')
                                        TextSpan(
                                            text: "8.5",
                                            style: TextStyle(
                                                fontSize: height * 0.04,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: " mg/dl",
                                          style: TextStyle(
                                              fontSize: height * 0.02,
                                              color: Colors.white))
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: "7.1",
                                          style: TextStyle(
                                              fontSize: height * 0.04,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: " mg/dl",
                                          style: TextStyle(
                                              fontSize: height * 0.02,
                                              color: Colors.white))
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (selected == 'Day') dayContainer(),
              if (selected == 'Month') monthContainer(),
              if (selected == 'Year') yearlyContainer(),
              SizedBox(
                height: height * 0.03,
              ),
              Visibility(
                visible: selected == 'Day',
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return BottomSheet(
                                onClosing: () {},
                                builder: (BuildContext context) {
                                  return Container(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    height: height * 0.32,
                                    width: width,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                "CALCULATED INSULIN",
                                                style: TextStyle(
                                                    fontSize: height * 0.02,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onInverseSurface),
                                              ),
                                              SizedBox(
                                                height: height * 0.03,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(Icons
                                                            .water_drop_outlined),
                                                        SizedBox(
                                                          width: width * .05,
                                                        ),
                                                        Text("Insulin dosage",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    height *
                                                                        0.02,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onInverseSurface)),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: width * 0.01,
                                                    ),
                                                    Text("$glucose units",
                                                        style: TextStyle(
                                                            fontSize:
                                                                height * 0.025,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onInverseSurface))
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: height * 0.02,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      child: Icon(
                                                        Icons.info_outline,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .tertiary,
                                                      ),
                                                      height: height * 0.02,
                                                    ),
                                                    SizedBox(
                                                      width: width * 0.055,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'Basal Wizard automatically calculate the recommended dosage of insulin based on your meal intake',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .tertiary,
                                                            fontSize:
                                                                height * 0.012),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                _saveInitialValue(
                                                    enterBgcontroller
                                                            .text.isEmpty
                                                        ? double.parse(glucose)
                                                        : double.parse(
                                                            enterBgcontroller
                                                                .text));

                                                 addGlucoseUnit(
                                                    enterBgcontroller
                                                            .text.isEmpty
                                                        ? glucose
                                                        : enterBgcontroller
                                                            .text,
                                                    context);

                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                height: height * 0.05,
                                                width: width * 0.4,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                                child: Center(
                                                    child: Text(
                                                  'INFUSE DOSAGE',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: height * 0.015),
                                                )),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        child: Text(
                          'DELIVER DOSAGE',
                          style: TextStyle(
                              color: Colors.white, fontSize: height * 0.016),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ])),
      ),
    );
  }

  dayContainer() {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Consumer<GlucoseDelivery>(builder: (context, value, child) {
      if (value.glucoseStatus == true) {
        _fetchChartData('Day');
      }
      return Container(
        color: Theme.of(context).colorScheme.onPrimary,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/star.png',
                    width: MediaQuery.of(context).size.height * 0.02,
                    height: MediaQuery.of(context).size.width * 1,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  Text(
                    "Glucose in Range | Going down",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onInverseSurface),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.01,
                ),
                Text(
                  "Inrange",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onInverseSurface),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                Icon(
                  Icons.circle,
                  color: Colors.amber,
                  size: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.01,
                ),
                Text(
                  "High",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onInverseSurface),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.03,
                ),
                Icon(
                  Icons.circle,
                  color: Colors.red,
                  size: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.03,
                ),
                Text(
                  "Low",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onInverseSurface),
                ),
              ],
            ),
            Container(
              height: height * 0.23,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: SfCartesianChart(
                tooltipBehavior: TooltipBehavior(
                  shouldAlwaysShow: true,
                  canShowMarker: true,
                  format: 'point.y Kg',
                  shared: true,
                  duration: 1000,
                  enable: true,
                  color: Theme.of(context).colorScheme.onPrimary,
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    fontSize: height * 0.013,
                  ),
                ),
                plotAreaBorderWidth: 0.0,
                primaryXAxis: CategoryAxis(
                  axisLine: AxisLine(color: Colors.grey),
                  majorTickLines: MajorTickLines(color: Colors.grey),
                  labelRotation: 0,
       interval: 2,
                  minimum: 0,
                  majorGridLines: MajorGridLines(width: 0),
                  labelStyle: TextStyle(
                    fontSize: 8,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  axisLine: AxisLine(color: Colors.grey),
                  majorTickLines: MajorTickLines(color: Colors.grey),
          
                  majorGridLines: MajorGridLines(width: 0),
                  labelStyle: TextStyle(
                    fontSize: 8,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
                series: <CartesianSeries<dynamic, dynamic>>[
                  ColumnSeries<ChartDataInfo, String>(
                    width: 0.3,
                    spacing: 0,
                    dataSource: chartData,
                    pointColorMapper: (ChartDataInfo data, _) => data.color,
                    xValueMapper: (ChartDataInfo data, _) => data.time,
                    yValueMapper: (ChartDataInfo data, _) => data.value,
                    enableTooltip: true,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: false,
                      angle: 0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Divider(
              height: MediaQuery.of(context).size.height * 0.03,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Insulin Dosage",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.025,
                        color: Theme.of(context).colorScheme.primaryContainer),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: '$glucose',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.04,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                fontWeight: AppColor.weight600)),
                        TextSpan(
                            text: " unit",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer))
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  monthContainer() {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/star.png',
                  width: MediaQuery.of(context).size.height * 0.02,
                  height: MediaQuery.of(context).size.width * 1,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                Text(
                  "Glucose in Range | Going down",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onInverseSurface),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                color: Colors.green,
                size: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.01,
              ),
              Text(
                "Inrange",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onInverseSurface),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.02,
              ),
              Icon(
                Icons.circle,
                color: Colors.amber,
                size: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.01,
              ),
              Text(
                "High",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onInverseSurface),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.03,
              ),
              Icon(
                Icons.circle,
                color: Colors.red,
                size: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.03,
              ),
              Text(
                "Low",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onInverseSurface),
              ),
            ],
          ),
          Container(
            height: height * 0.23,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: SfCartesianChart(
              tooltipBehavior: TooltipBehavior(
                shouldAlwaysShow: true,
                canShowMarker: true,
                format: 'point.y Kg',
                shared: true,
                duration: 1000,
                enable: true,
                color: Theme.of(context).colorScheme.onPrimary,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  fontSize: height * 0.013,
                ),
              ),
              plotAreaBorderWidth: 0.0,
              primaryXAxis: CategoryAxis(
                axisLine: AxisLine(color: Colors.grey),
                majorTickLines: MajorTickLines(color: Colors.grey),
                labelRotation: 0,
                 interval: 1,
                minimum: 0,
                majorGridLines: MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  fontSize: 8,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              primaryYAxis: NumericAxis(
                axisLine: AxisLine(color: Colors.grey),
                majorTickLines: MajorTickLines(color: Colors.grey),
      
                majorGridLines: MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  fontSize: 8,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              series: <CartesianSeries<dynamic, dynamic>>[
                ColumnSeries<ChartDataInfo, String>(
                  width: 0.3,
                  spacing: 0,
                  dataSource: chartData,
                  pointColorMapper: (ChartDataInfo data, _) => data.color,
                  xValueMapper: (ChartDataInfo data, _) => data.time,
                  yValueMapper: (ChartDataInfo data, _) => data.value,
                  enableTooltip: true,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: false,
                    angle: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Divider(
            height: MediaQuery.of(context).size.height * 0.03,
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Monthly Insulin Dosage",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      color: Theme.of(context).colorScheme.primaryContainer),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: '${totaldeliveredDosage}',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.03,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              fontWeight: AppColor.weight600)),
                      TextSpan(
                          text: " unit",
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer))
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  yearlyContainer() {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/star.png',
                  width: MediaQuery.of(context).size.height * 0.02,
                  height: MediaQuery.of(context).size.width * 1,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                Text(
                  "Glucose in Range | Going down",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onInverseSurface),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                color: Colors.green,
                size: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.01,
              ),
              Text(
                "Inrange",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onInverseSurface),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.02,
              ),
              Icon(
                Icons.circle,
                color: Colors.amber,
                size: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.01,
              ),
              Text(
                "High",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onInverseSurface),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.03,
              ),
              Icon(
                Icons.circle,
                color: Colors.red,
                size: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.03,
              ),
              Text(
                "Low",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onInverseSurface),
              ),
            ],
          ),
          Container(
            height: height * 0.23,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: SfCartesianChart(
              tooltipBehavior: TooltipBehavior(
                shouldAlwaysShow: true,
                canShowMarker: true,
                format: 'point.y Kg',
                shared: true,
                duration: 1000,
                enable: true,
                color: Theme.of(context).colorScheme.onPrimary,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  fontSize: height * 0.013,
                ),
              ),
              plotAreaBorderWidth: 0.0,
              primaryXAxis: CategoryAxis(
                axisLine: AxisLine(color: Colors.grey),
                majorTickLines: MajorTickLines(color: Colors.grey),
                labelRotation: 0,
                minimum: 0,
           
                majorGridLines: MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  fontSize: 8,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              primaryYAxis: NumericAxis(
       
                axisLine: AxisLine(color: Colors.grey),
                majorTickLines: MajorTickLines(color: Colors.grey),
                majorGridLines: MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  fontSize: 8,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              series: <CartesianSeries<dynamic, dynamic>>[
                ColumnSeries<ChartDataInfo, String>(
                  width: 0.3,
                  spacing: 0,
                
                  dataSource: chartData,
                  pointColorMapper: (ChartDataInfo data, _) => data.color,
                  xValueMapper: (ChartDataInfo data, _) => data.time,
                  yValueMapper: (ChartDataInfo data, _) => data.value,
                  enableTooltip: true,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: false,
                    angle: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Divider(
            height: MediaQuery.of(context).size.height * 0.03,
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Yearly Insulin Dosage",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      color: Theme.of(context).colorScheme.primaryContainer),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: '$totaldeliveredDosage',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.03,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              fontWeight: AppColor.weight600)),
                      TextSpan(
                          text: " unit",
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer))
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  selectedBUtton(text) {
    if (_selectedtext == text) {
      activeColor = Colors.green;
    } else {
      activeColor = Colors.transparent;
    }
    return GestureDetector(
      onTap: () {
        _fetchChartData(text);
        setState(() {
          _selectedtext = text;
          selected = text;
          print('this is selected text $_selectedtext and this is text $text');
          totaldeliveredDosage = _hivedb.getString('totalDeliveredDosage');
        });
      },
      child: Container(
          height: MediaQuery.of(context).size.height * 0.03,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50), color: activeColor),
          child: Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.height * 0.02,
                )),
          ))),
    );
  }

}
