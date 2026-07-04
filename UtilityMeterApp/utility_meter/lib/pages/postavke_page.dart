import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostavkePage extends StatefulWidget {
  @override
  State<PostavkePage> createState() => PostavkePageState();
}

class PostavkePageState extends State<PostavkePage> {
  double interval = 30;
  bool novaSlika = true;
  bool neobicnaPotrosnja = true;
  bool uredajOffline = true;


  Future<void> spremiInterval(double interval) async {
    final response = await http.post(
      Uri.parse('https://utilitymeter.uk/set-interval'),
      headers: {'X-API-Key': 'zavrsnirad', 'Content-Type': 'application/json'},
      body: jsonEncode({'interval': interval}),
    );
  }

  Future<void> getInterval() async{

    final response = await http.get(
      Uri.parse('https://utilitymeter.uk/get-interval'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        interval = data['interval'].toDouble();
      });
    }
  }


  @override
  void initState() {
    super.initState();
    getInterval();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Postavke')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 30),
            Row(
              children: [
                Text(
                  'Konfiguracija uređaja:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Text('Interval slikanja:', style: TextStyle(fontSize: 16)),
                Slider(
                  value: interval,
                  min: 5,
                  max: 180,
                  divisions: 35,
                  label: interval.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      interval = value;
                    });
                  },
                ),
                Text('${interval.round()} min'),
              ],
            ),
            SizedBox(height: 50),
            Row(
              children: [
                Text(
                  'Obavijesti:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Text('Nova slika:   ', style: TextStyle(fontSize: 16)),
                Switch(
                  value: novaSlika,
                  onChanged: (bool value) {
                    setState(() {
                      novaSlika = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text('Neobična potrošnja:   ', style: TextStyle(fontSize: 16)),
                Switch(
                  value: neobicnaPotrosnja,
                  onChanged: (bool value) {
                    setState(() {
                      neobicnaPotrosnja = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text('Uređaj offline:   ', style: TextStyle(fontSize: 16)),
                Switch(
                  value: uredajOffline,
                  onChanged: (bool value) {
                    setState(() {
                      uredajOffline = value;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(onPressed: ()
            {
              spremiInterval(interval);
            }, 
            child: Text('Spremi postavke')),
          ],
        ),
      ),
    );
  }
}
