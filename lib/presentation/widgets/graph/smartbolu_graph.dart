import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api_config.dart';
import '../../../core/constants/app_colors.dart';

import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../data/providers/smart_bolus_delivery_provider.dart';
import '../../animations/animation_shimmer.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();
class ChartDataInfo {
  ChartDataInfo(this.time, this.value, [this.color]);

  final String time;
  final double value;
  final Color? color;
}

class SmartBolusWidget extends StatefulWidget {
  @override
  State<SmartBolusWidget> createState() => _SmartBolusWidgetState();
}

class _SmartBolusWidgetState extends State<SmartBolusWidget> {
  Future<void>? _smartBolusChart;
  List<ChartDataInfo> chartData = [];

  @override
  void initState() {
    super.initState();
    _smartBolusChart = _fetchChartData();
    print('inside smartbolus graph');
  }

  Future<void> _fetchChartData() async {
    final dio = Dio();


    final String? userId = await _hivedb.getString('userId');
    print('inside smartbolus graph 2');
    try {
      final response = await dio.get(
        '$smartBolasData/$userId',
        queryParameters: {'filter': 'today'},
      );

      if (response.statusCode == 200) {
        print('inside smartbolus graph 3');
        final data = response.data['data'] as List<dynamic>;

        setState(() {
          chartData = data.map<ChartDataInfo>((item) {
            return ChartDataInfo(
              item['time'],
              double.parse(item['unit']),
              AppColor.smartbolusChartColor,
            );
          }).toList();
        });
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print('Error fetching chart data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Consumer<SmartBolusDelivery>(builder: (context, value, child) {
      if (value.sbolusStatus == true) {
        _smartBolusChart = _fetchChartData();
        Provider.of<SmartBolusDelivery>(context, listen: false)
            .updateSmartBolusValue(false);
      }
      return Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SMART',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      fontSize: height * 0.023,
                    ),
                  ),
                  Text(
                    'BOLUS',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      fontSize: height * 0.023,
                    ),
                  ),
                ],
              ),
              FutureBuilder(
                future: _smartBolusChart,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SmartBolusOuterShimmereffect();
                  } else if (snapshot.hasError || chartData.isEmpty) {
                    return Center(
                      child: Text(
                        'No Data found',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer),
                      ),
                    );
                  } else {
                    return Container(
                      width: width * 0.65,
                      height: height * 0.09,
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0.0,
                        primaryXAxis: CategoryAxis(
                          majorTickLines: MajorTickLines(width: 0.0),
                          axisLine: AxisLine(width: 0),
                          labelRotation: 0,
                          majorGridLines: MajorGridLines(width: 0.0),
                          interval: 2,
                          labelStyle: TextStyle(
                            fontSize: 10,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          majorTickLines: MajorTickLines(width: 0.0),
                          axisLine: AxisLine(width: 0),
                          labelRotation: 0,
                          majorGridLines: MajorGridLines(width: 0.0),
                          labelStyle: TextStyle(
                            fontSize: 10,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                        series: <CartesianSeries<dynamic, dynamic>>[
                          ColumnSeries<ChartDataInfo, String>(
                            borderRadius: BorderRadius.circular(50),
                            width: 0.6,
                            dataSource: chartData,
                            pointColorMapper: (ChartDataInfo data, _) =>
                                data.color,
                            xValueMapper: (ChartDataInfo data, _) => data.time,
                            yValueMapper: (ChartDataInfo data, _) => data.value,
                            enableTooltip: false,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              angle: 0,
                              margin: EdgeInsets.all(0),
                              builder: (
                                data,
                                point,
                                series,
                                pointIndex,
                                seriesIndex,
                              ) {
                                if (chartData[pointIndex].value == 0) {
                                  return Icon(
                                    Icons.circle,
                                    color: Color.fromARGB(255, 207, 207, 207),
                                    size: 3,
                                  );
                                } else {
                                  return SizedBox();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
