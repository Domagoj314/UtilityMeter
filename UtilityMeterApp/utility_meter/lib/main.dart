import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void fetchData() async {
  try {
    final response = await http.get(
      Uri.parse('https://utilitymeter.uk/measurements'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}

void main() {
  fetchData();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Text('Utility Meter'),
        ),
        body: Container(
          child: const Text('Očitavanje potrošnje'), 
        ),
      )
    );
  }
}
