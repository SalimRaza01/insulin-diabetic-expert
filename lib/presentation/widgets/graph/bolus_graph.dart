import 'package:INSUL/core/utils/hive_db_utils.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/api/api_config.dart';
import '../../../core/constants/app_colors.dart';

import '../../../data/providers/bolus_delivery_provider.dart';
  final _hivedb = HiveDbHelper();
class ChartDataInfo {
  ChartDataInfo(this.time, this.unit, [this.color]);

  final String time;
  final double unit;
  final Color? color;
}

class Bolusgraph extends StatefulWidget {
  const Bolusgraph({Key? key}) : super(key: key);

  @override
  _BolusgraphState createState() => _BolusgraphState();
}

class _BolusgraphState extends State<Bolusgraph> {
  final List<String> periods = ['Today', 'Week', 'Month', 'Year'];
  int currentIndex = 0;
  List<ChartDataInfo> chartData = [];
  
bool refreshActive = false;

  @override
  void initState() {
    super.initState();
    _fetchChartData(periods[currentIndex]);
  }

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
    if (period == "Today") {
      filter = 'today';
    } else if (period == "Week") {
      filter = 'weekly';
    } else if (period == "Month") {
      filter = '30days-data';
    } else if (period == "Year") {
      filter = '12month-data';
    }

    print(period.toLowerCase());
    final String? userId = await _hivedb.getString('userId');
    final response = await dio.get(
      '$getBolusGraphData/$userId',
      queryParameters: {'filter': filter},
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];

      setState(() {
        chartData = data.map<ChartDataInfo>((item) {
          return ChartDataInfo(
            item['time'],
            double.parse(item['unit']),
            AppColor.bolusChartColor,
          );
        }).toList();
                if(filter == 'today'){
     double totalUnits = chartData.fold(0, (sum, item) => sum + item.unit);
      print('this is my Basal units $totalUnits');
_hivedb.putString('totalbolusvalue', totalUnits.toString());
        }
      });
    } else {
      print('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Consumer<Bolusdelivery>(
      builder:(context, bolusDelivery, child) {
        if(bolusDelivery.deliveryStatus == true){
          _fetchChartData(periods[currentIndex]);
      Provider.of<Bolusdelivery>(context, listen: false)
          .updateStatus(false);
        }
        return   Container(
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
                      'BOLUS RATE',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          fontSize: height * 0.015,
                          fontWeight: AppColor.weight600),
                    ),
                    GestureDetector(
                      onTap: () {
                        _updateChartData();
                      },
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
                      majorTickLines: MajorTickLines( color: Colors.grey),
                    labelRotation: 0,
                                      interval: periods[currentIndex] == 'Month' ? 0.22 : 1,
                    minimum: 0,
                    majorGridLines: MajorGridLines(width: 0),
                    labelStyle: TextStyle(fontSize: 8,color: Theme.of(context).colorScheme.primaryContainer,),
                  ),
                  primaryYAxis: NumericAxis(
                                  axisLine: AxisLine(color: Colors.grey),
                      majorTickLines: MajorTickLines( color: Colors.grey),
                    interval: 1,
                    majorGridLines: MajorGridLines(width: 0),
                    labelStyle: TextStyle(fontSize: 8,color: Theme.of(context).colorScheme.primaryContainer,),
                  ),
                  series: <CartesianSeries<dynamic, dynamic>>[
                    ColumnSeries<ChartDataInfo, String>(
                      width: 0.3,
                      spacing: 0,
                      dataSource: chartData,
                      pointColorMapper: (ChartDataInfo data, _) => data.color,
                      xValueMapper: (ChartDataInfo data, _) => data.time,
                      yValueMapper: (ChartDataInfo data, _) => data.unit,
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
        
      },
  
    );
  }
}
