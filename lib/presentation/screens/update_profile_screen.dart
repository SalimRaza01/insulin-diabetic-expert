import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/utils/popover_bottomsheet.dart';
import '../../data/models/city_model.dart';
import '../../data/models/state_model.dart';
import '../../data/providers/profile_updated_provider.dart';
import '../widgets/slider_widget.dart';

List<String> genderList = ['Male', 'Female'];
List<String> diabetesList = ['Diabetes', 'HyperTension'];
List<String> selectedCheckBoxValue = [];

class UpdateProfile extends StatefulWidget {
  final String fname;
  final String lname;
  final String dob;
  final String age;
  final String phone;
  final String email;
  final String state;
  final String city;
  final String height;
  final String weight;
  final String gender;
  bool hyperTension2;
  bool diabetes2;

  UpdateProfile(
    this.fname,
    this.lname,
    this.dob,
    this.age,
    this.phone,
    this.email,
    this.state,
    this.city,
    this.height,
    this.weight,
    this.gender,
    this.hyperTension2,
    this.diabetes2,
  );

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  late String fname;
  late String lname;
  late String dob;
  late String age;
  late String phone;
  late String email;
  late String state;
  late String city;
  late String height;
  late String weight;
  late String gender;
  late bool hyperTension2;
  late bool diabetes2;

  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String selectedGender = '';

  double tempWeight = 60;
  double tempHeight = 100;
  double tempAge = 18;
  bool diabeties = false;
  bool? hypertension = false;
  bool showCityList = false;
  bool showStatelist = false;
  DateTime selectedData = DateTime.now();
  bool showError = false;
  String error = '*please select your diagnosis';

