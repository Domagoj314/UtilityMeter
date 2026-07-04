import 'mjerenje_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'postavke_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  
  List<dynamic> measurements = [];
  String? gottenType;
  double? lastStruja;
  double? lastVoda;
  double? lastPlin;
  List<dynamic> last7daysMeasurements = [];
  double? monthlyConsumption;

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('https://utilitymeter.uk/measurements'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    if (response.statusCode == 200) {
      setState(() {
        measurements = jsonDecode(response.body);
      });
    }
  }

  Future<void> fetchLastReadingForStruja() async {
    final response = await http.get(
      Uri.parse('https://utilitymeter.uk/measurements?type=struja&limit=1'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    if (response.statusCode == 200) {
      setState(() {
        final data = jsonDecode(response.body);
        lastStruja = data[0]['reading'].toDouble();
      });
    }
  }

  Future<void> fetchLastReadingForVoda() async {
    final response = await http.get(
      Uri.parse('https://utilitymeter.uk/measurements?type=voda&limit=1'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    if (response.statusCode == 200) {
      setState(() {
        final data = jsonDecode(response.body);
        lastVoda = data[0]['reading'].toDouble();
      });
    }
  }

  Future<void> fetchLastReadingForPlin() async {
    final response = await http.get(
      Uri.parse('https://utilitymeter.uk/measurements?type=plin&limit=1'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    if (response.statusCode == 200) {
      setState(() {
        final data = jsonDecode(response.body);
        lastPlin = data[0]['reading'].toDouble();
      });
    }
  }

  Future<void> getLast7DaysForType() async {
    await getType();
    final response = await http.get(
      Uri.parse('https://utilitymeter.uk/measurements?type=$gottenType'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    if (response.statusCode == 200) {
      setState(() {
        final data = jsonDecode(response.body);
        DateTime today = DateTime.now();
        DateTime sevenback = DateTime.now().subtract(Duration(days: 7));
        if (data is List) {
          last7daysMeasurements = data.where((measurement) {
            DateTime measurementDate = DateTime.parse(measurement['datetime']);
            return measurementDate.isAfter(sevenback) &&
                measurementDate.isBefore(today);
          }).toList();
        }
      });
    }
  }

  Future<void> getType() async {
    final response = await http.get(
      Uri.parse('https://utilitymeter.uk/get-type'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    if (response.statusCode == 200) {
      final gottenType = jsonDecode(response.body)['type'];
      setState(() {
        this.gottenType = gottenType;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    getType();
    fetchLastReadingForStruja();
    fetchLastReadingForPlin();
    fetchLastReadingForVoda();
    getLast7DaysForType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text('Utility Meter'),
            Text(
              'Mjeri: ${gottenType ?? 'loading...'}',
              style: TextStyle(fontSize: 14, color: Color(0xFFFFDBD1)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Color(0xFFFA9EBC)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostavkePage()),
              ).then((value) {
                getType();
                fetchData();
                fetchLastReadingForStruja();
                fetchLastReadingForVoda();
                fetchLastReadingForPlin();
                getLast7DaysForType();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MjerenjePage(type: 'struja'),
                        ),
                      ).then((value) {
                        getType();
                        fetchData();
                        fetchLastReadingForStruja();
                        fetchLastReadingForVoda();
                        fetchLastReadingForPlin();
                        getLast7DaysForType();
                      });
                    },
                    child: Container(
                      width: 100,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFFA9EBC), width: 1),
                        color: Color(0xFF1A2E7A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.bolt, color: Color(0xFFFA9EBC)),
                          Text(
                            'Struja',
                            style: TextStyle(
                              color: Color(0xFFF8F3EA),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${lastStruja ?? '-'}kWh',
                            style: TextStyle(
                              color: Color(0xFFFA9EBC),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MjerenjePage(type: 'voda'),
                        ),
                      ).then((value) {
                        getType();
                        fetchData();
                        fetchLastReadingForStruja();
                        fetchLastReadingForVoda();
                        fetchLastReadingForPlin();
                        getLast7DaysForType();
                      });
                    },
                    child: Container(
                      width: 100,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFFA9EBC), width: 1),
                        color: Color(0xFF1A2E7A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.water, color: Color(0xFFFA9EBC)),
                          Text(
                            'Voda',
                            style: TextStyle(
                              color: Color(0xFFF8F3EA),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${lastVoda ?? '-'}m³',
                            style: TextStyle(
                              color: Color(0xFFFA9EBC),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MjerenjePage(type: 'plin'),
                        ),
                      ).then((value) {
                        getType();
                        fetchData();
                        fetchLastReadingForStruja();
                        fetchLastReadingForVoda();
                        fetchLastReadingForPlin();
                        getLast7DaysForType();
                      });
                    },
                    child: Container(
                      width: 100,
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
                            'Plin',
                            style: TextStyle(
                              color: Color(0xFFF8F3EA),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${lastPlin ?? '-'}m³',
                            style: TextStyle(
                              color: Color(0xFFFA9EBC),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                'Zadnjih 7 dana potrošnje za: ${gottenType}',
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
                  child: last7daysMeasurements.isEmpty
                      ? Center(child: Text('Nema podataka za zadnjih 7 dana'))
                      : LineChart(
                          LineChartData(
                            clipData: FlClipData.all(),
                            minY:
                                last7daysMeasurements
                                    .map((m) => m['reading'].toDouble())
                                    .reduce((a, b) => a < b ? a : b) -
                                2,
                            maxY:
                                last7daysMeasurements
                                    .map((m) => m['reading'].toDouble())
                                    .reduce((a, b) => a > b ? a : b) +
                                2,
                            lineBarsData: [
                              LineChartBarData(
                                spots: last7daysMeasurements.reversed.map((m) {
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
                                  interval: last7daysMeasurements.length > 1
                                      ? (DateTime.parse(
                                                          last7daysMeasurements
                                                              .first['datetime'],
                                                        ).millisecondsSinceEpoch
                                                        .toDouble() -
                                                    DateTime.parse(
                                                          last7daysMeasurements
                                                              .last['datetime'],
                                                        ).millisecondsSinceEpoch
                                                        .toDouble())
                                                .abs() /
                                            (last7daysMeasurements.length - 1)
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
              SizedBox(height: 24),
              Text(
                'Zadnja očitanja:',
                style: TextStyle(
                  color: Color(0xFFF8F3EA),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
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
                              style: TextStyle(
                                color: Color(0xFFFA9EBC),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  measurement['type'].toString(),
                                  style: TextStyle(
                                    color: Color(0xFFF8F3EA),
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  measurement['datetime'].toString(),
                                  style: TextStyle(
                                    color: Color(0xFFFFDBD1),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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
                  fetchData();
                  fetchLastReadingForPlin();
                  fetchLastReadingForStruja();
                  fetchLastReadingForVoda();
                  getType();
                  getLast7DaysForType();
                },
                child: Text('Refresh'),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
