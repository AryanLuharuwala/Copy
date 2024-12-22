import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/features/user/widget/checkout.dart';
import 'package:myapp/utils/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Your Cart', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final productList = cartProvider.productList;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: productList.isEmpty
                      ? const Center(
                          child: Text(
                            'Your cart is empty',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      : AnimatedList(
                          key: _listKey,
                          initialItemCount: productList.length,
                          itemBuilder: (context, index, animation) {
                            final product = productList[index];

                            return SizeTransition(
                              key: ValueKey(product['id']), // Unique key
                              sizeFactor: animation,
                              child: CartItemWidget(
                                product: product,
                                cartProvider: cartProvider,
                                onRemove: () => _removeItem(index),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '₹${cartProvider.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(75),
                          ),
                        ),
                        onPressed: () {
                          const CheckoutPage();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.navigate_next_outlined),
                            SizedBox(width: 10),
                            Text(
                              "Checkout",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _removeItem(int index) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Remove the item from AnimatedList first
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          height: 100,
          color: Colors.redAccent,
          alignment: Alignment.center,
          child: const Text(
            'Removing...',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );

    // Delay the removal from the data source to match the animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (index < cartProvider.productList.length) {
        cartProvider.removeItem(index);
      }
    });
  }
}

class CartItemWidget extends StatefulWidget {
  final Map<String, dynamic> product;
  final CartProvider cartProvider;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.product,
    required this.cartProvider,
    required this.onRemove,
  });

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;

  void _onClear() {
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110, // Slightly increased height for better spacing
      child: Stack(
        children: [
          // Background with "Options" and "Clear"
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Options Button
                GestureDetector(
                  onTap: () {
                    _showOptionsDialog(context, widget.product);
                  },
                  child: Container(
                    width: 75,
                    height: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Text(
                      "Options",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5), // Gap between buttons
                // Clear Button
                GestureDetector(
                  onTap: _onClear,
                  child: Container(
                    width: 75,
                    height: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Text(
                      "Clear",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Foreground item (the cart widget)
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragOffset =
                      (_dragOffset + details.delta.dx).clamp(-160.0, 0.0);
                });
              },
              onHorizontalDragEnd: (details) {
                if (_dragOffset < -80) {
                  setState(() {
                    _dragOffset = -160.0;
                  });
                } else {
                  setState(() {
                    _dragOffset = 0.0;
                  });
                }
              },
              child: Container(
                height: 110, // Matching height with the background
                margin:
                    const EdgeInsets.symmetric(vertical: 6.0), // Reduced gap
                padding: const EdgeInsets.all(12.0), // Consistent padding
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          8.0), // Rounded corners for the image
                      child: Image.network(
                        widget.product["images"]?[0]["url"] ??
                            'assets/default.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                    const SizedBox(
                        width: 12), // Adjusted gap between image and details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.product["name"] ?? 'Unnamed Product',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Price: ₹${widget.product['price'] ?? 'N/A'}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Quantity: ${widget.product['quantity']}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Decrease quantity logic
                        widget.cartProvider.decreaseQuantity(widget
                            .cartProvider.productList
                            .indexOf(widget.product));
                      },
                      icon: const Icon(
                        Icons.remove_circle,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.product['quantity'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Increase quantity logic
                        widget.cartProvider.increaseQuantity(widget
                            .cartProvider.productList
                            .indexOf(widget.product));
                      },
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Options for ${product['name']}"),
          content: const Text("You can add more actions here."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
