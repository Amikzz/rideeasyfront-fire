// ignore_for_file: prefer_interpolation_to_compose_strings, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ride_easy/common/customappbar.dart';
import 'package:ride_easy/features/HomePage/home.dart';

class BusSchedulePage extends StatefulWidget {
  const BusSchedulePage({super.key});

  @override
  _BusSchedulePageState createState() => _BusSchedulePageState();
}

class _BusSchedulePageState extends State<BusSchedulePage> {
  List<String> towns = ['ANY'];
  List<Map<String, dynamic>> data = [];
  String src = 'ANY', des = 'ANY';

  void setSrc(String? t) {
    setState(() {
      src = t ?? towns[0];
    });
  }

  void setDes(String? t) {
    setState(() {
      des = t ?? towns[0];
    });
  }

  void fetchTowns() async {
    Response response = await get(Uri.parse('http://10.0.2.2:3000/towns'));
    List result = jsonDecode(response.body) as List;
    setState(() {
      towns.clear();
      towns.add('ANY');
      for (Map<String, dynamic> item in result) {
        String? townName = item['name'];
        if (townName != null) towns.add(townName);
      }
    });
  }

  void search() async {
    String url = 'http://10.0.2.2:3000/info/$src/$des/ANY';
    Response response = await get(Uri.parse(url));
    setState(() {
      data.clear();
      List items = jsonDecode(response.body) as List;
      for (Map<String, dynamic> item in items) {
        data.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchTowns();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: ClipPath(
          clipper: CustomAppBar(),
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        ); // Navigate back
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
                const SizedBox(width: 50), // Adjust spacing as needed
              ],
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SOURCE'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton(
                      value: src,
                      items: towns.map((element) {
                        return DropdownMenuItem(
                            value: element, child: Text(element));
                      }).toList(),
                      onChanged: setSrc,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DESTINATION'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton(
                      value: des,
                      items: towns.map((element) {
                        return DropdownMenuItem(
                            value: element, child: Text(element));
                      }).toList(),
                      onChanged: setDes,
                    ),
                  ),
                ],
              ),
            ],
          ),
          TextButton.icon(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: search,
            label: const Text(
              'Search',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) => BusCard(data: data[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class BusCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const BusCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[700],
          borderRadius: BorderRadius.circular(12),
        ),
        width: double.infinity,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SOURCE',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    Text(
                      data['src_name']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      data['src_town']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Text(
                  '→',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'DESTINATION',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    Text(
                      data['des_name']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      data['des_town']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Icon(
                  Icons.directions,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    '${data['distance']} KM, via ' + data['inter_towns']!,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const Icon(
                  Icons.directions_bus,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  data['brand']! +
                      ', ' +
                      data['chair_count'].toString() +
                      ' seater, ' +
                      ['Non-AC', 'AC'][data['ac']!],
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  data['start_time'].toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(
                  width: 16,
                ),
                const Icon(
                  Icons.timelapse_rounded,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  data['duration'].toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
