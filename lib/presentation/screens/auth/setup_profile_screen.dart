import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api_service.dart';
import '../../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/popover_bottomsheet.dart';
import '../../../data/models/city_model.dart';
import '../../../data/models/state_model.dart';
import '../../widgets/slider_widget.dart';

List<String> genderList = ['Male', 'Female'];
List<String> diabetesList = ['Diabetes', 'HyperTension'];
List<String> selectedCheckBoxValue = [];

class SetupProfile extends StatefulWidget {
  const SetupProfile({super.key});

  @override
  State<SetupProfile> createState() => _SetupProfileState();
}

class _SetupProfileState extends State<SetupProfile> {
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  final today = DateUtils.dateOnly(DateTime.now());
  bool showCityList = false;
  List<String> selectedDiabetesTypes = [];
  double tempWeight = 60;
  double tempHeight = 100;
  double tempAge = 18;
  bool diabeties = false;
  bool hypertension = false;
  bool isProfileCompleted = false;
  bool _isNotValidate = false;
  String? _firstNameError;
  String? _lastNameError;
  String? _dobError;
  String? _cityError;
  String? _stateError;
  String? _genderError;
  String? _ageError;
  String? _heightError;
  String? _weightError;
  String? _diagnosis;
  bool showStatelist = false;
  DateTime selectedData = DateTime.now();

  @override
  void initState() {
    super.initState();
    // getStateList();
    // getCityList(stateController.text);
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    dobController.dispose();
    cityController.dispose();
    stateController.dispose();
    genderController.dispose();
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

  bool validateFirstName(String value) {
    if (value.isEmpty) {
      _firstNameError = 'Name cannot be empty';
      return false;
    } else if (RegExp(r'[0-9]').hasMatch(value)) {
      _firstNameError = 'Name cannot contain numbers';
      return false;
    } else if (RegExp(r'\s').hasMatch(value)) {
      _firstNameError = 'Name cannot contain spaces';
      return false;
    } else {
      _firstNameError = null;
      return true;
    }
  }

  bool validateLastName(String value) {
    if (value.isEmpty) {
      _lastNameError = 'Name cannot be empty';
      return false;
    } else if (RegExp(r'[0-9]').hasMatch(value)) {
      _lastNameError = 'Name cannot contain numbers';
      return false;
    } else if (RegExp(r'\s').hasMatch(value)) {
      _lastNameError = 'Name cannot contain spaces';
      return false;
    } else {
      _lastNameError = null;
      return true;
    }
  }

  bool validateDOB(String value) {
    if (value.isEmpty) {
      _dobError = 'Date of Birth cannot be empty';
      return false;
    } else {
      _dobError = null;
      return true;
    }
  }

  bool validateCity(String value) {
    if (value.isEmpty) {
      _cityError = 'City cannot be empty';
      return false;
    } else if (RegExp(r'[0-9]').hasMatch(value)) {
      _cityError = 'City cannot contain numbers';
      return false;
    } else {
      _cityError = null;
      return true;
    }
  }

  bool validateState(String value) {
    if (value.isEmpty) {
      _stateError = 'State cannot be empty';
      return false;
    } else if (RegExp(r'[0-9]').hasMatch(value)) {
      _stateError = 'State cannot contain numbers';
      return false;
    } else {
      _stateError = null;
      return true;
    }
  }

  bool validateGender(String value) {
    if (value.isEmpty) {
      _genderError = 'Please select a gender';
      return false;
    } else {
      _genderError = null;
      return true;
    }
  }

  bool validateAge(String value) {
    if (value.isEmpty) {
      _ageError = 'Age cannot be empty';
      return false;
    } else if (!RegExp(r'^[1-9]\d*$').hasMatch(value)) {
      _ageError = 'Please enter a valid age';
      return false;
    } else {
      _ageError = null;
      return true;
    }
  }

  bool validateHeight(String value) {
    if (value.isEmpty) {
      _heightError = 'Height cannot be empty';
      return false;
    } else if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
      _heightError = 'Please enter a valid height in cms';
      return false;
    } else {
      _heightError = null;
      return true;
    }
  }

