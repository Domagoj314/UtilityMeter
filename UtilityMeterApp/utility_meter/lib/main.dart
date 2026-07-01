import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF0B1957),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0B1957),
          titleTextStyle: TextStyle(
            color: Color(0xFFF8F3EA),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(
            color: Color(0xFFF8F3EA),
        ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFA9EBC),
            foregroundColor: Color(0xFF0B1957),
          ),
        ),
        listTileTheme: ListTileThemeData(
          titleTextStyle: TextStyle(color: Color(0xFFF8F3EA), fontSize: 16),
          subtitleTextStyle: TextStyle(color: Color(0xFFFFDBD1)),
        ),
        iconTheme: IconThemeData(
          color: Color(0xFFF8F3EA),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFF8F3EA)),
          bodySmall: TextStyle(color: Color(0xFFFFDBD1)),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

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

  Future<void> fetchLastReadingForStruja() async{
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

    Future<void> fetchLastReadingForVoda() async{
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

    Future<void> fetchLastReadingForPlin() async{
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Utility Meter - currently measuring: ${gottenType ?? 'loading...'}',
        ),
      ),
      body: Column(
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
                  });
                },
                child: Container(
                  width: 100,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A2E7A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.bolt, color: Color(0xFFFA9EBC)),
                      Text('Struja', style: TextStyle(color: Color(0xFFF8F3EA), fontSize: 12)),
                      Text('${lastStruja ?? '-'}', style: TextStyle(color: Color(0xFFFA9EBC), fontSize: 18, fontWeight: FontWeight.w500)),
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
                  });
                },
                child: Container(
                  width: 100,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A2E7A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.water, color: Color(0xFFFA9EBC)),
                      Text('Voda', style: TextStyle(color: Color(0xFFF8F3EA), fontSize: 12)),
                      Text('${lastVoda ?? '-'}', style: TextStyle(color: Color(0xFFFA9EBC), fontSize: 18, fontWeight: FontWeight.w500)),
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
                  });
                },
                child: Container(
                  width: 100,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A2E7A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.air, color: Color(0xFFFA9EBC)),
                      Text('Plin', style: TextStyle(color: Color(0xFFF8F3EA), fontSize: 12)),
                      Text('${lastPlin ?? '-'}', style: TextStyle(color: Color(0xFFFA9EBC), fontSize: 18, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: measurements.length,
              itemBuilder: (context, index) {
                final measurement = measurements[index];
                return ListTile(
                  title: Text(measurement['reading'].toString()),
                  subtitle: Text(measurement['datetime'].toString()),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              fetchData();
              fetchLastReadingForPlin();
              fetchLastReadingForStruja();
              fetchLastReadingForVoda();
              getType();
          }, 
          child: Text('Refresh')),
        ],
      ),
    );
  }
}

class MjerenjePage extends StatefulWidget {
  final String type;

  MjerenjePage({required this.type});

  @override
  State<MjerenjePage> createState() => MjerenjePageState();
}

class MjerenjePageState extends State<MjerenjePage> {
  List<dynamic> measurements = [];

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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.type.toUpperCase()} MEASUREMENTS')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child:Column(
          children: [
          Expanded(
            child: ListView.builder(
              itemCount: measurements.length,
              itemBuilder: (context, index) {
                final measurement = measurements[index];
                return ListTile(
                  title: Text(measurement['reading'].toString()),
                  subtitle: Text(measurement['datetime'].toString()),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setType(widget.type);
            },
            child: Text('Postavi tip mjerenja na ${widget.type}'),
          ),
        ],
      ),
      ),
    );
  }
}
