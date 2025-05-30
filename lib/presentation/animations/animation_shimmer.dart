import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../screens/profile_screen.dart';

class Shimmereffect extends StatelessWidget {
  const Shimmereffect({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        height: height * 0.3,
        child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.onPrimary,
                highlightColor: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                        border: Border.all(width: 1.0)),
                    child: ExpansionTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        height: 40,
                        width: 40,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              width: width,
                              height: height * 0.02),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              width: width,
                              height: height * 0.02)
                        ],
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class ShimmereffectSmartBolus extends StatelessWidget {
  const ShimmereffectSmartBolus({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        height: height * 0.1,
        child: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Colors.grey,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                        border: Border.all(width: 1.0)),
                    child: ExpansionTile(
                      leading: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey),
                        height: 40,
                        width: 40,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey),
                              width: width,
                              height: height * 0.02),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey),
                              width: width,
                              height: height * 0.02)
                        ],
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey),
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class ShimmereffectGraph extends StatelessWidget {
  const ShimmereffectGraph({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.onPrimary,
      highlightColor: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: width * 0.8,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimary, width: 2),
                  bottom: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimary, width: 2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: height * 0.15,
                      width: width * 0.03,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: height * 0.15,
                      width: width * 0.03,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: height * 0.15,
                      width: width * 0.03,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: height * 0.15,
                      width: width * 0.03,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: height * 0.15,
                      width: width * 0.03,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: height * 0.15,
                      width: width * 0.03,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: height * 0.15,
                      width: width * 0.03,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: height * 0.15,
                      width: width * 0.03,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: height * 0.15,
                      width: width * 0.03,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: height * 0.15,
                      width: width * 0.03,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmereffectMealHistory extends StatelessWidget {
  const ShimmereffectMealHistory({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        height: height * 0.3,
        child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.primary,
                highlightColor: Colors.grey,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                        border: Border.all(width: 1.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              height: 30,
                              width: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      width: width * 0.6,
                                      height: height * 0.01),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      width: width * 0.6,
                                      height: height * 0.01)
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      width: width * 0.15,
                                      height: height * 0.01),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      width: width * 0.15,
                                      height: height * 0.01)
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      width: width * 0.15,
                                      height: height * 0.01),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      width: width * 0.15,
                                      height: height * 0.01)
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      width: width * 0.15,
                                      height: height * 0.01),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      width: width * 0.15,
                                      height: height * 0.01)
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      width: width * 0.15,
                                      height: height * 0.01),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      width: width * 0.15,
                                      height: height * 0.01)
                                ],
                              ),
                            ),
                          ],
                        )
                      ]),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class ShimmereffectWeightHistory extends StatelessWidget {
  const ShimmereffectWeightHistory({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        height: height * 0.3,
        child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.primary,
                highlightColor: const Color.fromARGB(132, 158, 158, 158),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.transparent,
                        border: Border.all(width: 1.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                height: height * 0.02,
                                width: width * 0.06,
                              ),
                              SizedBox(
                                width: width * .04,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                width: width * 0.12,
                                height: height * 0.02,
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            width: width * 0.06,
                            height: height * 0.02,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class ShimmereffectProfile extends StatelessWidget {
  const ShimmereffectProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.primary,
        highlightColor: const Color.fromARGB(132, 158, 158, 158),
        child: Container(
          height: height,
          width: width,
          padding: EdgeInsets.only(left: 16, top: 25, right: 16),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey,
                              ),
                              width: width * 0.4,
                              height: height * 0.025),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey,
                              ),
                              width: width * 0.45,
                              height: height * 0.025),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey,
                              ),
                              width: width * 0.8,
                              height: height * 0.025),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey,
                              ),
                              width: width * 0.8,
                              height: height * 0.025),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey,
                              ),
                              width: width * 0.8,
                              height: height * 0.025),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Divider(
                            thickness: 1,
                          ),
                          width: width * 0.2,
                        ),
                        Text('DEMOGRAPHIC',
                            style: TextStyle(
                                color: Color.fromARGB(255, 167, 167, 167),
                                fontSize: height * .015,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          child: Divider(
                            thickness: 1,
                          ),
                          width: width * 0.2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: height * 0.09,
                            width: width * 0.25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          Container(
                            height: height * 0.09,
                            width: width * 0.25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          Container(
                            height: height * 0.09,
                            width: width * 0.25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: height * 0.09,
                            width: width * 0.4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          Container(
                            height: height * 0.09,
                            width: width * 0.4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
              Positioned(
                right: 30,
                top: 0,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    border: Border.all(
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10,
                          color: Colors.black.withOpacity(1),
                          offset: Offset(0, 10))
                    ],
                    shape: BoxShape.circle,
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

class WithOutShimmerProfile extends StatelessWidget {
  const WithOutShimmerProfile({
    super.key, required this.waiting,

  });

  final bool waiting;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Skeletonizer(
      enabled: waiting,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        body: Container(
          height: height,
          width: width,
          padding: EdgeInsets.only(
            top: 25,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                 
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Container(
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Textfield(
                                height: height,
                                items: '-',
                                items2: '-',
                                title: "Full Name"),
                            Container(
                              width: 200,
                              child: Divider(
                                thickness: 1,
                              ),
                            ),
                            Textfield(height: height, items: '-', title: "Phone"),
                            Container(
                              width: 300,
                              child: Divider(
                                thickness: 1,
                              ),
                            ),
                            Textfield(height: height, items: '-', title: "Email"),
                            Divider(
                              thickness: 1,
                            ),
                            Textfield(height: height, items: '-', title: "City"),
                            Divider(
                              thickness: 1,
                            ),
                            Textfield(height: height, items: '-', title: "State"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Divider(
                            thickness: 1,
                          ),
                          width: width * 0.2,
                        ),
                        Text('DEMOGRAPHIC',
                            style: TextStyle(
                                color: Color.fromARGB(255, 167, 167, 167),
                                fontSize: height * .015,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          child: Divider(
                            thickness: 1,
                          ),
                          width: width * 0.2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: height * 0.09,
                            width: width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color.fromARGB(255, 255, 255, 255),
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
                                      fontWeight: FontWeight.w300,
                                      color: Color.fromARGB(255, 167, 167, 167),
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset(
                                        'assets/images/Male.png',
                                        height: height * 0.032,
                                      ),
                                      Text('--',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 167, 167, 167),
                                              fontSize: height * .015,
                                              fontWeight: FontWeight.bold)),
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
                              borderRadius: BorderRadius.circular(16),
                              color: Color.fromARGB(255, 255, 255, 255),
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
                                      fontWeight: FontWeight.w300,
                                      color: Color.fromARGB(255, 167, 167, 167),
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset(
                                        'assets/images/Man.png',
                                        height: height * 0.035,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('--',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 167, 167, 167),
                                                  fontSize: height * .013,
                                                  fontWeight: FontWeight.bold)),
                                          Text('cms',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 167, 167, 167),
                                                  fontSize: height * .013,
                                                  fontWeight: FontWeight.bold)),
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
                              borderRadius: BorderRadius.circular(16),
                              color: Color.fromARGB(255, 255, 255, 255),
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
                                      fontWeight: FontWeight.w300,
                                      color: Color.fromARGB(255, 167, 167, 167),
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset(
                                        'assets/images/Vector.png',
                                        height: height * 0.035,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('--',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 167, 167, 167),
                                                  fontSize: height * .013,
                                                  fontWeight: FontWeight.bold)),
                                          Text('kg',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 167, 167, 167),
                                                  fontSize: height * .013,
                                                  fontWeight: FontWeight.bold)),
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
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: height * 0.09,
                            width: width * 0.45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color.fromARGB(255, 255, 255, 255),
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
                                      fontWeight: FontWeight.w300,
                                      color: Color.fromARGB(255, 167, 167, 167),
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset(
                                        'assets/images/Calenderr.png',
                                        height: height * 0.035,
                                      ),
                                      Text('--/--/--',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 167, 167, 167),
                                              fontSize: height * .015,
                                              fontWeight: FontWeight.bold))
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
                              borderRadius: BorderRadius.circular(16),
                              color: Color.fromARGB(255, 255, 255, 255),
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
                                      fontWeight: FontWeight.w300,
                                      color: Color.fromARGB(255, 167, 167, 167),
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset(
                                        'assets/images/Diagnosis1.png',
                                        height: height * 0.035,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('--',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 167, 167, 167),
                                                  fontSize: height * .013,
                                                  fontWeight: FontWeight.bold)),
                                          Text('--',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 167, 167, 167),
                                                  fontSize: height * .013,
                                                  fontWeight: FontWeight.bold)),
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
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SmartBolusOuterShimmereffect extends StatelessWidget {
  const SmartBolusOuterShimmereffect({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
        child: Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.onPrimary,
      highlightColor: Theme.of(context).colorScheme.primary,
      child: Container(
          width: width * 0.65,
          height: height * 0.09,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.primary),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column()),
    ));
  }
}

class NutritionShimmereffectGraph extends StatelessWidget {
  const NutritionShimmereffectGraph({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.onPrimary,
      highlightColor: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          height: height * 0.4,
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    height: height * 0.1,
                    width: width * 0.03,
                  ),
                  Container(
                    width: width * 0.8,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary,
                            width: 2),
                        bottom: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary,
                            width: 2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            height: height * 0.10,
                            width: width * 0.03,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            height: height * 0.10,
                            width: width * 0.03,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            height: height * 0.10,
                            width: width * 0.03,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            height: height * 0.10,
                            width: width * 0.03,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            height: height * 0.10,
                            width: width * 0.03,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            height: height * 0.10,
                            width: width * 0.03,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            height: height * 0.10,
                            width: width * 0.03,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            height: height * 0.10,
                            width: width * 0.03,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            height: height * 0.10,
                            width: width * 0.03,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            height: height * 0.10,
                            width: width * 0.03,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                height: height * 0.01,
                width: width * 0.85,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
