import 'package:animated_icon/animated_icon.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../core/api/api_service.dart';
import '../../core/api/api_config.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/weight_model.dart';
import '../../data/providers/weight_provider.dart';
import '../animations/animation_shimmer.dart';
import '../widgets/slider_widget.dart';
import '../widgets/graph/weight_graph.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();
class WeightTargetHistory {
  final double setweight;
  final DateTime selectedDate;

  WeightTargetHistory({
    required this.setweight,
    required this.selectedDate,
  });

  Map<String, dynamic> toJson() => {
        'setweight': setweight,
        'selectedDate': selectedDate.toIso8601String(),
      };

  static WeightTargetHistory fromJson(Map<String, dynamic> json) =>
      WeightTargetHistory(
        setweight: json['setweight'],
        selectedDate: DateTime.parse(json['selectedDate']),
      );
}

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  Future<List<WeightPostData>>? _weightHistory;
  int currentIndex = 0;
  WeightType weightType = WeightType.kg;
  double? tempWeight;
  double finalWeight = 0;
  bool show = false;

  final List<String> periods = ['Month', 'Year'];

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
    print(response);
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
    getLastWeight();
    _weightHistory = fetchWeightHistory();
    tempWeight = double.parse(_hivedb.getString('weight')!);
    print('weight from shared $tempWeight');
    _fetchChartData(periods[currentIndex]);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Consumer<WeightSetup>(builder: (context, weightchart, child) {
      if (weightchart.weightStatus == true) {
        print('weight updated');
        _fetchChartData(periods[currentIndex]);
        weightchart.weightStatus = false;
      }
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'WEIGHT',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Container(
                      height: height * 0.40,
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onHorizontalDragUpdate: (details) {},
                            child: Container(
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                          GestureDetector(
                                            onTap: _updateChartData,
                                            child: Text(
                                              periods[currentIndex],
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                fontSize: height * 0.015,
                                                fontWeight: AppColor.weight600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Text(
                                            refreshActive
                                                ? 'Refreshing..'
                                                : 'Tap to Refresh',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer,
                                              fontSize: height * 0.014,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(
                                            width: width * 0.02,
                                          ),
                                          AnimateIcon(
                                            onTap: () {
                                              _fetchChartData(
                                                  periods[currentIndex]);
                                              setState(() {
                                                refreshActive = true;
                                              });
                                              Future.delayed(
                                                  Duration(seconds: 1), () {
                                                setState(() {
                                                  refreshActive = false;
                                                });
                                              });
                                            },
                                            iconType: IconType.animatedOnTap,
                                            height: height * 0.02,
                                            width: width * 0.04,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          textStyle: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            fontSize: height * 0.013,
                                          ),
                                        ),
                                        plotAreaBorderWidth: 0.1,
                                        primaryXAxis: CategoryAxis(
                                          axisLine:
                                              AxisLine(color: Colors.grey),
                                          majorTickLines: MajorTickLines(
                                              color: Colors.grey),
                                          labelRotation: 0,
                                                           interval: periods[currentIndex] == 'Month' ? 0.22 : 1,
                                          minimum: 0,
                                          majorGridLines:
                                              MajorGridLines(width: 0),
                                          labelStyle: TextStyle(
                                            fontSize: 8,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                          ),
                                        ),
                                        primaryYAxis: NumericAxis(
                                          axisLine:
                                              AxisLine(color: Colors.grey),
                                          majorTickLines: MajorTickLines(
                                              color: Colors.grey),
                                          interval: 1,
                                          majorGridLines:
                                              MajorGridLines(width: 0),
                                          labelStyle: TextStyle(
                                            fontSize: 8,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                          ),
                                        ),
                                        series: <CartesianSeries>[
                                          ColumnSeries<ChartDataInfo, String>(
                                            width: 0.3,
                                            spacing: 0,
                                            dataSource: chartData,
                                            pointColorMapper:
                                                (ChartDataInfo data, _) =>
                                                    data.color,
                                            xValueMapper:
                                                (ChartDataInfo data, _) =>
                                                    data.time,
                                            yValueMapper:
                                                (ChartDataInfo data, _) =>
                                                    data.value,
                                            enableTooltip: true,
                                            dataLabelSettings:
                                                DataLabelSettings(
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
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "--",
                                          style: TextStyle(
                                            fontSize: height * 0.02,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                          ),
                                        ),
                                        Text(
                                          "--",
                                          style: TextStyle(
                                            fontSize: height * 0.01,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          tempWeight != null
                                              ? tempWeight!.toString()
                                              : '0.0',
                                          style: TextStyle(
                                            fontSize: height * 0.035,
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 8),
                                          child: RichText(
                                            text: TextSpan(
                                                text: " kg",
                                                style: TextStyle(
                                                    fontSize: height * 0.025,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondaryContainer,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "--",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                          ),
                                        ),
                                        Text(
                                          "---",
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),
                                LinearPercentIndicator(
                                  animation: true,
                                  lineHeight: height * 0.003,
                                  animationDuration: 2000,
                                  percent: 0.5,
                                  barRadius: const Radius.circular(16),
                                  progressColor: AppColor.weightChartColor,
                                  backgroundColor: Colors.grey[300],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'History',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                fontSize: height * 0.015,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Container(
                        height: height * 0.15,
                        child: FutureBuilder<List<WeightPostData>>(
                            future: _weightHistory,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return ShimmereffectGraph();
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('No History found',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer)));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                    child: Text('No History found',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer)));
                              } else {
                                final items = snapshot.data!;

                                return ListView.separated(
                                  reverse: items.length > 2 ? true : false,
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final item = items[index];

                                    //  tempWeight = double.parse(item.weight!);

                                    return Dismissible(
                                      key: ValueKey(item.id),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) async {
                                        try {
                                          await deleteWeight(item.id!);
                                          final remove = items.removeAt(index);
                                          await _fetchChartData(
                                              periods[currentIndex]);
                                          _weightHistory = fetchWeightHistory();
                                        } catch (error) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Center(
                                                child: Text(
                                                  "Failed to remove ${item.weight}",
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      background: Container(
                                        color: Colors.red,
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Icon(Icons.delete,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                      child: Container(
                                        width: width,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.trending_down,
                                            color: AppColor.weightChartColor,
                                            size: 20,
                                          ),
                                          title: Text(
                                            item.weight == null
                                                ? '${tempWeight} kg'
                                                : '${item.weight} kg',
                                            style: TextStyle(
                                                fontSize: height * 0.015,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onInverseSurface),
                                          ),
                                          trailing: Text(
                                            "${DateFormat("dd-MMM").format(item.createdAt!)}",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onInverseSurface),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return SizedBox(
                                      height: height * 0.01,
                                    );
                                  },
                                );
                              }
                            })),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Weight",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                fontSize: height * 0.015,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                  ],
                ),
              ),
              Container(
                height: height * 0.22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Stack(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {});
                            },
                            icon: Icon(Icons.cancel_sharp),
                            color: Colors.grey,
                          ),
                          IconButton(
                            onPressed: () async {
                              setState(() {
                                finalWeight = tempWeight!;
                              });
                              addWeight(tempWeight.toString(), context);
                              _weightHistory = fetchWeightHistory();
                              getLastWeight();
                            },
                            icon: Icon(Icons.check_circle),
                            color: AppColor.weightChartColor,
                          )
                        ]),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: DivisionSlider(
                        from: 0,
                        max: 100,
                        initialValue: tempWeight != null ? tempWeight! : 0.0,
                        type: weightType,
                        onChanged: (value) =>
                            setState(() => tempWeight = value),
                        title: "Weight",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
