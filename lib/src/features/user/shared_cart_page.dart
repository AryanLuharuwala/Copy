import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SharedCartPage extends StatefulWidget {
  const SharedCartPage({super.key});

  @override
  _SharedCartPageState createState() => _SharedCartPageState();
}

class _SharedCartPageState extends State<SharedCartPage> {
  List<dynamic> sharedCartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSharedCartData();
  }

  Future<void> fetchSharedCartData() async {
    // Replace this URL with your actual API endpoint
    const String url = 'https://your-api-url.com/api/cart/shared';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          sharedCartData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load shared cart data');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Cart'),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Shared Cart Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: sharedCartData.length,
                      itemBuilder: (context, index) {
                        final cartItem = sharedCartData[index];
                        return SharedCartItem(
                          productName: cartItem['product']['name'],
                          productImage: cartItem['product']['image'],
                          sharedBy: cartItem['sharedBy'],
                        );
                      },
                    ),
                  ),
                  // Floating Action Button at Bottom
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8),
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                // Floating action button functionality
                              },
                              icon: const Icon(Icons.add, color: Colors.white),
                            ),
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
}

class SharedCartItem extends StatelessWidget {
  final String productName;
  final String productImage;
  final String sharedBy;

  const SharedCartItem({
    super.key,
    required this.productName,
    required this.productImage,
    required this.sharedBy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(8),
            ),
            child: productImage.isNotEmpty
                ? Image.asset(
                    productImage,
                    fit: BoxFit.cover,
                  )
                : Container(),
          ),
          const SizedBox(width: 16),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'By $sharedBy',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
