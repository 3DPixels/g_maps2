import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = new Location();
  LatLng? _currentP = null;
  final _kGooglePlex = const LatLng(37.42796133580664, -122.085749655962);
  final _kApplePark = const LatLng(37.3346, -122.0090);

  Future<void> getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    //check if service is enabled on phone, like if location is turned off or not available
    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      print('service not enabled');
      return;
    }

    //check for permission to use gps
    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print('Permission was not granted');
        return;
      }
    }

    //listen to any change in user location
    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          print(_currentP);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null
          ? Center(
              child: Text('Loading...'),
            )
          : GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _kGooglePlex, zoom: 15),
              markers: {
                Marker(
                    markerId: MarkerId('_currentLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _currentP!),
                Marker(
                    markerId: MarkerId('_sourceLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _kGooglePlex),
                Marker(
                    markerId: MarkerId('_destinationLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _kApplePark),
              },
            ),
    );
  }
}
