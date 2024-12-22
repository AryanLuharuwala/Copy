import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart'; // For accessing the ProductProvider
import 'package:myapp/utils/product_provider.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    // Access latitude and longitude from ProductProvider
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    double latitude = productProvider.latitude;
    latitude = 23;
    double longitude = productProvider.longitude;
    longitude = 82;
    return SingleChildScrollView(
      child: Column(
        children: [
          // Advertisement Section
          Container(
            height: MediaQuery.of(context).size.height / 2,
            color: Colors.grey[300],
            child: const Center(
              child: Text(
                'Coming Soon to Your Location!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Scrolling Advertisements
          SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://via.placeholder.com/800x400?text=Ad+${index + 1}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Map Section
          SizedBox(
            height: 300,
            child: _buildMap(latitude, longitude),
          ),
        ],
      ),
    );
  }

  // Reusable Map Function
  Widget _buildMap(double latitude, double longitude) {
    final MapController mapController = MapController();

    // Center the map on the given location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(
          LatLng(latitude, longitude), 13.0); // Adjust zoom level as needed
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(75.0), // Rounded corners for map view
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(latitude, longitude),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(latitude, longitude),
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
