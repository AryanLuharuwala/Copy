import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/utils/cart_provider.dart';
import 'package:myapp/utils/global_variables.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  Future<void> _placeOrder(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('$uri/api/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'cart': cartProvider.productList.map((item) {
            return {
              'productId': item['productId'],
              'quantity': item['quantity'],
              'price': item['price'],
              'seller': item['seller'],
            };
          }).toList(),
        }),
      );

      if (response.statusCode == 200) {
        // Order placed successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );

        // Clear the cart
        cartProvider.clearCart();

        // Navigate to orders page or home
        Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
      } else {
        // Handle errors
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Failed to place order.')),
        );
      }
    } catch (e) {
      print('Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while placing the order.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cartProvider.productList.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.productList.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.productList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(item['imageUrl']),
                        ),
                        title: Text(item['productName']),
                        subtitle: Text('Quantity: ${item['quantity']}'),
                        trailing: Text('\$${item['price']}'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _placeOrder(context),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text('Place Order'),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
