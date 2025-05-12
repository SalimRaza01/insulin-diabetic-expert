
import 'package:intl/intl.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api_config.dart';
import '../../../core/theme/app_colors.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();
class TodaysStatus extends StatefulWidget {
  const TodaysStatus({Key? key});

  @override
  State<TodaysStatus> createState() => _TodaysStatusState();
}

class _TodaysStatusState extends State<TodaysStatus> {
double insulinDose = 0.0;
double insulinLevel = 0.0;
double glucoseMeter = 0.0;
String updateDate = '';
bool refreshActive = false;

  Future<void> getCurrentData() async {
    final dio = Dio();
    final String? userId = await _hivedb.getString('userId');
    print(' user $userId');
    try {
      final response = await dio.get(
        '$getCurrentReading/$userId',
        queryParameters: {'filter': 'today'},
      );

      if (response.statusCode == 200) {
        var data = response.data['data'][0];
   
     
        setState(() {
          insulinDose = double.parse(data['insulinCount']);
          insulinLevel = double.parse(data['insulineLevel']);
          glucoseMeter = double.parse(data['glucoseCount']);
        });
            
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      print('Error fetching data: $e');
      rethrow;
    }
  }


@override
  void initState() {
getCurrentData();
updateDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      // height: height * 0.28,
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.primary),
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TODAY'S READING",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    fontSize: height * 0.015,
                    fontWeight: AppColor.weight600,
                  ),
                ),
                Row(
                    children: [
                      Text(
                        refreshActive ? 'Refreshing..' : 'Tap to Refresh',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          fontSize: height * 0.014,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      AnimateIcon(
                        onTap: () {
                                  getCurrentData();
                          setState(() {
                            refreshActive = true;
                          });
                          Future.delayed(Duration(seconds: 1), () {
                            setState(() {
                              refreshActive = false;
                            });
                          });
                        },
                        iconType: IconType.animatedOnTap,
                        height: height * 0.02,
                        width: width * 0.04,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        animateIcon: AnimateIcons.refresh,
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(
              height: height * 0.03,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircularIndicator(
                  context: context,
                  value: glucoseMeter / 100,
                  size: height * 0.10,
                  progressColor: Color.fromARGB(255, 76, 76, 76),
                  valueText: glucoseMeter.toString(),
                  unitText: 'mg/dl',
                ),
                _buildCircularIndicator(
                  context: context,
                  value: insulinDose / 100,
                  size: height * 0.10,
                  progressColor: Color.fromARGB(255, 59, 177, 86),
                  valueText: insulinDose.toString(),
                  unitText: 'units/hr',
                ),
                _buildCircularIndicator(
                  context: context,
                  value: insulinLevel / 100,
                  size: height * 0.10,
                  progressColor: Color.fromARGB(255, 214, 86, 244),
                  valueText: insulinLevel.toString(),
                  unitText: 'units',
                ),
              ],
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLabel('GLUCOMETER', height, context),
                _buildLabel('INSULIN DOSE', height, context),
                _buildLabel('INSULIN LEVEL', height, context),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCircularIndicator({
    required double value,
    required double size,
    required Color progressColor,
    required String valueText,
    required String unitText,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: size,
              width: size,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: size * 0.1,
                color: progressColor,
                backgroundColor: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Text(
                    valueText,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        fontSize: size * 0.25), // Adjust font size as needed
                  ),
                  Text(
                    unitText,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        fontSize: size * 0.1), // Adjust font size as needed
                  )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text, double height, BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primaryContainer,
        fontSize: height * 0.013,
        fontWeight: AppColor.lightWeight,
      ),
    );
  }
}
