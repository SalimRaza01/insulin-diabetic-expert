import 'package:animated_icon/animated_icon.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api_config.dart';
import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../data/providers/basal_delivery_provider.dart';
import '../../../data/providers/bolus_delivery_provider.dart';
import '../../../data/providers/glucose_provider.dart';
import '../../../data/providers/smart_bolus_delivery_provider.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();
class ChartDataInfo {
  ChartDataInfo(this.time, this.value, [this.color]);

  final String time;
  final double value;
  final Color? color;
}

final List<ChartDataInfo> data24Hours = List.generate(
  24,
  (index) => ChartDataInfo(
      index.toString(), (index + 1) * 5.0, AppColor.insulinChartColor),
);

class Insulinchart extends StatefulWidget {
  const Insulinchart({Key? key}) : super(key: key);

  @override
  _InsulinchartState createState() => _InsulinchartState();
}

class _InsulinchartState extends State<Insulinchart> {
  final List<String> periods = ['Week', 'Month', 'Year'];
  int currentIndex = 0;
  List<ChartDataInfo> chartData = [];
  bool refreshActive = false;

  @override
  void initState() {
    super.initState();
    _fetchInsulinChartData(periods[currentIndex]);
  }

  Future<void> _fetchInsulinChartData(String period) async {
    final dio = Dio();
    String? filter;


    final String? userId = await _hivedb.getString('userId');
 if (period == "Week") {
      filter = 'weekly';
    } else if (period == "Month") {
      filter = '30days-data';
    } else if (period == "Year") {
      filter = '12month-data';
    }

    print(period.toLowerCase());

    final response = await dio.get(
      '$insulinData/$userId',
      queryParameters: {'filter': filter},
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];

      setState(() {
        chartData = data.map<ChartDataInfo>((item) {
          return ChartDataInfo(
            item['time'],
            double.parse(item['unit']),
            AppColor.insulinChartColor,
          );
        }).toList();
      });
    } else {
      setState(() {
        ChartDataInfo(
          '',
          0,
          AppColor.smartbolusChartColor,
        );
      });
      print('Failed to load data');
    }
  }

  void _updateChartData() {
    setState(() {
      currentIndex = (currentIndex + 1) % periods.length;
      print(currentIndex);
    });
    _fetchInsulinChartData(periods[currentIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Consumer4<SmartBolusDelivery, Bolusdelivery, BasalDelivery, GlucoseDelivery>(builder: (context, smartbolusvalue, bolusValue, basalValue, glucoseValue, child) {
    if(smartbolusvalue == true || bolusValue == true || basalValue == true || glucoseValue == true){
          _fetchInsulinChartData(periods[currentIndex]);
    }

      return Container(
        height: height * 0.3,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'INSULIN',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          fontSize: height * 0.015,
                          fontWeight: AppColor.weight600),
                    ),
                    GestureDetector(
                      onTap: _updateChartData,
                      child: Text(
                        periods[currentIndex],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primaryContainer,
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
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        fontSize: height * 0.014,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.02,
                    ),
                    AnimateIcon(
                      onTap: () {
                         _fetchInsulinChartData(periods[currentIndex]);
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
                  tooltipBehavior: TooltipBehavior(color: Colors.red),
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
                    axisLine: AxisLine(color: Colors.grey),
                    majorTickLines: MajorTickLines(color: Colors.grey),
                    interval: 1,
                    majorGridLines: MajorGridLines(width: 0),
                    labelStyle: TextStyle(
                      fontSize: 8,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  series: <CartesianSeries<dynamic, dynamic>>[
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
              )
            ],
          ),
        ),
      );
    }
    );
  }
}
