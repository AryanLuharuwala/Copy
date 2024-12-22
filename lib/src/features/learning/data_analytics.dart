import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(DataAnalyticsApp());
}

class DataAnalyticsApp extends StatelessWidget {
  const DataAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DataAnalyticsPage(),
    );
  }
}

class DataAnalyticsPage extends StatefulWidget {
  const DataAnalyticsPage({super.key});

  @override
  _DataAnalyticsPageState createState() => _DataAnalyticsPageState();
}

class _DataAnalyticsPageState extends State<DataAnalyticsPage> {
  double price = 69.0;
  double quantitySold = 100.0;
  double inventory = 100.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text('Data Analytics'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // First Chart
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Parle G (Month Vs Sales)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            _buildBarGroup(0, price),
                            _buildBarGroup(1, 19),
                            _buildBarGroup(2, 3),
                            _buildBarGroup(3, 5),
                            _buildBarGroup(4, 2),
                            _buildBarGroup(5, 3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Second Chart
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Parle G (Month Vs Sales)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            _buildBarGroup(0, 15),
                            _buildBarGroup(1, inventory),
                            _buildBarGroup(2, 16),
                            _buildBarGroup(3, price),
                            _buildBarGroup(4, 3),
                            _buildBarGroup(5, inventory + price),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sliders
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildSlider('Price', price, 0, 200, (value) {
                    setState(() {
                      price = value;
                    });
                  }),
                  _buildSlider('Quantity Sold', quantitySold, 0, 200, (value) {
                    setState(() {
                      quantitySold = value;
                    });
                  }),
                  _buildSlider('Inventory', inventory, 0, 200, (value) {
                    setState(() {
                      inventory = value;
                    });
                  }),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Start'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build slider
  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toInt()}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Helper method to create bar group for charts
  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue,
          width: 15,
        ),
      ],
    );
  }
}
