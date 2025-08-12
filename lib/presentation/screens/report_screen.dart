import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/api/api_config.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/drawer_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:INSUL/core/utils/hive_db_utils.dart';

  final _hivedb = HiveDbHelper();
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int touchedIndex = -1;
  String _selectedText = 'WEEKLY';
  Color? activeColor;
  Color? activeText;
  String totalInsulValue = '';
  String totalGlucoseValue = '';
  String totalBasalValue = '';
  String totalBolusValue = '';
  String patientName = '';
  String patientAge = '';
  String patientGender = '';
  String reportGenerateDate = '';

  @override
  void initState() {
    super.initState();
    getReportDetails(_selectedText);
  }

  Future<void> getReportDetails(String filterName) async {
    final dio = Dio();
    final String? userId = await _hivedb.getString('userId');
    try {
      final response = await dio.get(
        '$getReportData/$userId',
        queryParameters: {'filter': filterName.toLowerCase()},
      );

      if (response.statusCode == 200) {
        print('Get Report Data for $filterName');
        var data = response.data['data'][0];
        print(data);
        setState(() {
          totalBasalValue = data['basalSum'].toString();
          totalBolusValue = data['bolusSum'].toString();
          totalGlucoseValue = data['glucoseSum'].toString();
          totalInsulValue = data['insulinSum'].toString();
          patientName = data['name'];
          patientAge = data['age'];
          patientGender = data['gender'];
           reportGenerateDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(data['createdAt'].toString()));
        });
      } else {
        setState(() {
          totalBasalValue = '-';
          totalBolusValue = '-';
          totalGlucoseValue = '-';
          totalInsulValue  = '-';
          patientName = '-';
          patientAge = '-';
          patientGender  = '-';
           reportGenerateDate = '-';
        });
        throw Exception('Failed to load');
      }
    } catch (e) {
       setState(() {
          totalBasalValue = '-';
          totalBolusValue = '-';
          totalGlucoseValue = '-';
          totalInsulValue  = '-';
          patientName = '-';
          patientAge = '-';
          patientGender  = '-';
           reportGenerateDate = '-';
        });
      print('Error fetching data: $e');
      rethrow;
    }
  }


  Future<void> downloadPDF() async {
    print('button hit for download');
    final pdf = pw.Document();

    final Uint8List assetImage = await rootBundle
        .load('assets/images/INSUL-4.png')
        .then((data) => data.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Image(
                pw.MemoryImage(
                  assetImage,
                ),
                width: 110,
                fit: pw.BoxFit.fitWidth),
                  pw.SizedBox(height: 15),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('$_selectedText REPORT',
                    style: pw.TextStyle(
                      fontSize: 14,
                    )),
                pw.Row(
                  children: [
                    pw.Text('Generated On : ',
                        style: pw.TextStyle(fontSize: 14)),
                    pw.Text(reportGenerateDate, style: pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('DEMOGRAPHIC DETAILS', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Patient Name', style: pw.TextStyle(fontSize: 14)),
                pw.Text(patientName),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Patient Age', style: pw.TextStyle(fontSize: 14)),
                pw.Text(patientAge),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Gender', style: pw.TextStyle(fontSize: 14)),
                pw.Text(patientGender),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('INSULIN REPORT OVERVIEW',
                style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Glucose Level:',
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text(totalGlucoseValue),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Insulin Delivered:',
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text(totalInsulValue),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Bolus Delivered:',
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text(totalBolusValue),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Basal Delivered:',
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text(totalBasalValue),
              ],
            ),
            
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: AppDrawerNavigation('REPORT'),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 1,
        centerTitle: true,
        title: Text(
          "REPORT",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: width / 1.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _selectButton('WEEKLY', height, width),
                          _selectButton('MONTHLY', height, width),
                          _selectButton('YEARLY', height, width),
                        ]),
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    height: height * 0.02,
                  ),
                  HeadingText(height, 'DEMOGRAPHIC DETAILS'),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name :',
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Age :',
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Gender :',
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Generated On :',
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                patientName,
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                patientAge,
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                patientGender,
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                             reportGenerateDate,
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  HeadingText(height, 'INSULIN REPORT OVERVIEW'),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Glucose Level :',
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Total Insulin Delivered :',
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Total Bolus Delivered :',
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Total Basal Delivered :',
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                totalGlucoseValue,
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                totalInsulValue,
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                totalBolusValue,
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                totalBasalValue,
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  fontSize: height * 0.015,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.04,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: downloadPDF,
                      child: Container(
                        height: height * 0.045,
                        width: width * 0.35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: Center(
                            child: Text(
                          'DOWNLOAD',
                          style: TextStyle(
                              color: Colors.white, fontSize: height * 0.016),
                        )),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectButton(String text, double height, double width) {
    Color activeColor;
    Color activeText;

    if (_selectedText == text) {
      activeColor = Colors.green;
      activeText = Theme.of(context).colorScheme.primary;
    } else {
      activeColor = Theme.of(context).colorScheme.onPrimary;
      activeText = Theme.of(context).colorScheme.secondaryContainer;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedText = text;
          getReportDetails(_selectedText);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: activeColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 5),
          child: Text(
            text,
            style: TextStyle(
                color: activeText,
                fontSize: height * 0.015,
                fontWeight: AppColor.lightWeight),
          ),
        ),
      ),
    );
  }
}

class HeadingText extends StatelessWidget {
  HeadingText(this.height, this.text);

  final double height;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: Colors.black54,
          fontSize: height * 0.015,
          fontWeight: AppColor.lightWeight),
    );
  }
}
