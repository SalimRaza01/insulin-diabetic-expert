import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_service.dart';
import '../../data/providers/profile_updated_provider.dart';
import '../animations/animation_shimmer.dart';
import '../widgets/drawer_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import 'update_profile_screen.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> genderList = ['Male', 'Female'];
  List<String> diabetesList = ['Diabetes', 'HyperTension'];
  String selectedGender = 'Select Gender';

  bool showPassword = false;
  bool isEditMode = false;
  bool hyperTension2 = false;
  bool diabetes2 = false;
  File? _image;
  String? filepath;
  String? inputcheck;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getProfileData();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    filepath = await _hivedb.getString('profileImage');
    print(_hivedb.getString('profileImage'));

    setState(() {
      _image = File(filepath!);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    PermissionStatus permissionStatus;

    permissionStatus = await Permission.camera.request();

    if (permissionStatus.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          filepath = pickedFile.path;
        });
        await _hivedb.putImageFile('profileImage', _image!);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission not granted')),
      );
    }
  }

  Future<void> _filepicker(ImageSource source) async {
    PermissionStatus permissionStatus;

    permissionStatus = await Permission.storage.request();

    if (permissionStatus.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          filepath = pickedFile.path;
          print('this is my set image $_image');
        });
        await _hivedb.putString('profileImage', filepath!);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission not granted')),
      );
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: <Widget>[
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              title: Text(
                'Photo Library',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
              ),
              onTap: () {
                _filepicker(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_camera,
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              title: Text(
                'Camera',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
              ),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            Visibility(
              visible: _image != null,
              child: ListTile(
                leading: Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                title: Text(
                  'Remove Current Profile',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: ()  {
                  // setState(() {
                  //   _image = null;
                  // });
                  //  _hivedb
                  //     .putImageFile('profileImage', _image!);

                    Navigator.of(context).pop();
                
                },
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.cancel,
                color: Colors.red,
              ),
              title: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
        drawer: AppDrawerNavigation('PROFILESCREEN'),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          elevation: 1,
          centerTitle: true,
          title: Text(
            "PROFILE",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Consumer<ProfileUpdateNotifier>(
          builder: (context, value, child) {
            if (value.updatedProfile == true) {
              getProfileData();
              Future.delayed(Duration(seconds: 2), () {
                Provider.of<ProfileUpdateNotifier>(context, listen: false)
                    .updateProfile(false);
              });
            }
            return SingleChildScrollView(
              child: Container(
                height: height,
                width: width,
                padding: EdgeInsets.only(left: 16, top: 25, right: 16),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: FutureBuilder(
                          future: getProfileData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ShimmereffectProfile();
                            } else if (snapshot.hasError) {
                              return WithOutShimmerProfile();
                            } else {
                              final items = snapshot.data!;
                              print('my profile data  ${items.age}');

                              firstNameController.text =
                                  items.firstName.toString();
                              lastNameController.text =
                                  items.lastName.toString();
                              dobController.text = items.dob.toString();
                              ageController.text = items.age.toString();
                              phoneController.text = items.phone.toString();
                              emailController.text = items.email.toString();
                              stateController.text = items.state.toString();
                              cityController.text = items.city.toString();
                              heightController.text = items.height.toString();
                              weightController.text = items.weight.toString();
                              selectedGender = items.gender.toString();
                              hyperTension2 = items.hypertension!;
                              diabetes2 = items.diabetes!;

                              return Column(
                                children: [
                                  Container(
                                    width: width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Textfield(
                                              height: height,
                                              items: items.firstName,
                                              items2: items.lastName,
                                              title: "Full Name"),
                                          Container(
                                            width: width / 2.4,
                                            child: Divider(
                                              thickness: 1,
                                              color: Color.fromARGB(
                                                  155, 174, 174, 174),
                                            ),
                                          ),
                                          Textfield(
                                              height: height,
                                              items: items.phone,
                                              title: "Phone"),
                                          Divider(
                                            thickness: 1,
                                            color: Color.fromARGB(
                                                155, 174, 174, 174),
                                          ),
                                          Textfield(
                                              height: height,
                                              items: items.email,
                                              title: "Email"),
                                          Divider(
                                            thickness: 1,
                                            color: Color.fromARGB(
                                                155, 174, 174, 174),
                                          ),
                                          Textfield(
                                              height: height,
                                              items: items.city,
                                              title: "City"),
                                          Divider(
                                            thickness: 1,
                                            color: Color.fromARGB(
                                                155, 174, 174, 174),
                                          ),
                                          Textfield(
                                              height: height,
                                              items: items.state,
                                              title: "State"),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.03,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          child: Divider(
                                            thickness: 1,
                                            color: Color.fromARGB(
                                                155, 174, 174, 174),
                                          ),
                                          width: width * 0.3,
                                        ),
                                        Text('DEMOGRAPHIC',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 169, 167, 167),
                                                fontSize: height * .015,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          child: Divider(
                                            thickness: 1,
                                            color: Color.fromARGB(
                                                155, 174, 174, 174),
                                          ),
                                          width: width * 0.3,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.03,
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: height * 0.09,
                                            width: width * 0.3,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8, left: 15, right: 15),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Gender',
                                                    style: TextStyle(
                                                      fontSize: height * 0.014,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.01,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Image.asset(
                                                        items.gender == 'Male'
                                                            ? 'assets/images/Male.png'
                                                            : 'assets/images/Female.png',
                                                        height: height * 0.032,
                                                      ),
                                                      Text(
                                                          items.gender!
                                                                  .contains(
                                                                      'Select')
                                                              ? ' '
                                                              : items.gender!,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondaryContainer,
                                                              fontSize:
                                                                  height * .015,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: height * 0.09,
                                            width: width * 0.3,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8, left: 15, right: 15),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Height',
                                                    style: TextStyle(
                                                      fontSize: height * 0.014,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.01,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Image.asset(
                                                        items.gender == 'Male'
                                                            ? 'assets/images/Man.png'
                                                            : 'assets/images/Women.png',
                                                        height: height * 0.035,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(items.height!,
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondaryContainer,
                                                                  fontSize:
                                                                      height *
                                                                          .013,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                          Text('cms',
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondaryContainer,
                                                                  fontSize:
                                                                      height *
                                                                          .013,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: height * 0.09,
                                            width: width * 0.3,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8, left: 15, right: 15),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Weight',
                                                    style: TextStyle(
                                                      fontSize: height * 0.014,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.01,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/Vector.png',
                                                        height: height * 0.035,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(items.weight!,
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondaryContainer,
                                                                  fontSize:
                                                                      height *
                                                                          .013,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                          Text('kg',
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondaryContainer,
                                                                  fontSize:
                                                                      height *
                                                                          .013,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: height * 0.02,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: height * 0.09,
                                            width: width * 0.45,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8, left: 20, right: 20),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Date of Birth',
                                                    style: TextStyle(
                                                      fontSize: height * 0.014,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.01,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/Calenderr.png',
                                                        height: height * 0.035,
                                                      ),
                                                      Text(items.dob!,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondaryContainer,
                                                              fontSize:
                                                                  height * .015,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: height * 0.09,
                                            width: width * 0.45,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8, left: 20, right: 20),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Diagnosis',
                                                    style: TextStyle(
                                                      fontSize: height * 0.014,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.01,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/Diagnosis1.png',
                                                        height: height * 0.035,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          if (items.diabetes ==
                                                              true)
                                                            Text('Diabetes',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .secondaryContainer,
                                                                    fontSize:
                                                                        height *
                                                                            .013,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500)),
                                                          if (items
                                                                  .hypertension ==
                                                              true)
                                                            Text('Hypertension',
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .secondaryContainer,
                                                                    fontSize:
                                                                        height *
                                                                            .013,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: height * 0.03,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 70),
                                    child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      UpdateProfile(
                                                          firstNameController
                                                              .text,
                                                          lastNameController
                                                              .text,
                                                          dobController.text,
                                                          ageController.text,
                                                          phoneController.text,
                                                          emailController.text,
                                                          stateController.text,
                                                          cityController.text,
                                                          heightController.text,
                                                          weightController.text,
                                                          selectedGender,
                                                          hyperTension2,
                                                          diabetes2)));
                                        },
                                        child: Container(
                                          height: height * 0.06,
                                          width: width / 2.5,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            border: Border.all(),
                                          ),
                                          child: Center(
                                              child: Text(
                                            'EDIT PROFILE',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: height * 0.02,
                                            ),
                                          )),
                                        )),
                                  ),
                                ],
                              );
                            }
                          }),
                    ),
                    Positioned(
                      right: 30,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          _showPicker(context);
                        },
                        child: Container(
                          width: width * 0.32,
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: width * 0.01,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.1),
                                  offset: Offset(0, 10))
                            ],
                            shape: BoxShape.circle,
                          ),
                          child: _image == null
                              ? ClipOval(
                                  child: Image.asset(
                                    'assets/images/avatar.png',
                                    height: height * 0.14,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ClipOval(
                                  child: Image.file(
                                    _image!,
                                    height: height * 0.14,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}

class Textfield extends StatelessWidget {
  Textfield(
      {super.key, required this.height, this.items, this.items2, this.title});

  final double height;
  String? items;
  String? items2;
  String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title!.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primaryContainer,
                fontSize: height * .011,
              )),
          if (items2 == null)
            Text('${items!.toUpperCase()}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  fontSize: height * .015,
                )),
          if (items2 != null)
            Text('${items!.toUpperCase()} ${items2!.toUpperCase()}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  fontSize: height * .015,
                ))
        ],
      ),
    );
  }
}
