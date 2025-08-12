import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class CarbsIntakeInput extends StatelessWidget {
  final TextEditingController controller;
  final String title;

  CarbsIntakeInput({required this.controller, this.title = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.primary,
        //         border: Border.all(
        //   color: Colors.black,
        //   width: 0.2,
        // ),
        
          //   boxShadow: [
          //     BoxShadow(
          //       color: const Color.fromARGB(134, 158, 158, 158),
          //       blurRadius: 5,
          //     ),
          //  ]
            ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  title,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary, fontSize: 16),
                ),
              ),
              SizedBox(
                child: Image.asset('assets/images/info.png'),
                height: 20,
                width: 20,
              ),
              SizedBox(
                width: 100,
                height: 30,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0 gram',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,fontWeight: AppColor.lightWeight
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  height: 40,
                  width: 2,
                  color: Colors.grey,
                ),
              ),
              GestureDetector(
                child: SizedBox(
                  child: Image.asset('assets/images/editicon.png'),
                  height: 18,
                  width: 20,
                ),
              ),
            ],
          ),
        ));
  }
}