  bool validateWeight(String value) {
    if (value.isEmpty) {
      _weightError = 'Weight cannot be empty';
      return false;
    } else if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
      _weightError = 'Please enter a valid weight in kg';
      return false;
    } else {
      _weightError = null;
      return true;
    }
  }

  bool validateAllFields() {
    return validateFirstName(firstnameController.text) &&
        validateLastName(lastnameController.text) &&
        validateDOB(dobController.text) &&
        validateCity(cityController.text) &&
        validateState(stateController.text) &&
        validateGender(genderController.text) &&
        validateAge(ageController.text) &&
        validateHeight(heightController.text) &&
        validateWeight(weightController.text);
  }

  void _selectGenderType() {
    showModalBottomSheet<int>(
      backgroundColor: Colors.white,
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
                            color: Colors.black54, fontWeight: FontWeight.w400),
                      ),
                      onTap: () {
                        setState(() {
                          genderController.text = gender;
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

  void _selectDiabetesType() {
    showModalBottomSheet<int>(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return Popover(
          height: 150,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Wrap(
                children: diabetesList.map((diabetesType) {
                  return CheckboxListTile(
                    checkboxShape: CircleBorder(),
                    checkColor: Colors.white,
                    activeColor: Colors.green,
                    title: Text(
                      diabetesType,
                      style: TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.w400),
                    ),
                    value: selectedDiabetesTypes.contains(diabetesType),
                    onChanged: (bool? value) {
                      setModalState(() {
                        if (value == true) {
                          selectedDiabetesTypes.add(diabetesType);
                          print(selectedDiabetesTypes);
                        } else {
                          selectedDiabetesTypes.remove(diabetesType);
                          print(selectedDiabetesTypes);
                        }
                      });
                      setState(() {
                        if (selectedDiabetesTypes.contains('Diabetes') ==
                            true) {
                          setState(() {
                            diabeties = true;
                            print('my diabeties status $diabeties');
                          });
                        } else {
                          setState(() {
                            diabeties = false;
                            print('my diabeties status $diabeties');
                          });
                        }
                        if (selectedDiabetesTypes.contains('HyperTension') ==
                            true) {
                          setState(() {
                            hypertension = true;
                            print('my hyper status $hypertension');
                          });
                        } else {
                          setState(() {
                            hypertension = false;
                            print('my hyper status $hypertension');
                          });
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }

  void _selectWeight() {
    showModalBottomSheet<int>(
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
                    child: CupertinoTheme(
                      data: CupertinoThemeData(brightness: Brightness.light),
                      child: DivisionSlider(
                        from: 20,
                        max: 250,
                        initialValue: tempWeight,
                        type: WeightType.kg,
                        onChanged: (value) =>
                            setModalState(() => tempWeight = value),
                        title: "Weight",
                      ),
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
                      initialValue: tempHeight,
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: <Color>[
            const Color.fromARGB(255, 14, 96, 164),
            const Color.fromARGB(255, 5, 53, 93)
          ])),
          child: Column(
            children: [
              SizedBox(
                height: height * 0.08,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "COMPLETE YOUR PROFILE",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.025,
                  ),
                ),
              ),
              
              SizedBox(
                height: height * 0.05,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    children: [
                      TextFormField(
                        cursorColor: Colors.black,
                        selectionControls: CupertinoTextSelectionControls(),
                        controller: firstnameController,
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 12),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 177, 177, 177),
                            // size: height * 0.025,
                          ),
                          hintText: 'First Name',
                          errorText: _firstNameError,
                          hintStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w400),
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.isEmpty) {
                              _firstNameError = 'Name cannot be empty';
                            } else if (RegExp(r'[0-9]').hasMatch(value)) {
                              _firstNameError = 'Name cannot contain numbers';
                            } else if (RegExp(r'\s').hasMatch(value)) {
                              _firstNameError = 'Name cannot contain spaces';
                            } else {
                              _firstNameError = null;
                            }
                          });
                        },
                      ),
                      SizedBox(
                        height: height * 0.015,
                      ),
                      TextFormField(
                        cursorColor: Colors.black,
                        selectionControls: CupertinoTextSelectionControls(),
                        controller: lastnameController,
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 12),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color.fromARGB(255, 177, 177, 177),
                            // size: height * 0.025,
                          ),
                          hintText: 'Last Name',
                          errorText: _lastNameError,
                          hintStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w400),
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.isEmpty) {
                              _lastNameError = 'Name cannot be empty';
                            } else if (RegExp(r'[0-9]').hasMatch(value)) {
                              _lastNameError = 'Name cannot contain numbers';
                            } else if (RegExp(r'\s').hasMatch(value)) {
                              _lastNameError = 'Name cannot contain spaces';
                            } else {
                              _lastNameError = null;
                            }
                          });
                        },
                      ),
                      SizedBox(
                        height: height * 0.015,
                      ),
                      TextFormField(
                        readOnly: true,
                        controller: dobController,
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 12),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          prefixIcon: Icon(
                            Icons.calendar_month,
                            color: Color.fromARGB(255, 177, 177, 177),
                            // size: height * 0.025,
                          ),
                          hintText: 'Date of Birth',
                          errorText: _dobError,
                          hintStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w400),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            backgroundColor: Colors.white,
                            context: context,
                            builder: (context) {
                              return Container(
                                // color: Colors.white,
                                height: height * 0.35,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: height * 0.25,
                                        child: CupertinoTheme(
                                          data: CupertinoThemeData(
                                            brightness: Brightness.light,
                                          ),
                                          child: CupertinoDatePicker(
                                            initialDateTime: selectedData,
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
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Color.fromRGBO(
                                                          255, 87, 87, 1),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 30,
                                                          vertical: 10),
                                                      child: Center(
                                                        child: Text(
                                                          'CANCEL',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: height *
                                                                  0.016),
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    dobController.text =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(
                                                                selectedData);

                                                    int age =
                                                        DateTime.now().year -
                                                            selectedData.year;

                                                    if (DateTime.now().month <
                                                            selectedData
                                                                .month ||
                                                        (DateTime.now().month ==
                                                                selectedData
                                                                    .month &&
                                                            DateTime.now().day <
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
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Color.fromRGBO(
                                                          112, 217, 136, 1),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 30,
                                                          vertical: 10),
                                                      child: Center(
                                                        child: Text(
                                                          'SELECT',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: height *
                                                                  0.016),
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
                      SizedBox(
                        height: height * 0.015,
                      ),
                      Column(
                        children: [
                          TextFormField(
                            cursorColor: Colors.black,
                            selectionControls: CupertinoTextSelectionControls(),
                            controller: stateController,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(top: 12),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 177, 177, 177),
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 177, 177, 177),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 177, 177, 177),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.location_city,
                                color: Color.fromARGB(255, 177, 177, 177),
                              ),
                              hintText: 'Select State',
                              errorText: _stateError,
                              hintStyle: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                showStatelist = true;
                                if (value.isEmpty) {
                                  showStatelist = false;
                                  _stateError = 'Please enter your state';
                                } else if (RegExp(r'[0-9]').hasMatch(value)) {
                                  _stateError = 'State cannot contain numbers';
                                } else {
                                  _stateError = null;
                                }
                              });
                            },
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.fastOutSlowIn,
                            decoration: BoxDecoration(
                              color: AppColor.backgroundColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            height: showStatelist ? 50 : 0,
                            child: FutureBuilder<List<Statemodel>>(
                              future: Future.delayed(
                                  Duration(milliseconds: 300), () {
                                return getStateList();
                              }),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox();
                                } else if (snapshot.hasError) {
                                  return SizedBox();
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                      child: Text('No data available'));
                                } else {
                                  final items = snapshot.data!;
                                  final filteredItems = items
                                      .where((item) => item.name!
                                          .toLowerCase()
                                          .contains(stateController.text
                                              .toLowerCase()))
                                      .toList();

                                  return ListView.builder(
                                    padding: EdgeInsets.all(0),
                                    itemCount: filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final stateItem = filteredItems[index];
                                      return ListTile(
                                        title: Text(
                                          stateItem.name!,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            stateController.text =
                                                stateItem.name!;
                                            showStatelist = false;
                                          });
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: height * 0.015,
                      ),
                      Column(
                        children: [
                          TextFormField(
                            cursorColor: Colors.black,
                            selectionControls: CupertinoTextSelectionControls(),
                            controller: cityController,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(top: 12),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 177, 177, 177),
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 177, 177, 177),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 177, 177, 177),
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: Color.fromARGB(255, 177, 177, 177),
                              ),
                              hintText: 'Select City',
                              errorText: _cityError,
                              hintStyle: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                showCityList = true;
                                if (value.isEmpty) {
                                  showCityList = false;
                                  _cityError = 'Please enter your city';
                                } else if (RegExp(r'[0-9]').hasMatch(value)) {
                                  _cityError = 'City cannot contain numbers';
                                } else {
                                  _cityError = null;
                                }
                              });
                            },
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.fastOutSlowIn,
                            decoration: BoxDecoration(
                              color: AppColor.backgroundColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            height: showCityList ? 50 : 0,
                            child: FutureBuilder<List<Citymodel>>(
                              future: Future.delayed(
                                  Duration(milliseconds: 300), () {
                                return getCityList(stateController.text);
                              }),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox();
                                } else if (snapshot.hasError) {
                                  return SizedBox();
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                      child: Text('No data available'));
                                } else {
                                  final items = snapshot.data!;
                                  final filteredItems = items
                                      .where((item) => item.name!
                                          .toLowerCase()
                                          .contains(cityController.text
                                              .toLowerCase()))
                                      .toList();

                                  return ListView.builder(
                                    padding: EdgeInsets.all(0),
                                    itemCount: filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final cityItems = filteredItems[index];
                                      return ListTile(
                                        title: Text(
                                          cityItems.name!,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            cityController.text =
                                                cityItems.name!;
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
                        ],
                      ),
                      SizedBox(
                        height: height * 0.015,
                      ),
                      TextFormField(
                        readOnly: true,
                        controller: genderController,
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 12),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          prefixIcon: Icon(
                            genderController.text == 'Male'
                                ? Icons.male
                                : Icons.female,
                            color: Color.fromARGB(255, 177, 177, 177),
                          ),
                          errorText: _genderError,
                          hintText: 'Select Gender',
                          hintStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w400),
                        ),
                        onTap: () {
                          _selectGenderType();
                        },
                      ),
                      SizedBox(
                        height: height * 0.022,
                      ),
                      TextFormField(
                        controller: ageController,
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 12),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          prefixIcon: Icon(
                            Icons.man_2_outlined,
                            color: Color.fromARGB(255, 177, 177, 177),
                          ),
                          errorText: _ageError,
                          suffixText: 'years',
                          hintText: 'Set Age',
                          hintStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w400),
                        ),
                        readOnly: true,
                        // onTap: () {
                        //   _selectAge();
                        // },
                        onChanged: (value) {
                          if (value.isEmpty) {
                            _ageError = 'Age cannot be empty';
                          } else if (!RegExp(r'^[1-9]\d*$').hasMatch(value)) {
                            _ageError = 'Please enter a valid age';
                          } else {
                            _ageError = null;
                          }
                        },
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      TextFormField(
                        readOnly: true,
                        controller: heightController,
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 12),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          prefixIcon: Icon(
                            Icons.height,
                            color: Color.fromARGB(255, 177, 177, 177),
                          ),
                          errorText: _heightError,
                          suffixText: 'cms',
                          hintText: 'Set Height',
                          hintStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w400),
                        ),
                        onTap: () {
                          _selectHeight();
                        },
                        onChanged: (value) {
                          if (value.isEmpty) {
                            _heightError = 'Height cannot be empty';
                          } else if (!RegExp(r'^\d+(\.\d+)?$')
                              .hasMatch(value)) {
                            _heightError = 'Please enter a valid height in cms';
                          } else {
                            _heightError = null;
                          }
                        },
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      TextFormField(
                        controller: weightController,
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                        readOnly: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 12),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          prefixIcon: Icon(
                            Icons.monitor_weight,
                            color: Color.fromARGB(255, 177, 177, 177),
                          ),
                          errorText: _weightError,
                          suffixText: 'kg',
                          hintText: 'Set Weight',
                          hintStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w400),
                        ),
                        onTap: () {
                          _selectWeight();
                        },
                        onChanged: (value) {
                          if (value.isEmpty) {
                            _weightError = 'Weight cannot be empty';
                          } else if (!RegExp(r'^\d+(\.\d+)?$')
                              .hasMatch(value)) {
                            _weightError = 'Please enter a valid weight in kg';
                          } else {
                            _weightError = null;
                          }
                        },
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      TextFormField(
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                        readOnly: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 12),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 177, 177, 177),
                          )),
                          prefixIcon: Icon(
                            Icons.health_and_safety_outlined,
                            color: Color.fromARGB(255, 177, 177, 177),
                          ),
                          hintText: selectedDiabetesTypes.isEmpty
                              ? 'Additional Diagnosis'
                              : selectedDiabetesTypes.join(','),
                          hintStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w400),
                        ),
                        onTap: () {
                          _selectDiabetesType();
                        },
                        onChanged: (value) {},
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (validateAllFields() &&
                                  selectedDiabetesTypes.isNotEmpty) {
                                setUpProfileApi(
                                    firstnameController.text,
                                    lastnameController.text,
                                    dobController.text,
                                    ageController.text,
                                    cityController.text,
                                    stateController.text,
                                    genderController.text,
                                    heightController.text,
                                    weightController.text,
                                    diabeties,
                                    hypertension,
                                    true,
                                    "",
                                    "",
                                    context);

                       
                              } else {
                                setState(() {
                                  if (selectedDiabetesTypes.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.error,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                "Please fill out all fields",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    fontSize: 15),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                });
                              }
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: height * 0.06,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(width: 1, color: Colors.white),
                                gradient: LinearGradient(colors: <Color>[
                                  const Color.fromARGB(255, 14, 96, 164),
                                  const Color.fromARGB(255, 5, 53, 93)
                                ])),
                            child: Center(
                              child: Text(
                                "SUBMIT",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: height * 0.02),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
