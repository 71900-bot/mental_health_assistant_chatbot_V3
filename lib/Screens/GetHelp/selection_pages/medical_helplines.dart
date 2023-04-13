import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';


class MedicalHelplinesScreen extends StatefulWidget {
  final String info;
  const MedicalHelplinesScreen({Key? key, required this.info}) : super(key: key);
  @override
  _MedicalHelplinesScreenState createState() => _MedicalHelplinesScreenState();
}

class _MedicalHelplinesScreenState extends State<MedicalHelplinesScreen> {
  List<Helpline> _nearbyHelplines = []; // List of nearby helplines
  MapController _mapController = MapController(); // Controller for the map
  late LatLng _currentLocation = LatLng(0, 0); // Current location of the user

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _timer = Timer.periodic(Duration(minutes: 5), (_) => _getCurrentLocation());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Get the current location of the user
  Future<void> _getCurrentLocation() async {
    // Check if location permission is granted
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      // Request location permission
      status = await Permission.locationWhenInUse.request();
      if (status.isDenied) {
        throw Exception('Location permission denied');
      }
    }

    // Get current location
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    // Get nearby helplines
    _getNearbyHelplines();
  }

  // Get nearby mental health helplines from a backend API
  void _getNearbyHelplines() async {
    // Make API call to get nearby helplines
    final response = await http.get(Uri.parse('http://192.168.43.74/mental_health_assistant_chatbot/Get%20Help/mentalHelplines.json'));
    if (response.statusCode == 200) {
      print(response.body);
      // Parse the response JSON to a list of Helpline objects
      final List<dynamic> data = json.decode(response.body);
      final List<Helpline> helplines = data.map((json) => Helpline.fromJson(json)).toList();

      // Update the list of nearby helplines
      setState(() {
        _nearbyHelplines = helplines;
        print(_nearbyHelplines.length);
      });
    } else {
      throw Exception('Failed to fetch nearby helplines');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Mental Health Assistant Chatbot'),),
        body: Column(
            children: [
        Flexible(
        child: _currentLocation == null
            ? Center(
          child: CircularProgressIndicator(),
        )
            : FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _currentLocation,
            zoom: 14.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate:
              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayerOptions(
              markers: _nearbyHelplines
                  .map((helpline) => Marker(
                point: LatLng(helpline.latitude, helpline.longitude),
                builder: (context) => IconButton(
                  icon: Icon(Icons.location_on),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(helpline.name),
                        content: Text(helpline.phone),
                        actions: [
                          TextButton(
                            child: Text('CALL'),
                            onPressed: () {},
                          ),
                          TextButton(
                            child: Text('CLOSE'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ))
                  .toList(),
            ),
          ],
        )
    ),
    SizedBox(height: 16),
    Text(
      'Nearby Helplines',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: 8),
    Expanded(
      child: ListView.builder(
        itemCount: _nearbyHelplines.length,
        itemBuilder: (context, index) {
          final helpline = _nearbyHelplines[index];
          return ListTile(
            title: Text(helpline.name),
            subtitle: Text(helpline.phone),
            trailing: IconButton(
              icon: Icon(Icons.call),
              onPressed: () {
                // Make a phone call to the helpline phone number
              },
            ),
          );
        },
      ),
    ),
  ],
      ),
    ),
    );
  }
}

class Helpline {
  final String id;
  final String name;
  final String phone;
  final double latitude;
  final double longitude;

  Helpline({required this.id, required this.name, required this.phone, required this.latitude, required this.longitude});

  factory Helpline.fromJson(Map<String, dynamic> json) {
    return Helpline(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}