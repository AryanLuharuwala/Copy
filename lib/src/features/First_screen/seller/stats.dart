import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatefulWidget {
  final Map<String, dynamic> sellerId;

  const StatisticsPage({super.key, required this.sellerId});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  // Sample data for demonstration
  List<double> weeklyRevenue = [100, 150, 200, 180, 220, 300, 250];
  List<double> monthlyRevenue = [1200, 1400, 1600, 1800, 2000, 2200, 2400];
  List<double> productPerformance = [75, 50, 90, 60, 85];
  List<String> topSellingProducts = ["Product A", "Product B", "Product C"];
  double conversionRate = 5.4; // Conversion rate in %
  int totalOrders = 500;
  double repeatCustomerRate = 30.0; // in %
  double avgOrderValue = 45.0;
  int newCustomers = 120;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatisticsData();
  }

  Future<void> fetchStatisticsData() async {
    // TODO: Fetch data from the API
    // Simulate a delay for fetching data
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRevenueTrendChart(),
                  const SizedBox(height: 20),
                  _buildMonthlySalesChart(),
                  const SizedBox(height: 20),
                  _buildProductPerformanceChart(),
                  const SizedBox(height: 20),
                  _buildTopSellingProductsList(),
                  const SizedBox(height: 20),
                  _buildConversionRate(),
                  const SizedBox(height: 20),
                  _buildRepeatCustomerRate(),
                  const SizedBox(height: 20),
                  _buildAverageOrderValue(),
                  const SizedBox(height: 20),
                  _buildNewCustomers(),
                  const SizedBox(height: 20),
                  _buildSalesSummary(),
                ],
              ),
            ),
    );
  }

  Widget _buildRevenueTrendChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Revenue Trend',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 400,
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black, width: 1),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: weeklyRevenue
                      .asMap()
                      .entries
                      .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                      .toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                      show: true, color: Colors.blue.withOpacity(0.3)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlySalesChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Sales Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 3000,
              barGroups: monthlyRevenue
                  .asMap()
                  .entries
                  .map((entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value,
                            color: Colors.purple,
                            width: 20,
                          ),
                        ],
                      ))
                  .toList(),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: true),
              gridData: const FlGridData(show: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductPerformanceChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Performance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barGroups: productPerformance
                  .asMap()
                  .entries
                  .map((entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value,
                            color: Colors.green,
                            width: 20,
                          ),
                        ],
                      ))
                  .toList(),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: true),
              gridData: const FlGridData(show: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSellingProductsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Selling Products',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topSellingProducts.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text((index + 1).toString(),
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(topSellingProducts[index]),
              subtitle: Text('Sold Quantity: ${productPerformance[index]}'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConversionRate() {
    return ListTile(
      title: const Text(
        'Conversion Rate',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        '$conversionRate%',
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
      ),
    );
  }

  Widget _buildRepeatCustomerRate() {
    return ListTile(
      title: const Text(
        'Repeat Customer Rate',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        '$repeatCustomerRate%',
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildAverageOrderValue() {
    return ListTile(
      title: const Text(
        'Average Order Value',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        '\$${avgOrderValue.toStringAsFixed(2)}',
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
      ),
    );
  }

  Widget _buildNewCustomers() {
    return ListTile(
      title: const Text(
        'New Customers',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        '$newCustomers',
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
      ),
    );
  }

  Widget _buildSalesSummary() {
    double totalRevenue = weeklyRevenue.reduce((a, b) => a + b);
    int totalProductsSold = productPerformance.reduce((a, b) => a + b).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sales Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Revenue: \$${totalRevenue.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Total Products Sold: $totalProductsSold',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Average Sale Value: \$${(totalRevenue / totalProductsSold).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
