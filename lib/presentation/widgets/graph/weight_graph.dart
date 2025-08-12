import 'dart:async';
import 'package:animated_icon/animated_icon.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api_config.dart';
import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../data/providers/weight_provider.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();
class WeightChart extends StatefulWidget {
  const WeightChart({Key? key}) : super(key: key);

  @override
  _WeightChartState createState() => _WeightChartState();
}

class _WeightChartState extends State<WeightChart> {
  final List<String> periods = ['Month', 'Year'];

  late PageController _pageController;
  int currentIndex = 0;
  int pageIndex = 0;
  String? thisWeek;
  List<ChartDataInfo> chartData = [];
  bool refreshActive = false;

  void _updateChartData() {
    setState(() {
      currentIndex = (currentIndex + 1) % periods.length;
      print(currentIndex);
    });
    _fetchChartData(periods[currentIndex]);
  }

  Future<void> _fetchChartData(String period) async {
    final dio = Dio();
    String? filter;

    if (period == "Year") {
      filter = '12month-data';
    } else if (period == "Month") {
      filter = '30days-data';
    }

    print(period.toLowerCase());
    final String? userId = await _hivedb.getString('userId');
    final response = await dio.get(
      '$getWeightChartData/$userId',
      queryParameters: {'filter': filter},
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];

      setState(() {
        chartData = data.map<ChartDataInfo>((item) {
          return ChartDataInfo(
            item['time'],
            double.parse(item['weight']),
            AppColor.weightChartColor,
          );
        }).toList();
      });
    } else {
      print('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // _getMonthbyDayData(0);
    _fetchChartData(periods[currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Consumer<WeightSetup>(
      builder: (context, weightchart, child) {
        if (weightchart.weightStatus == true) {
          print('weight updated');
          _fetchChartData(periods[currentIndex]);
      Provider.of<WeightSetup>(context, listen: false)
          .weightUpdate(false);
        }

        return Container(
          height: height * 0.3,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 9,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'WEIGHT',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                fontSize: height * 0.015,
                                fontWeight: AppColor.weight600),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _updateChartData,
                        child: Text(
                          periods[currentIndex],
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            fontSize: height * 0.015,
                            fontWeight: AppColor.weight600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
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
                          _fetchChartData(periods[currentIndex]);
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
                ),
                SizedBox(height: height * 0.01),
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
                    plotAreaBorderWidth: 0.1,
                    primaryXAxis: CategoryAxis(
                      axisLine: AxisLine(color: Colors.grey),
                      majorTickLines: MajorTickLines(color: Colors.grey),
                      labelRotation: 0,
                               interval: periods[currentIndex] == 'Month' ? 0.22 : 1,
                      minimum: 0,
                      majorGridLines: MajorGridLines(width: 0),
                      labelStyle: TextStyle(
                        fontSize: 8,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      interval: 1,
                      axisLine: AxisLine(color: Colors.grey),
                      majorTickLines: MajorTickLines(color: Colors.grey),
                      majorGridLines: MajorGridLines(
                        width: 0,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 8,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    series: <CartesianSeries>[
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChartDataInfo {
  final String time;
  final double value;
  final Color? color;

  ChartDataInfo(this.time, this.value, [this.color]);
}
