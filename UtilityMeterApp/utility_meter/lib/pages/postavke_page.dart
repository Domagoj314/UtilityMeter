import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostavkePage extends StatefulWidget {
  @override
  State<PostavkePage> createState() => PostavkePageState();
}

class PostavkePageState extends State<PostavkePage> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Postavke')),
      body: Center(
        child: Text('Ovdje možete postaviti postavke aplikacije.'),
      ),
    );
  }
}