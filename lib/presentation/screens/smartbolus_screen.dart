import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/api/api_service.dart';
import '../../core/api/nutrition_middleware.dart';
import '../../core/services/bluetooth_service_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/search_meal_model.dart';
import '../../data/providers/smart_bolus_delivery_provider.dart';
import '../animations/animation_shimmer.dart';
import '../widgets/drawer_widget.dart';
import 'package:provider/provider.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();
class SmartBolusScreen extends StatefulWidget {
  @override
  State<SmartBolusScreen> createState() => _SmartBolusScreenState();
}

class _SmartBolusScreenState extends State<SmartBolusScreen>
    with SingleTickerProviderStateMixin {
  final BleManager _bleManager = BleManager();
  double initialInsulinValue = 0.0;
  Future<List<FoodItem>>? _getFutureMeal;
  final TextEditingController _searchMealController = TextEditingController();
  Future<List<FoodItem>>? _postFutureMeal;
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _bgController = TextEditingController();
  bool showlist = false;
  bool addedFood = false;
  FocusNode dosageFocusNode = FocusNode();
  String? weight;
  String quantity = '1';
  List<dynamic> items = [];
  int? _expandedIndex;
  String char = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  String cmd = 'cm+sync';
  String currentView = "enterbg";
  bool navigate = false;
  bool delivered = false;
  double calculateTotalCarbs(List<FoodItem> foodItems) {
    double totalCarbs = 0;

    for (var item in foodItems) {
      String carbString = item.carbs;
      double carbsValue = 0;
      final cleanedString = carbString.replaceAll(RegExp(r'[^\d.]'), '');

      try {
        carbsValue = double.parse(cleanedString);
      } catch (e) {
        print('Error parsing carbs value: $e');
      }

      totalCarbs += carbsValue;
    }

    return totalCarbs;
  }

  double getBloodGlucose() {
    return double.tryParse(_bgController.text) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    weight = _hivedb.getString('weight')!;
    _loadMeals();
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
    });
  }

  void _loadMeals() {
    setState(() {
      print('loading meal');
      _getFutureMeal = getMeal();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    _searchMealController.dispose();
    _currentPageNotifier.dispose();
    _pageController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _notifyUser(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          duration: Duration(milliseconds: 400),
          backgroundColor: Colors.blue,
          content: Center(
              child: Text(
            message,
            style: TextStyle(fontSize: 17),
          ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: AppDrawerNavigation('INSULIN'),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Stack(
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
          Visibility(
            visible: showlist,
            child: SingleChildScrollView(
              child: Container(
                height: 300,
                child: Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: FutureBuilder<List<FoodItem>>(
                    future: _getFutureMeal,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: Text('Please Add Food First',
                                style: TextStyle(color: Colors.white)),
                          ),
                        );
                      } else {
                        items = snapshot.data!;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: AnimationLimiter(
                            child: ListView.separated(
                              itemCount: items.length,
                              itemBuilder: (BuildContext context, int index) {
                                final item = items[index];

                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 700),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Dismissible(
                                        key: ValueKey(item.id),
                                        direction: DismissDirection.endToStart,
                                        onDismissed: (direction) async {
                                          try {
                                            await deleteMeal(item.id!, context);
                                            final remove =
                                                items.removeAt(index);
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
                                                        color: Colors.white,
                                                        fontSize: 15),
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
                                                        color: Colors.white,
                                                        fontSize: 15),
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
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
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
                                                            height: 35),
                                                        SizedBox(
                                                            width:
                                                                width * 0.02),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  width * 0.4,
                                                              child: Text(
                                                                item.foodName ??
                                                                    "",
                                                                maxLines: 2,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      AppColor
                                                                          .weight600,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          59,
                                                                          58,
                                                                          58),
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                                'Quantity : ${(double.parse(item.quantity!)).toInt()}',
                                                                style: TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            59,
                                                                            58,
                                                                            58),
                                                                    fontSize:
                                                                        12)),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      width: width * 0.3,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons
                                                                  .remove_circle,
                                                              color: AppColor
                                                                  .appbarColor,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              double
                                                                  carbsPerServing;
                                                              try {
                                                                carbsPerServing = double.parse(item
                                                                    .carbs_per_unit!
                                                                    .replaceAll(
                                                                        RegExp(
                                                                            r'[^0-9.]'),
                                                                        ''));
                                                              } catch (e) {
                                                                print(
                                                                    'Error parsing carbs as number: $e');
                                                                carbsPerServing =
                                                                    0;
                                                              }

                                                              double
                                                                  enteredQuantity;
                                                              try {
                                                                enteredQuantity =
                                                                    double.parse(
                                                                        item.quantity!);
                                                              } catch (e) {
                                                                print(
                                                                    'Error parsing quantity as number: $e');
                                                                enteredQuantity =
                                                                    1;
                                                              }

                                                              if (enteredQuantity >
                                                                  1) {
                                                                setState(() {
                                                                  enteredQuantity--;
                                                                  item.quantity =
                                                                      enteredQuantity
                                                                          .toString();
                                                                });

                                                                double
                                                                    newCarbs =
                                                                    carbsPerServing *
                                                                        enteredQuantity;
                                                                await updateQuantity(
                                                                    item.id,
                                                                    enteredQuantity,
                                                                    newCarbs);

                                                                _loadMeals();
                                                                _notifyUser(
                                                                    'Quantity reduced');
                                                              } else {
                                                                _notifyUser(
                                                                    'Quantity cannot be less than 1');
                                                              }
                                                            },
                                                          ),
                                                          Text(
                                                            '${(double.parse(item.quantity!)).toInt()}',
                                                            style: TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      59,
                                                                      58,
                                                                      58),
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.add_circle,
                                                              color: AppColor
                                                                  .appbarColor,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              double
                                                                  carbsPerServing;
                                                              try {
                                                                carbsPerServing = double.parse(item
                                                                    .carbs_per_unit!
                                                                    .replaceAll(
                                                                        RegExp(
                                                                            r'[^0-9.]'),
                                                                        ''));
                                                              } catch (e) {
                                                                print(
                                                                    'Error  while parsing carbs $e');
                                                                carbsPerServing =
                                                                    0;
                                                              }

                                                              double
                                                                  enteredQuantity;
                                                              try {
                                                                enteredQuantity =
                                                                    double.parse(
                                                                        item.quantity!);
                                                              } catch (e) {
                                                                print(
                                                                    'Error parsing quantity as number: $e');
                                                                enteredQuantity =
                                                                    1;
                                                              }

                                                              setState(() {
                                                                enteredQuantity++;
                                                                item.quantity =
                                                                    enteredQuantity
                                                                        .toString();
                                                              });

                                                              double newCarbs =
                                                                  carbsPerServing *
                                                                      enteredQuantity;
                                                              await updateQuantity(
                                                                  item.id,
                                                                  enteredQuantity,
                                                                  newCarbs);

                                                              _loadMeals();
                                                              _notifyUser(
                                                                  'Quantity added');
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(height: height * 0.015);
                              },
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              height: currentView == 'calculatedInsulValue'
                  ? height * 0.50
                  : navigate
                      ? (showlist ? height * 0.40 : height * 1)
                      : height * 0.65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  Visibility(
                      visible: currentView == "enterbg",
                      child: enterbg(height, width, context)),
                  Visibility(
                      visible: currentView == "searchmeal",
                      child: searchmeal(height, width, context)),
                  Visibility(
                      visible: currentView == "calculatedValue",
                      child: calculatedValue(height, width, context)),
                  Visibility(
                      visible: currentView == "calculatedInsulValue",
                      child: calculatedInsulValue(height, width, context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget enterbg(double height, double width, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'BLOOD GLUCOSE',
                  style: TextStyle(
                    fontSize: height * 0.025,
                    fontWeight: FontWeight.w200,
                    color: Color.fromARGB(255, 59, 58, 58),
                  ),
                ),
                SizedBox(
                  height: height * 0.025,
                ),
                Image.asset(
                  'assets/images/BG.png',
                  height: height * 0.15,
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
                      readOnly: true,
                      style: TextStyle(color: Color.fromARGB(255, 59, 58, 58)),
                      controller: _bgController,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        suffixText: 'mg/dl',
                        border: InputBorder.none,
                        hintText: 'ENTER BG VALUE',
                        hintStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: Color.fromARGB(255, 59, 58, 58)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.025,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        addedFood = false;
                        navigate = true;
                        currentView = "searchmeal";
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
              textController: _bgController,
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

  Widget searchmeal(double height, double width, BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    // await SystemChannels.textInput.invokeMethod('TextInput.hide');
                
                    setState(() {
                            FocusScope.of(context).unfocus();
                      addedFood = false;
                      navigate = false;
                      currentView = "enterbg";
                    
                    });
                  },
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Color.fromARGB(255, 59, 58, 58),
                  ),
                ),
                Text(
                  'SEARCH MEAL',
                  style: TextStyle(
                      fontSize: height * 0.025,
                      fontWeight: FontWeight.w200,
                      color: Color.fromARGB(255, 59, 58, 58)),
                ),
                GestureDetector(
                  onTap: () {
                    _loadMeals();
                    _searchMealController.clear();
                    setState(() {
                      showlist = true;

                      currentView = "calculatedValue";
                    });
                  },
                  child: Icon(
                    Icons.forward,
                    color: Color.fromARGB(255, 59, 58, 58),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Container(
              height: height * 0.058,
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColor.backgroundColor,
              ),
              child: TextField(
                style: TextStyle(
                  color: Color.fromARGB(255, 59, 58, 58),
                  fontSize: height * 0.018,
                  fontWeight: FontWeight.w300,
                ),
                controller: _searchMealController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _postFutureMeal = fetchFoodItem(_searchMealController.text);
                  });
                },
                decoration: InputDecoration(
                  // label: Text(
                  //   'Search Meal',
                  //   style: TextStyle(
                  //       fontSize: height * 0.018,
                  //       fontWeight: FontWeight.w300,
                  //       color: Color.fromARGB(255, 59, 58, 58)),
                  // ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color.fromARGB(255, 59, 58, 58),
                    size: height * 0.03,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            FutureBuilder<List<FoodItem>>(
              future: _postFutureMeal,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ShimmereffectSmartBolus();
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    'Please check your internet connection',
                    style: TextStyle(color: Color.fromARGB(255, 59, 58, 58)),
                  ));
                } else if (!snapshot.hasData) {
                  return SizedBox();
                } else {
                  final items = snapshot.data!;

                  return AnimationLimiter(
                    child: Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 400),
                            child: SlideAnimation(
                              verticalOffset: 500.0,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color.fromARGB(255, 242, 242, 247),
                                ),
                                child: ExpansionTile(
                                  onExpansionChanged: (expanded) {
                                    setState(() {
                                      _expandedIndex = expanded ? index : null;
                                      _quantityController.clear();
                                    });
                                  },
                                  initiallyExpanded: _expandedIndex == index,
                                  shape: Border(),
                                  leading: Image.asset(
                                    'assets/images/diet.png',
                                    height: height * 0.03,
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.foodName?.toUpperCase() ?? "",
                                        style: TextStyle(
                                          fontWeight: AppColor.lightWeight,
                                          color: Color.fromARGB(
                                              255, 100, 100, 100),
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
                                                color: Color.fromARGB(
                                                    255, 100, 100, 100),
                                                fontSize: height * 0.015,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              item.foodDescription!
                                                  .split('-')[0],
                                              style: TextStyle(
                                                fontWeight:
                                                    AppColor.lightWeight,
                                                color: Color.fromARGB(
                                                    255, 100, 100, 100),
                                                fontSize: height * 0.015,
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
                                                color: Color.fromARGB(
                                                    255, 100, 100, 100),
                                              ),
                                              controller: _quantityController,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                hintText: '1',
                                                hintStyle: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 100, 100, 100),
                                                ),
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

                                            setState(() {
                                              addedFood = true;
                                            });

                                            await addMeal(item, quantity,
                                                newCarbs, carbs, context);

                                            _notifyUser('FOOD LOGGED');
                                          },
                                          iconType: IconType.animatedOnTap,
                                          height: 40,
                                          width: 40,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
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
                                                      color: Color.fromARGB(
                                                          255, 100, 100, 100),
                                                    ),
                                                  ),
                                                  Text(
                                                    "${item.calories}",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          AppColor.lightWeight,
                                                      color: Color.fromARGB(
                                                          255, 100, 100, 100),
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
                                                      color: Color.fromARGB(
                                                          255, 100, 100, 100),
                                                    ),
                                                  ),
                                                  Text(
                                                    "${item.carbs}",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          AppColor.lightWeight,
                                                      color: Color.fromARGB(
                                                          255, 100, 100, 100),
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
                                                      color: Color.fromARGB(
                                                          255, 100, 100, 100),
                                                    ),
                                                  ),
                                                  Text(
                                                    "${item.protein}",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          AppColor.lightWeight,
                                                      color: Color.fromARGB(
                                                          255, 100, 100, 100),
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
                                                      color: Color.fromARGB(
                                                          255, 100, 100, 100),
                                                    ),
                                                  ),
                                                  Text(
                                                    "${item.fat}",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          AppColor.lightWeight,
                                                      color: Color.fromARGB(
                                                          255, 100, 100, 100),
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
                                                String quantity;
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

                                                await addMeal(item, quantity,
                                                    newCarbs, carbs, context);
                                                _loadMeals();
                                                _searchMealController.clear();

                                                _notifyUser('FOOD LOGGED');

                                                setState(() {
                                                  addedFood = true;

                                                  showlist = true;
                                                  currentView =
                                                      "calculatedValue";
                                                });
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
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget calculatedValue(double height, double width, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          addedFood = false;
                          showlist = false;
                          navigate = true;
                          currentView = "searchmeal";
                        });
                      },
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Color.fromARGB(255, 59, 58, 58),
                      )),
                  SizedBox(height: 20),
                ],
              ),
              SizedBox(height: 10),
              FutureBuilder<List<FoodItem>>(
                future: _getFutureMeal,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'total Calculated carbs'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                            Text(
                              '--',
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'total Calculated BG'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                            Text(
                              '--',
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    size: height * 0.015,
                                    color: Color.fromARGB(255, 59, 58, 58)),
                                SizedBox(width: width * 0.02),
                                Text(
                                  'Based on the current weight',
                                  style: TextStyle(
                                      fontSize: height * 0.015,
                                      color: Color.fromARGB(255, 59, 58, 58)),
                                ),
                              ],
                            ),
                            Text(
                              weight ?? '',
                              style: TextStyle(
                                  fontSize: height * 0.015,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'total Calculated carbs'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                            Text(
                              '--',
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'total Calculated BG'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                            Text(
                              '--',
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    size: height * 0.015,
                                    color: Color.fromARGB(255, 59, 58, 58)),
                                SizedBox(width: width * 0.02),
                                Text(
                                  'Based on the current weight',
                                  style: TextStyle(
                                      fontSize: height * 0.015,
                                      color: Color.fromARGB(255, 59, 58, 58)),
                                ),
                              ],
                            ),
                            Text(
                              weight ?? '',
                              style: TextStyle(
                                  fontSize: height * 0.015,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    double totalCarbs = calculateTotalCarbs(snapshot.data!);
                    double bloodGlucose = getBloodGlucose();
                    double totalCalculatedBG =
                        bloodGlucose + (totalCarbs / 100);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'total Calculated carbs'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                            Text(
                              '${totalCarbs.toStringAsFixed(1)} gram',
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'total Calculated BG'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                            Text(
                              '${totalCalculatedBG.toStringAsFixed(1)} mg/dl',
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    size: height * 0.015,
                                    color: Color.fromARGB(255, 59, 58, 58)),
                                SizedBox(width: width * 0.02),
                                Text(
                                  'Based on the current weight',
                                  style: TextStyle(
                                      fontSize: height * 0.015,
                                      color: Color.fromARGB(255, 59, 58, 58)),
                                ),
                              ],
                            ),
                            Text(
                              weight ?? '',
                              style: TextStyle(
                                  fontSize: height * 0.015,
                                  color: Color.fromARGB(255, 59, 58, 58)),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
          Center(
            child: _getFutureMeal != null
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        showlist = false;
                        currentView = "calculatedInsulValue";
                      });
                    },
                    child: Align(
                      alignment: Alignment.bottomCenter,
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
                          style: TextStyle(
                              color: Colors.white, fontSize: height * 0.015),
                        )),
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: height * 0.05,
                      width: width * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromARGB(71, 5, 53, 93),
                      ),
                      child: Center(
                          child: Text(
                        'NEXT',
                        style: TextStyle(
                            color: Color.fromARGB(188, 255, 255, 255),
                            fontSize: height * 0.015),
                      )),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget calculatedInsulValue(
      double height, double width, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: () {
                    setState(() {
                      addedFood = false;
                      showlist = true;
                      currentView = "calculatedValue";
                    });
                  },
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Color.fromARGB(255, 59, 58, 58),
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
          AnimatedContainer(
            height: currentView == 'calculatedInsulValue'
                ? height * 0.15
                : height * 0.0,
            duration: Duration(milliseconds: 2000),
            child: Image.asset(
              'assets/images/drop.png',
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: '50',
                    style: TextStyle(
                        fontSize: height * 0.05,
                        color: Color.fromARGB(255, 100, 100, 100),
                        fontWeight: AppColor.weight600)),
                TextSpan(
                    text: " unit",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: height * 0.02,
                    ))
              ],
            ),
          ),
          Consumer<SmartBolusDelivery>(
            builder: (context, value, child) {
              if (value.sbolusStatus == true) {
                Future.delayed(Duration(milliseconds: 1500), () {
                  setState(() {
                    delivered = false;
                    Provider.of<SmartBolusDelivery>(context, listen: false)
                        .updateSmartBolusValue(false);
                  });
                });
              }
              return GestureDetector(
                onTap: () async {
                  smartBolusApi('2.0', context);
                  await _saveInitialValue(2.0);
                  delivered = true;
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 5, 53, 93),
                    border: Border.all(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      delivered ? 'DELIVERING' : 'DELIVER SMART BOLUS',
                      style: TextStyle(
                          color: Colors.white, fontSize: height * 0.015),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
