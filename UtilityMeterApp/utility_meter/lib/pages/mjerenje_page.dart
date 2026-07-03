import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';


class MjerenjePage extends StatefulWidget {
  final String type;

  MjerenjePage({required this.type});

  @override
  State<MjerenjePage> createState() => MjerenjePageState();
}

class MjerenjePageState extends State<MjerenjePage> {
  List<dynamic> measurements = [];
  double? monthlyConsumption;
  double? lastReading;
  List<dynamic> monthlyMeasurements = [];

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('https://utilitymeter.uk/measurements?type=${widget.type}'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    if (response.statusCode == 200) {
      setState(() {
        measurements = jsonDecode(response.body);
      });
    }
  }

  Future<void> setType(String type) async {
    final response = await http.post(
      Uri.parse('https://utilitymeter.uk/set-type'),
      headers: {'X-API-Key': 'zavrsnirad', 'Content-Type': 'application/json'},
      body: jsonEncode({'type': type}),
    );
  }

  Future<void> calculateMonthlyConsumptionForType(String type) async {
    final response = await http.get(
      Uri.parse('https://utilitymeter.uk/measurements?type=${type}'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    if (response.statusCode == 200) {
      setState(() {
        measurements = jsonDecode(response.body);
              monthlyMeasurements = measurements.where((measurement) {
      DateTime measurementDate = DateTime.parse(measurement['datetime']);
      return measurementDate.month == DateTime.now().month &&
          measurementDate.year == DateTime.now().year;
    }).toList();
      });
    }

    if (monthlyMeasurements.isEmpty) return;
    if(monthlyMeasurements.length < 2) {
      setState(() {
        monthlyConsumption = null;
      });
      return;
    }
    setState(() {
      monthlyConsumption =
          monthlyMeasurements.first['reading'] -
          monthlyMeasurements.last['reading'];
    });
  }

    Future<void> fetchLastReading(String type) async {
    final response = await http.get(
      Uri.parse('https://utilitymeter.uk/measurements?type=$type&limit=1'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    if (response.statusCode == 200) {
      setState(() {
        final data = jsonDecode(response.body);
        lastReading = data[0]['reading'].toDouble();
      });
    }
  }


  @override
  void initState() {
    super.initState();
    fetchData();
    calculateMonthlyConsumptionForType(widget.type);
    fetchLastReading(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.type.toUpperCase()} MEASUREMENTS')),
      body: SingleChildScrollView(
        child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
                      width: 300,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFFA9EBC), width: 1),
                        color: Color(0xFF1A2E7A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.air, color: Color(0xFFFA9EBC)),
                          Text(
                            widget.type,
                            style: TextStyle(
                              color: Color(0xFFF8F3EA),
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Last reading: ${lastReading != null ? lastReading!.toStringAsFixed(2) : '-'}',
                            style: TextStyle(
                              color: Color(0xFFFA9EBC),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                           Text(
                            'Monthly consumption:${monthlyConsumption != null ? monthlyConsumption!.toStringAsFixed(2) : 'Not enough data'}',
                            style: TextStyle(
                              color: Color(0xFFFA9EBC),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                                                              SizedBox(height: 30), 
              Text(
                'Zadnjih 30 dana potrošnje za: ${widget.type}',
                style: TextStyle(
                  color: Color(0xFFF8F3EA),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 30),            
SizedBox(
  width: double.infinity,
  child: Text('Reading', textAlign: TextAlign.left),
),
            SizedBox(height: 20),
                     SizedBox(
                height: 200,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: monthlyMeasurements.isEmpty
                      ? Center(child: Text('Nema podataka za zadnjih 7 dana'))
                      : LineChart(
                          LineChartData(
                            clipData: FlClipData.all(),
                            minY:
                                monthlyMeasurements
                                    .map((m) => m['reading'].toDouble())
                                    .reduce((a, b) => a < b ? a : b) -
                                2,
                            maxY:
                                monthlyMeasurements
                                    .map((m) => m['reading'].toDouble())
                                    .reduce((a, b) => a > b ? a : b) +
                                2,
                            lineBarsData: [
                              LineChartBarData(
                                spots: monthlyMeasurements.reversed.map((m) {
                                  return FlSpot(
                                    DateTime.parse(
                                      m['datetime'],
                                    ).millisecondsSinceEpoch.toDouble(),
                                    m['reading'].toDouble(),
                                  );
                                }).toList(),
                                color: Color(0xFFFA9EBC),
                                isCurved: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, bar, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: Color(0xFFFA9EBC),
                                      strokeColor: Color(0xFFF8F3EA),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                              ),
                            ],
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 45,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: Color(0xFFFFDBD1),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
                                  getTitlesWidget: (value, meta) {
                                    final date =
                                        DateTime.fromMillisecondsSinceEpoch(
                                          value.toInt(),
                                        );
                                    return Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${date.day}.${date.month}\n${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Color(0xFFFFDBD1),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  },
                                  interval: monthlyMeasurements.length > 1
                                      ? (DateTime.parse(
                                                          monthlyMeasurements
                                                              .first['datetime'],
                                                        ).millisecondsSinceEpoch
                                                        .toDouble() -
                                                    DateTime.parse(
                                                          monthlyMeasurements
                                                              .last['datetime'],
                                                        ).millisecondsSinceEpoch
                                                        .toDouble())
                                                .abs() /
                                            (monthlyMeasurements.length - 1)
                                      : null,
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 30),            
SizedBox(
  width: double.infinity,
  child: Text('Date', textAlign: TextAlign.right),
),
            SizedBox(height: 60),
           SizedBox(
  height: 300,
  child: ListView.builder(
    itemCount: measurements.length,
    itemBuilder: (context, index) {
      final measurement = measurements[index];
      return Card(
        color: Color(0xFF1A2E7A),
        margin: EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                measurement['reading'].toString(),
                style: TextStyle(color: Color(0xFFFA9EBC), fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                measurement['datetime'].toString(),
                style: TextStyle(color: Color(0xFFFFDBD1), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    },
  ),
),
              SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setType(widget.type);
              },
              child: Text('Postavi tip mjerenja na ${widget.type}'),
            ),
          ],
        ),
      ),
    ),
    );
  }
}