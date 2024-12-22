import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/utils/global_variables.dart';

class SellerHomePage extends StatefulWidget {
  final Map<String, dynamic> sellerId;

  const SellerHomePage({super.key, required this.sellerId});

  @override
  _SellerHomePageState createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  List<dynamic> recommendedProducts = [
    {"name": "Product 1", "image": "assets/images/cereal.jpg"},
    {"name": "Product 2", "image": "assets/images/snack.jpg"}
  ];
  List<dynamic> topSearchedItems = [];
  List<double> sellerRevenue = [23, 2, 3, 32, 23, 2, 3, 2, 3, 2];
  List<double> marketAverageRevenue = [12, 21, 3, 1, 23, 12, 3, 12];
  double totalRevenue = 0;
  int totalProductsSold = 0;
  double profit = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSellerData();
    print(widget.sellerId);
  }

  Future<void> fetchSellerData() async {
    //await fetchRecommendedProducts();
    await fetchRevenueData();
    //await fetchTopSearchedItems();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRecommendedProducts() async {
    final String url =
        'https://your-api-url.com/api/seller/${widget.sellerId}/recommended';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          recommendedProducts = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load recommended products');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchRevenueData() async {
    final String url = '$uri/api/seller/${widget.sellerId['_id']}/metrics';
    try {
      final response = await http.get(Uri.parse(url));
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

        setState(() {
          totalRevenue = (data['totalRevenue'] as num).toDouble();
          totalProductsSold =
              data['totalSales'] ?? 0; // Assuming this is an integer
          profit = (data['profit'] as num).toDouble();
        });
      } else {
        throw Exception('Failed to load revenue data');
      }
    } catch (e) {
      print("Error fetching revenue data: $e");
    }
  }

// No need to calculate sales summary separately if fetched from backend

  Future<void> fetchTopSearchedItems() async {
    final String url =
        'https://your-api-url.com/api/seller/${widget.sellerId}/top-searched';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          topSearchedItems = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load top searched items');
      }
    } catch (e) {
      print(e);
    }
  }

  double get averageSaleValue =>
      totalProductsSold == 0 ? 0 : totalRevenue / totalProductsSold;

  @override
  Widget build(BuildContext context) {
    // Get container color based on theme
    final containerColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Searches',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: topSearchedItems.length,
                      itemBuilder: (context, index) {
                        final item = topSearchedItems[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          width: 100,
                          color: containerColor,
                          child: Center(
                            child: Text(
                              item['name'],
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Summary',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Total Revenue: \$${totalRevenue.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Total Products Sold: $totalProductsSold',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Profit: \$${profit.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Average Sale Value: \$${averageSaleValue.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Recommended',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendedProducts.length,
                      itemBuilder: (context, index) {
                        final product = recommendedProducts[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          width: 120,
                          color: containerColor,
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.asset(
                                  product['image'],
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  product['name'],
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Market Avg',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        minY: _calculateMinY() - 5,
                        maxY: _calculateMaxY() + 5,
                        gridData: FlGridData(
                          show: true,
                          verticalInterval: _calculateVerticalInterval(),
                          drawHorizontalLine: true,
                          drawVerticalLine: true,
                          getDrawingVerticalLine: (value) => FlLine(
                            color: Colors.grey[700]!,
                            strokeWidth: 1,
                          ),
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey[700]!,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.white),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: sellerRevenue
                                .asMap()
                                .entries
                                .map((entry) =>
                                    FlSpot(entry.key.toDouble(), entry.value))
                                .toList(),
                            isCurved: true,
                            color: Colors.yellow,
                            barWidth: 3,
                          ),
                          LineChartBarData(
                            spots: marketAverageRevenue
                                .asMap()
                                .entries
                                .map((entry) =>
                                    FlSpot(entry.key.toDouble(), entry.value))
                                .toList(),
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  double _calculateMinY() {
    // Calculates the minimum value between sellerRevenue and marketAverageRevenue
    return min(sellerRevenue.reduce(min), marketAverageRevenue.reduce(min));
  }

  double _calculateMaxY() {
    // Calculates the maximum value between sellerRevenue and marketAverageRevenue
    return max(sellerRevenue.reduce(max), marketAverageRevenue.reduce(max));
  }

  double _calculateVerticalInterval() {
    double maxValue = _calculateMaxY();
    double minValue = _calculateMinY();
    double range = maxValue - minValue;
    return range / 5; // Divides range into 5 intervals for better grid spacing
  }
}
