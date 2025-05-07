import 'package:INSUL/core/utils/sharedpref_utils.dart';
import 'package:flutter/material.dart';

class BloodCount extends StatelessWidget {
  BloodCount({Key? key}) : super(key: key);

  final TextEditingController bloodCountController = TextEditingController();

  final TextEditingController bloodPressureController = TextEditingController();

  final SharedPrefsHelper pref = SharedPrefsHelper();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 226, 122, 0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: height * 0.035,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "WANT TO ADD",
                    style: TextStyle(
                        fontSize: height * 0.02,
                        color: Colors.white,
                        fontWeight: FontWeight.w300),
                  ),
                  Text(
                    "Blood count & Blood pressure !".toUpperCase(),
                    style: TextStyle(
                        fontSize: height * 0.015,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(
                width: width * 0.01,
              ),
              Icon(
                Icons.water_drop,
                size: height * 0.05,
                color: Colors.white,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'NOT NOW',
                    style: TextStyle(
                      fontSize: height * 0.015,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        context: context,
                        builder: (BuildContext context) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                            child: Container(
                              // height: height * 0.35,
                              width: width,
                              child: Padding(
                                padding: MediaQuery.of(context)
                                    .viewInsets, // for keyboard
                                child: SingleChildScrollView(
                                  child: Container(
                                    padding: const EdgeInsets.all(18.0),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: height * 0.02),
                                        Text(
                                          "Blood count & Blood pressure"
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: height * 0.018,
                                            color:  Theme.of(context)
                                                        .colorScheme
                                                        .onInverseSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.water_drop_outlined,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller:
                                                      bloodCountController,
                                                  cursorColor: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onInverseSurface,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    labelText:
                                                        "ENTER BLOOD COUNT",
                                                    labelStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onInverseSurface,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.monitor_heart,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller:
                                                      bloodPressureController,
                                                  cursorColor: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onInverseSurface,
                                                  ),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    labelText:
                                                        "ENTER BLOOD PRESSURE",
                                                    labelStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onInverseSurface,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 25),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF05355D),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            minimumSize: Size(
                                                width * 0.4, height * 0.05),
                                          ),
                                          onPressed: () {
                                            pref.putString('BloodSugarCount',
                                                bloodCountController.text);
                                            pref.putString('BloodPressure',
                                                bloodPressureController.text);
                                            Navigator.pop(
                                                context, "Data Saved");
                                          },
                                          child: Text(
                                            "SUBMIT",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: height * 0.018,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  },
                  child: Text(
                    'CHECK',
                    style: TextStyle(
                      fontSize: height * 0.015,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
