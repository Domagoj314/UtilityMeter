import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>{
  List<dynamic> measurements = [];

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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Utility Meter'),
      ),
      body: ListView.builder(
        itemCount: measurements.length,
        itemBuilder: (context, index) {
          final measurement = measurements[index];
          return ListTile(
            title: Text("Očitanje broj ${index+1}: ${measurement['reading'].toString()}"),
            subtitle: Text(measurement['datetime'].toString()),
          );
        },
      ),
    );
  }

}
