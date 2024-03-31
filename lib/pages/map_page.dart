import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:g_maps2/consts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  LatLng? _currentP;
  final _kGooglePlex = const LatLng(37.42796133580664, -122.085749655962);
  final _kApplePark = const LatLng(37.3346, -122.0090);

  Map<PolylineId, Polyline> polylines = {};

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(target: pos, zoom: 16);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  Future<void> getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    //check if service is enabled on phone, like if location is turned off or not available
    serviceEnabled = await _locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
    } else {
      print('service not enabled');
      return;
    }

    //check for permission to use gps
    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
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
          _cameraToPosition(_currentP!);
        });
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        kGoogleMapsAPIKey,
        PointLatLng(_kGooglePlex.latitude, _kGooglePlex.longitude),
        PointLatLng(_kApplePark.latitude, _kApplePark.longitude),
        travelMode: TravelMode.driving);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }

  @override
  void initState() {
    super.initState();
    getLocation().then(
      (_) => {
        getPolylinePoints()
            .then((coordinates) => generatePolyLineFromPoints(coordinates))
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null
          ? const Center(
              child: Text('Loading...'),
            )
          : GoogleMap(
              onMapCreated: (controller) => _mapController.complete(controller),
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
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }
}
