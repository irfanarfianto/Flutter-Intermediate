import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:story/constants/button.dart';

class MapPage extends StatefulWidget {
  final Function(double, double) onLocationSelected;
  final Function() onBack;

  const MapPage(
      {super.key, required this.onLocationSelected, required this.onBack});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Set<Marker> _markers = {};
  double? _lat;
  double? _lon;
  bool _isLocationSelected = false;

  void _onMapCreated(GoogleMapController controller) {}

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: latLng,
        ),
      );
      _lat = latLng.latitude;
      _lon = latLng.longitude;
      _isLocationSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(-6.2088, 106.8456),
              zoom: 18.0,
            ),
            onTap: _onMapTapped,
            markers: _markers,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Visibility(
              visible: _isLocationSelected,
              child: Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: primaryButtonStyle,
                  onPressed: () {
                    if (_lat != null && _lon != null) {
                      widget.onLocationSelected(_lat!, _lon!);
                      widget.onBack();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a location on the map.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Confirm Location'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
