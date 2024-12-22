// cart_map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CartMapPage extends StatefulWidget {
  final List<Map<String, dynamic>> shopLocations;

  const CartMapPage({super.key, required this.shopLocations});

  @override
  _CartMapPageState createState() => _CartMapPageState();
}

class _CartMapPageState extends State<CartMapPage> {
  late List<LatLng> _shopLatLngs;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _shopLatLngs = widget.shopLocations
        .map((location) => LatLng(location['latitude'], location['longitude']))
        .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitToBounds();
    });
  }

  void _fitToBounds() {
    if (_shopLatLngs.isEmpty) return;

    // Calculate the bounds to fit all the markers in view
    double minLat = _shopLatLngs
        .map((latLng) => latLng.latitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLat = _shopLatLngs
        .map((latLng) => latLng.latitude)
        .reduce((a, b) => a > b ? a : b);
    double minLng = _shopLatLngs
        .map((latLng) => latLng.longitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLng = _shopLatLngs
        .map((latLng) => latLng.longitude)
        .reduce((a, b) => a > b ? a : b);

    LatLngBounds bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    // Calculate center of the bounds
    LatLng center = bounds.center;

    // Set the map to the new center and adjust zoom level accordingly
    _mapController.move(center, _calculateZoomLevel(bounds));
  }

  double _calculateZoomLevel(LatLngBounds bounds) {
    // Here we are defining a base zoom level.
    // You can add your logic to calculate a more appropriate zoom level
    // depending on the bounds size and map's display area.
    return 11.0; // Adjust this value as needed for better fitting.
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(75.0), // Rounded corners for map view
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter:
              _shopLatLngs.isNotEmpty ? _shopLatLngs.first : const LatLng(0, 0),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _shopLatLngs.map((latLng) {
              return Marker(
                width: 80.0,
                height: 80.0,
                point: latLng,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40.0,
                ),
              );
            }).toList(),
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: _shopLatLngs,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// MarkerLayer(
//             markers: _shopLatLngs.map((latLng) {
//               return Marker(
//                 width: 80.0,
//                 height: 80.0,
//                 point: latLng,
//                 child: Icon(
//                   Icons.location_pin,
//                   color: Colors.red,
//                   size: 40.0,
//                 ),
//               );
//             }).toList(),
//           ),
