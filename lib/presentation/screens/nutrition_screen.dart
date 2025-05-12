import 'dart:async';
import 'package:animated_icon/animated_icon.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/api/nutrition_middleware.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/nutrition_donut_model.dart';
import '../../data/models/search_meal_model.dart';
import '../animations/animation_shimmer.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();
class NutritionScreen extends StatefulWidget {
  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  Future<List<FoodItem>>? _getFutureMeal;
  TextEditingController controller = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  String quantity = '1';
  Future<List<FoodItem>>? _futureFoodItems;
  Future<List<NutritionDonutDataItem>>? _nutritionDonutData;
  int? _expandedIndex;
  bool showlist = false;

  int touchedIndex = -1;

  void _loadMeals() {
    setState(() {
      print('loading meal');
      _getFutureMeal = getMeal();
    });
  }

  @override
  void initState() {
    _loadMeals();
    super.initState();
    _nutritionDonutData = fetchNutritionDonutData(_selectedText);
  }

  bool findMeal = false;
  bool findMeal2 = false;
  String _selectedText = 'TODAY';
  Color? activeColor;
  Color? activeText;

  void _notifyUser(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          duration: Duration(milliseconds: 600),
          backgroundColor: Colors.blue,
          content: Center(
              child: Text(
            message,
            style: TextStyle(fontSize: 20),
          ))),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        appBar: AppBar(
          title: Text(
            'NUTRITION',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
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
        body: Stack(children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(3),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _selectButton('TODAY', height, width),
                            _selectButton('WEEK', height, width),
                            _selectButton('MONTH', height, width),
                          ]),
                    ),
                  ),
                  FutureBuilder<List<NutritionDonutDataItem>>(
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                            centerSpaceRadius: height * 0.06,
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
                                                    color: AppColor.fatColor,
                                                    value: item.totalFat!
                                                        .toDouble(),
                                                    // title: '10%',
                                                    radius: radius,
                                                    titleStyle: TextStyle(
                                                      fontSize: fontSize,
                                                      color: AppColor.fatColor,
                                                    ),
                                                  );
                                                case 1:
                                                  return PieChartSectionData(
                                                    color: AppColor.carbsColor,
                                                    value: item.totalCarbs!
                                                        .toDouble(),
                                                    // title: '45%',
                                                    radius: radius,
                                                    titleStyle: TextStyle(
                                                      fontSize: fontSize,
                                                      color:
                                                          AppColor.carbsColor,
                                                    ),
                                                  );
                                                case 2:
                                                  return PieChartSectionData(
                                                    color:
                                                        AppColor.proteinColor,
                                                    value: item.totalProtein!
                                                        .toDouble(),
                                                    // title: '25%',
                                                    radius: radius,
                                                    titleStyle: TextStyle(
                                                      fontSize: fontSize,
                                                      color:
                                                          AppColor.proteinColor,
                                                    ),
                                                  );
                                                case 3:
                                                  return PieChartSectionData(
                                                    color: AppColor.kcalColor,
                                                    value: item.totalCalories!
                                                        .toDouble(),
                                                    // title: '20%',
                                                    radius: radius,
                                                    titleStyle: TextStyle(
                                                      fontSize: fontSize,
                                                      color: AppColor.kcalColor,
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
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                fontSize: height * 0.025,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Total kcal',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
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
                                        dataContainer(
                                            color: AppColor.kcalColor,
                                            title: 'Calories',
                                            percentage:
                                                item.totalCalories.toString()),
                                        dataContainer(
                                            color: AppColor.proteinColor,
                                            title: 'Protein',
                                            percentage:
                                                item.totalProtein.toString()),
                                        dataContainer(
                                            color: AppColor.fatColor,
                                            title: 'Fats',
                                            percentage:
                                                item.totalFat.toString()),
                                        dataContainer(
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
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Container(
                    height: height * 0.43,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Meals History',
                                style: TextStyle(
                                    fontSize: height * 0.018,
                                    fontWeight: FontWeight.w300,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          FutureBuilder<List<FoodItem>>(
                            future: _getFutureMeal,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: ShimmereffectMealHistory());
                              } else if (snapshot.hasError) {
                                return Container(
                                  height: height * 0.3,
                                  child: Center(
                                      child: Text('No Meals Found',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer))),
                                );
                              } else if (!snapshot.hasData) {
                                return Container(
                                  height: height * 0.3,
                                  child: Center(
                                      child: Text('No Meals Found',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer))),
                                );
                              } else {
                                final items = snapshot.data!;

                                return Container(
                                  height: height * 0.35,
                                  child: ListView.separated(
                                    itemCount: items.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final item = items[index];

                                      return Dismissible(
                                        key: ValueKey(item.id),
                                        direction: DismissDirection.endToStart,
                                        onDismissed: (direction) async {
                                          try {
                                            await deleteMeal(item.id!, context);
                                            final remove =
                                                items.removeAt(index);
                                            _nutritionDonutData =
                                                fetchNutritionDonutData(
                                                    _selectedText);
                                            _loadMeals();

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.blue,
                                                duration:
                                                    Duration(milliseconds: 500),
                                                content: Center(
                                                  child: Text(
                                                    "${item.foodName} Removed",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      fontSize: height * 0.015,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          } catch (error) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Center(
                                                  child: Text(
                                                    "Failed to remove ${item.foodName}",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      fontSize: height * 0.015,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        background: Container(
                                          color: Colors.red,
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Icon(Icons.delete,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Image.asset(
                                                          'assets/images/diet.png',
                                                          height: height * 0.04,
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                width * 0.02),
                                                        SizedBox(
                                                          width: width * 0.4,
                                                          child: Text(
                                                            item.foodName
                                                                    ?.toUpperCase() ??
                                                                "",
                                                            maxLines: 3,
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primaryContainer,
                                                              fontSize: height *
                                                                  0.015,
                                                              fontWeight:
                                                                  AppColor
                                                                      .weight600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                        'QTY : ${(double.parse(item.quantity!)).toInt()}',
                                                        style: TextStyle(
                                                          fontSize:
                                                              height * 0.019,
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .primaryContainer,
                                                        )),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: height * 0.01,
                                                ),
                                                Divider(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  height: 0.2,
                                                ),
                                                SizedBox(
                                                  height: height * 0.01,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Colories',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primaryContainer,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        Text(
                                                          item.calories,
                                                          style: TextStyle(
                                                            fontSize:
                                                                height * 0.015,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primaryContainer,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Carbs',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primaryContainer,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        Text('${item.carbs}g',
                                                            style: TextStyle(
                                                              fontSize: height *
                                                                  0.015,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primaryContainer,
                                                            ))
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Protein',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primaryContainer,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        Text(item.protein,
                                                            style: TextStyle(
                                                              fontSize: height *
                                                                  0.015,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primaryContainer,
                                                            ))
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Fats',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primaryContainer,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        Text(item.fat,
                                                            style: TextStyle(
                                                              fontSize: height *
                                                                  0.015,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primaryContainer,
                                                            ))
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return SizedBox(height: height * 0.015);
                                    },
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.035,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  findMeal = true;
                });
                Future.delayed(Duration(milliseconds: 300), () {
                  setState(() {
                    findMeal2 = true;
                  });
                });
              },
              child: Padding(
                padding: findMeal
                    ? EdgeInsets.only(bottom: 0)
                    : EdgeInsets.only(bottom: 50),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.linear,
                  height: findMeal ?  height * 1 : height * 0.05,
                  width: findMeal ? width : width * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: findMeal
                        ? BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))
                        : BorderRadius.circular(50),
                    color: findMeal
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                  child: findMeal
                      ? _searchMealData(height, width)
                      : Center(
                          child: Text(
                          'ADD MEAL',
                          style: TextStyle(
                              color: Colors.white, fontSize: height * 0.022),
                        )),
                ),
              ),
            ),
          ),
        ]));
  }

  _searchMealData(double height, double width) {
    return Visibility(
      visible: findMeal2,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: width * 0.025,
                ),
                Text(
                  'SEARCH MEAL',
                  style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.secondaryContainer),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      findMeal = false;
                      findMeal2 = false;
                         FocusScope.of(context).unfocus();
                    });
                    _nutritionDonutData =
                        fetchNutritionDonutData(_selectedText);
                    Future.delayed(Duration(seconds: 1), () {
                      _loadMeals();
                    });
                    controller.clear();
                  },
                  child: Icon(Icons.close,
                      size: height * 0.03,
                      color: Theme.of(context).colorScheme.secondaryContainer),
                ),
              ],
            ),
            SizedBox(
              height: height * 0.01,
            ),
            Container(
           height: height * 0.058,
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.onPrimary,
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
              ),
              child: TextField(
                cursorColor: Theme.of(context).colorScheme.onInverseSurface,
                style: TextStyle(
                     fontSize: height * 0.018,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
                controller: controller,
                     autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _futureFoodItems = fetchFoodItem(controller.text);
                  });
                },
                decoration: InputDecoration(
                
                  border: InputBorder.none,
                   prefixIcon:
                    Icon(Icons.search, color: Color.fromARGB(255, 59, 58, 58), size: height * 0.03,),
                  
                ),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            FutureBuilder<List<FoodItem>>(
              future: controller.text.isNotEmpty ? _futureFoodItems : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Shimmereffect();
                } else if (snapshot.hasError) {
                  return SizedBox();
                } else if (!snapshot.hasData) {
                  return SizedBox();
                } else {
                  final items = snapshot.data!;

                  //

                  return controller.text.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];

                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                child: ExpansionTile(
                                  onExpansionChanged: (expanded) {
                                    setState(() {
                                      _expandedIndex = expanded ? index : null;
                                      // controller.clear();
                                    });
                                  },
                                  initiallyExpanded: _expandedIndex == index,
                                  shape: Border(),
                                  leading: Image.asset(
                                    'assets/images/diet.png',
                                    height: 30,
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.foodName?.toUpperCase() ?? "",
                                        style: TextStyle(
                                          fontWeight: AppColor.weight600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          fontSize: height * 0.015,
                                        ),
                                      ),
                                      if (_expandedIndex != index)
                                        Row(
                                          children: [
                                            Text(
                                              'Cal ${item.calories},',
                                              style: TextStyle(
                                                fontWeight:
                                                    AppColor.lightWeight,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                fontSize: height * 0.015,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Flexible(
                                              child: Text(
                                                overflow: TextOverflow.ellipsis,
                                                item.foodDescription!
                                                    .split('-')[0],
                                                style: TextStyle(
                                                  fontWeight:
                                                      AppColor.lightWeight,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer,
                                                  fontSize: height * 0.015,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  trailing: _expandedIndex == index
                                      ? Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          width: 80,
                                          height: 35,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: TextField(
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface),
                                              controller: _quantityController,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                hintText: '1',
                                                hintStyle: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onInverseSurface),
                                                border: InputBorder.none,
                                              ),
                                              onChanged: (value) {
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                        )
                                      : AnimateIcon(
                                          key: ValueKey(index),
                                          onTap: () async {
                                            double carbs;
                                            final match =
                                                RegExp(r'Carbs:\s*([\d.]+)g')
                                                    .firstMatch(
                                                        item.foodDescription!);
                                            try {
                                              carbs = double.parse(
                                                  match!.group(1).toString());

                                              print(
                                                  "initial carb value ${carbs.toString()}");
                                            } catch (e) {
                                              print(
                                                  'Error parsing carbs as number: $e');
                                              carbs = 0;
                                            }

                                            double newCarbs = carbs * 1;

                                            await addMeal(item, quantity,
                                                newCarbs, carbs, context);

                                            _notifyUser('FOOD LOGGED');
                                          },
                                          iconType: IconType.animatedOnTap,
                                          height: 40,
                                          width: 40,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                          animateIcon: AnimateIcons.checkbox,
                                        ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 15, bottom: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Calories",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          AppColor.lightWeight,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${item.calories}",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          AppColor.lightWeight,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Carbs",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          AppColor.lightWeight,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${item.carbs}",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          AppColor.lightWeight,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Protein",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          AppColor.lightWeight,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${item.protein}",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          AppColor.lightWeight,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Fats",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          AppColor.lightWeight,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${item.fat}",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          AppColor.lightWeight,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 15),
                                          Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (_quantityController
                                                    .text.isNotEmpty) {
                                                  quantity =
                                                      _quantityController.text;
                                                } else {
                                                  quantity = '1';
                                                }

                                                double carbs;
                                                final match = RegExp(
                                                        r'Carbs:\s*([\d.]+)g')
                                                    .firstMatch(
                                                        item.foodDescription!);
                                                try {
                                                  carbs = double.parse(match!
                                                      .group(1)
                                                      .toString());

                                                  print(
                                                      "initial carb value ${carbs.toString()}");
                                                } catch (e) {
                                                  print(
                                                      'Error parsing carbs as number: $e');
                                                  carbs = 0;
                                                }

                                                double enteredQuantity;
                                                try {
                                                  enteredQuantity =
                                                      double.parse(
                                                          quantity.replaceAll(
                                                              RegExp(
                                                                  r'[^0-9.]'),
                                                              ''));
                                                } catch (e) {
                                                  print(
                                                      'Error parsing quantity as number: $e');
                                                  enteredQuantity = 1;
                                                }

                                                double newCarbs =
                                                    carbs * enteredQuantity;

                                                setState(() {
                                                  findMeal = false;
                                                });
                                        

                                                 addMeal(item, quantity,
                                                    newCarbs, carbs, context);

                                           

                                                _nutritionDonutData =
                                                    fetchNutritionDonutData(
                                                        _selectedText);

                                                Future.delayed(
                                                    Duration(seconds: 1), () {
                                                  _loadMeals();
                                                });
                                                        controller.clear();
                                                _quantityController.clear();
                                              },
                                              child: Container(
                                                height: height * 0.04,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'ADD',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                      fontSize: height * 0.015,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : SizedBox();
                }
              },
            ),
          ],
        ),
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
                          color: Color.fromARGB(255, 92, 94, 95),
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
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              Text(
                'Total kcal',
                style: TextStyle(
                  fontSize: height * 0.015,
                  color: Theme.of(context).colorScheme.primaryContainer,
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
            dataContainer(
                color: AppColor.kcalColor, title: 'Calories', percentage: '0'),
            dataContainer(
                color: AppColor.proteinColor,
                title: 'Protein',
                percentage: '0'),
            dataContainer(
                color: AppColor.fatColor, title: 'Fats', percentage: '0'),
            dataContainer(
                color: AppColor.carbsColor, title: 'Carbs', percentage: '0'),
          ],
        ),
      )
    ]);
  }

  Widget _selectButton(String text, double height, double width) {
    Color activeColor;
    Color activeText;

    if (_selectedText == text) {
      activeColor = Colors.green;
      activeText = Theme.of(context).colorScheme.primary;
    } else {
      activeColor = Colors.transparent;
      activeText = Theme.of(context).colorScheme.secondaryContainer;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedText = text;
          // Debug print
        });

        _nutritionDonutData = fetchNutritionDonutData(_selectedText);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: activeColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 5),
          child: Text(
            text,
            style: TextStyle(
                color: activeText,
                fontSize: height * 0.015,
                fontWeight: AppColor.lightWeight),
          ),
        ),
      ),
    );
  }
}

class dataContainer extends StatelessWidget {
  final Color color;
  final String title;
  final String percentage;
  dynamic mediaQuery;

  dataContainer({
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
        color: Theme.of(context).colorScheme.onPrimary,
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
                  color: Theme.of(context).colorScheme.primaryContainer,
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
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          )
        ],
      ),
    );
  }
}