  @override
  void initState() {
    super.initState();
    selectedGender = widget.gender;
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  _waitingDialogBox() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });

        return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Image.asset(
              'assets/images/profileupdate.gif',
              height: 250,
            ));
      },
    );
  }

  void _selectGenderType() {
    showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Popover(
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Wrap(
                  children: genderList.map((gender) {
                    return ListTile(
                      leading: Icon(
                        gender == 'Male' ? Icons.male : Icons.female,
                        color: gender == 'Male' ? Colors.blue : Colors.pink,
                      ),
                      title: Text(
                        gender,
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            fontWeight: FontWeight.w400),
                      ),
                      onTap: () {
                        setState(() {
                          selectedGender = gender;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectWeight() {
    showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Popover(
          height: 200,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: DivisionSlider(
                      from: 20,
                      max: 250,
                      initialValue: double.parse(widget.weight),
                      type: WeightType.kg,
                      onChanged: (value) =>
                          setModalState(() => tempWeight = value),
                      title: "Weight",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color.fromRGBO(255, 87, 87, 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  child: Center(
                                    child: Text(
                                      'CANCEL',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              setModalState(() {
                                print(
                                    'new weight $tempHeight ${weightController.text} ');
                                setState(() {
                                  weightController.text = tempWeight.toString();
                                });
                                Navigator.pop(context);
                              });
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color.fromRGBO(112, 217, 136, 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  child: Center(
                                    child: Text(
                                      'SELECT',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                )),
                          ),
                        ]),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _selectHeight() {
    showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Popover(
          height: 200,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: DivisionSlider(
                      from: 0,
                      max: 250,
                      initialValue: double.parse(widget.height),
                      type: WeightType.cms,
                      onChanged: (value) =>
                          setModalState(() => tempHeight = value),
                      title: "Height",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color.fromRGBO(255, 87, 87, 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  child: Center(
                                    child: Text(
                                      'CANCEL',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              setModalState(() {
                                print(
                                    'new height $tempHeight ${heightController.text} ');
                                setState(() {
                                  heightController.text = tempHeight.toString();
                                });
                                Navigator.pop(context);
                              });
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color.fromRGBO(112, 217, 136, 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  child: Center(
                                    child: Text(
                                      'SELECT',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                )),
                          ),
                        ]),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _selectAge() {
    showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Popover(
          height: 150,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Stack(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.cancel_sharp),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              print('new age $tempAge ${ageController.text} ');
                              setState(() {
                                ageController.text = tempAge.toString();
                              });
                              Navigator.pop(context);
                            });
                          },
                          icon: Icon(Icons.check_circle),
                          color: AppColor.weightChartColor,
                        )
                      ]),
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: DivisionSlider(
                      from: 0,
                      max: 100,
                      initialValue: tempAge,
                      type: WeightType.years,
                      onChanged: (value) =>
                          setModalState(() => tempAge = value),
                      title: "Age",
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(body: Consumer<ProfileUpdateNotifier>(
      builder: (context, value, child) {
        if (value.updatedProfile == true) {
          
          Navigator.pop(context);
        }

        return Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 0, left: 18),
                child: Column(
                  children: [
                    SizedBox(
                      height: height * 0.07,
                    ),
                    Text(
                      "UPDATE YOUR PROFILE",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                        fontSize: height * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height * 0.85,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: TextField(
                          controller: firstnameController,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            fontSize: height * 0.018,
                          ),
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.person,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            border: InputBorder.none,
                            hintText: widget.fname,
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                fontSize: height * 0.018,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color.fromARGB(155, 174, 174, 174),
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: TextField(
                          controller: lastnameController,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            fontSize: height * 0.018,
                          ),
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.person,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            border: InputBorder.none,
                            hintText: widget.lname,
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                fontSize: height * 0.018,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color.fromARGB(155, 174, 174, 174),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: TextField(
                          controller: emailController,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            fontSize: height * 0.018,
                          ),
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.email,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            border: InputBorder.none,
                            hintText: widget.email.isNotEmpty
                                ? widget.email
                                : " Enter your email",
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                fontSize: height * 0.018,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color.fromARGB(155, 174, 174, 174),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: TextField(
                          controller: phoneController,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            fontSize: height * 0.018,
                          ),
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.phone,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            border: InputBorder.none,
                            hintText: widget.phone.isNotEmpty
                                ? widget.phone
                                : 'Enter Phone Number',
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                fontSize: height * 0.018,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color.fromARGB(155, 174, 174, 174),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: TextField(
                          readOnly: true,
                          controller: dobController,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            fontSize: height * 0.018,
                          ),
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.calendar_month,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            border: InputBorder.none,
                            hintText: widget.dob,
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                fontSize: height * 0.018,
                                fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            showModalBottomSheet(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              context: context,
                              builder: (context) {
                                return SizedBox(
                                  height: height * 0.42,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: height * 0.3,
                                          child: CupertinoDatePicker(
                                            initialDateTime: DateTime.now(),
                                            mode: CupertinoDatePickerMode.date,
                                            use24hFormat: true,
                                            minimumDate: DateTime(1900),
                                            maximumDate: DateTime.now(),
                                            onDateTimeChanged:
                                                (DateTime newDate) {
                                              selectedData = newDate;
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: Color.fromRGBO(
                                                            255, 87, 87, 1),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 30,
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            'CANCEL',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15),
                                                          ),
                                                        ),
                                                      )),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      dobController
                                                          .text = DateFormat(
                                                              'dd/MM/yyyy')
                                                          .format(selectedData);

                                                      int age =
                                                          DateTime.now().year -
                                                              selectedData.year;

                                                      if (DateTime.now().month <
                                                              selectedData
                                                                  .month ||
                                                          (DateTime.now()
                                                                      .month ==
                                                                  selectedData
                                                                      .month &&
                                                              DateTime.now()
                                                                      .day <
                                                                  selectedData
                                                                      .day)) {
                                                        age--;
                                                      }

                                                      ageController.text =
                                                          age.toString();
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: Color.fromRGBO(
                                                            112, 217, 136, 1),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 30,
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            'SELECT',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15),
                                                          ),
                                                        ),
                                                      )),
                                                ),
                                              ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color.fromARGB(155, 174, 174, 174),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      TextField(
                        selectionControls: CupertinoTextSelectionControls(),
                        controller: stateController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          fontSize: height * 0.018,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.location_on,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          border: InputBorder.none,
                          hintText: widget.state,
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              fontSize: height * 0.018,
                              fontWeight: FontWeight.w400),
                        ),
                        onChanged: (value) {
                          setState(() {
                            showStatelist = true;
                            if (value.isEmpty) {
                              showStatelist = false;
                            }
                          });
                        },
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outline,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        height: showStatelist ? 50 : 0,
                        child: FutureBuilder<List<Statemodel>>(
                          future:
                              Future.delayed(Duration(milliseconds: 300), () {
                            return getStateList();
                          }),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: SizedBox());
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(child: Text('No data available'));
                            } else {
                              final items = snapshot.data!;
                              final filteredItems = items
                                  .where((item) => item.name!
                                      .toLowerCase()
                                      .contains(
                                          stateController.text.toLowerCase()))
                                  .toList();

                              return ListView.builder(
                                padding: EdgeInsets.all(0),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final stateItem = filteredItems[index];
                                  return ListTile(
                                    title: Text(
                                      stateItem.name!,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onInverseSurface,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        stateController.text = stateItem.name!;
                                        showStatelist = false;
                                      });
                                    },
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color.fromARGB(155, 174, 174, 174),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: TextField(
                          controller: cityController,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            fontSize: height * 0.018,
                          ),
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.location_city,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            border: InputBorder.none,
                            hintText: widget.city,
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                fontSize: height * 0.018,
                                fontWeight: FontWeight.w400),
                          ),
                          onChanged: (value) {
                            setState(() {
                              showCityList = true;
                              if (value.isEmpty) {
                                showCityList = false;
                              }
                            });
                          },
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        height: showCityList ? 50 : 0,
                        child: FutureBuilder<List<Citymodel>>(
                          future: stateController.text.isEmpty
                              ? getCityList(widget.state)
                              : getCityList(stateController.text),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: SizedBox());
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(child: Text('No data available'));
                            } else {
                              final items = snapshot.data!;
                              final filteredItems = items
                                  .where((item) => item.name!
                                      .toLowerCase()
                                      .contains(
                                          cityController.text.toLowerCase()))
                                  .toList();

                              return ListView.builder(
                                padding: EdgeInsets.all(0),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final cityItems = filteredItems[index];
                                  return ListTile(
                                    title: Text(
                                      cityItems.name!,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onInverseSurface,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        cityController.text = cityItems.name!;
                                        showCityList = false;
                                      });
                                    },
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color.fromARGB(155, 174, 174, 174),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      InkWell(
                        onTap: () {
                          _selectGenderType();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    selectedGender == 'Male'
                                        ? Icons.male
                                        : Icons.female,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  SizedBox(
                                    width: width * 0.04,
                                  ),
                                  Text(
                                    selectedGender,
                                    style: TextStyle(
                                        fontSize: height * 0.018,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              )
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color.fromARGB(155, 174, 174, 174),
                      ),
                      SizedBox(
                        height: height * 0.022,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.man_2_outlined,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                SizedBox(
                                  width: width * 0.04,
                                ),
                                if (ageController.text.isEmpty)
                                  Text(
                                    widget.age.toString(),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        fontSize: height * 0.018,
                                        fontWeight: FontWeight.w400),
                                  ),
                                Text(
                                  ageController.text,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      fontSize: height * 0.018,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'years',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color.fromARGB(155, 174, 174, 174),
                      ),
                      SizedBox(
                        height: height * 0.033,
                      ),
                      InkWell(
                        onTap: _selectHeight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.height,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  SizedBox(
                                    width: width * 0.04,
                                  ),
                                  if (heightController.text.isEmpty)
                                    Text(
                                      widget.height.toString(),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          fontSize: height * 0.018,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  Text(
                                    heightController.text,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        fontSize: height * 0.018,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'cms',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color.fromARGB(155, 174, 174, 174),
                      ),
                      SizedBox(
                        height: height * 0.033,
                      ),
                      InkWell(
                        onTap: _selectWeight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.monitor_weight,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  SizedBox(
                                    width: width * 0.04,
                                  ),
                                  if (weightController.text.isEmpty)
                                    Text(
                                      widget.weight.toString(),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          fontSize: height * 0.018,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  Text(
                                    weightController.text,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        fontSize: height * 0.018,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'kg',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color.fromARGB(155, 174, 174, 174),
                      ),
                      SizedBox(
                        height: height * 0.015,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  //SizedBox
                                  Text(
                                    'Diabetes',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        fontSize: height * 0.018,
                                        fontWeight: FontWeight.w400),
                                  ), //Text
                                  //SizedBox

                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    value: widget.diabetes2,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        widget.diabetes2 = value!;
                                        showError = false;
                                      });
                                    },
                                  ),
                                ], //<Widget>[]
                              ),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Text(
                                    'Hypertension',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        fontSize: height * 0.018,
                                        fontWeight: FontWeight.w400),
                                  ), //Text
                                  //SizedBox

                                  Checkbox(
                                    checkColor: Colors.white,
                                    activeColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    value: widget.hyperTension2,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        widget.hyperTension2 = value!;
                                        showError = false;
                                      });
                                    },
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Visibility(
                          visible: showError,
                          child: Text(
                            error,
                            style: TextStyle(color: Colors.red),
                          )),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3,
                              height: height * 0.05,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary),
                              child: Center(
                                child: Text(
                                  "Back",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: height * 0.02),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (widget.diabetes2 == true ||
                                  widget.hyperTension2 == true) {
                                await setUpProfileApi(
                                    firstnameController.text.isEmpty
                                        ? widget.fname
                                        : firstnameController.text,
                                    lastnameController.text.isEmpty
                                        ? widget.lname
                                        : lastnameController.text,
                                    dobController.text.isEmpty
                                        ? widget.dob
                                        : dobController.text,
                                    ageController.text.isEmpty
                                        ? widget.age
                                        : ageController.text,
                                    cityController.text.isEmpty
                                        ? widget.city
                                        : cityController.text,
                                    stateController.text.isEmpty
                                        ? widget.state
                                        : stateController.text,
                                    selectedGender == widget.gender
                                        ? widget.gender
                                        : selectedGender,
                                    heightController.text.isEmpty
                                        ? widget.height
                                        : heightController.text,
                                    weightController.text.isEmpty
                                        ? widget.weight
                                        : weightController.text,
                                    widget.diabetes2,
                                    widget.hyperTension2,
                                    true,
                                    emailController.text.isEmpty
                                        ? widget.email
                                        : emailController.text,
                                    phoneController.text.isEmpty
                                        ? widget.phone
                                        : phoneController.text,
                                    context);
                              } else {
                                setState(() {
                                  showError = true;
                                });
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3,
                              height: height * 0.05,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary),
                              child: Center(
                                child: Text(
                                  "SAVE",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: height * 0.02),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * 0.04,
                      ),
                    ],
                  )),
                ),
              ),
            )
          ],
        );
      },
    ));
  }
}
