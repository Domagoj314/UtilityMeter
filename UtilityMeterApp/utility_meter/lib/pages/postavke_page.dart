import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostavkePage extends StatefulWidget {
  @override
  State<PostavkePage> createState() => PostavkePageState();
}

class PostavkePageState extends State<PostavkePage> {
  int interval = 30;
  bool novaSlika = true;
  bool neobicnaPotrosnja = true;


  Future<void> spremiObavijesti(int interval, bool novaSlika, bool neobicnaPotrosnja) async {
    final response = await http.post(
      Uri.parse('https://utilitymeter.uk/set-interval'),
      headers: {'X-API-Key': 'zavrsnirad', 'Content-Type': 'application/json'},
      body: jsonEncode({'interval': interval.round()}),
    );
        final responsen = await http.post(
      Uri.parse('https://utilitymeter.uk/set-newpic-status'),
      headers: {'X-API-Key': 'zavrsnirad', 'Content-Type': 'application/json'},
      body: jsonEncode({'newpic': novaSlika}),
    );
            final responsew = await http.post(
      Uri.parse('https://utilitymeter.uk/set-reading-status'),
      headers: {'X-API-Key': 'zavrsnirad', 'Content-Type': 'application/json'},
      body: jsonEncode({'weirdReading': neobicnaPotrosnja}),
    );
  }



  Future<void> getObavijesti() async{

    final response = await http.get(
      Uri.parse('https://utilitymeter.uk/get-interval'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    if (response.statusCode == 200) {
      final data = response.body;
      setState(() {
        interval = int.parse(data);
      });
    }

       final responsen = await http.get(
      Uri.parse('https://utilitymeter.uk/get-newpic-status'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    if (responsen.statusCode == 200) {
      final data = jsonDecode(responsen.body);
      setState(() {
        novaSlika = data['newpic'];
      });
    }
          final responsew = await http.get(
      Uri.parse('https://utilitymeter.uk/get-reading-status'),
      headers: {'X-API-Key': 'zavrsnirad'},
    );
    if (responsew.statusCode == 200) {
      final data = jsonDecode(responsew.body);
      setState(() {
        neobicnaPotrosnja = data['weirdReading'];
      });
    }
  }


  @override
  void initState() {
    super.initState();
    getObavijesti();
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
                  value: interval.toDouble(),
                  min: 5,
                  max: 180,
                  divisions: 35,
                  label: interval.toString(),
                  onChanged: (double value) {
                    setState(() {
                      interval = value.round();
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
            ElevatedButton(onPressed: ()
            {
              spremiObavijesti(interval, novaSlika, neobicnaPotrosnja);
            }, 
            child: Text('Spremi postavke')),
          ],
        ),
      ),
    );
  }
}
