import 'package:flutter/material.dart';
import 'package:myapp/src/features/user/widget/cart_map_page.dart';
import 'cart_page.dart';

class CartPopupOverlay extends StatefulWidget {
  final VoidCallback onClose;


  const CartPopupOverlay({
    super.key,
    required this.onClose,

  });

  @override
  _CartPopupOverlayState createState() => _CartPopupOverlayState();
}

class _CartPopupOverlayState extends State<CartPopupOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showCart = true; // State to toggle between cart and map

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleView() {
    setState(() {
      _showCart = !_showCart; // Toggle between showing cart and map
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            color: Colors.black.withOpacity(0.5), // Dark background overlay
          ),
        ),
        Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _controller.value,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(75.0),
                  ),
                  child: Stack(
                    children: [
                      // Show CartPage or CartMapPage based on _showCart state
                      _showCart
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(75.0),
                              child: const CartPage(
                                
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(75.0),
                              child: const CartMapPage(
                                shopLocations: [
                                  {'latitude': 28.7041, 'longitude': 77.1025},
                                  {'latitude': 28.5355, 'longitude': 77.3910},
                                  {'latitude': 28.4595, 'longitude': 77.0266},
                                ],
                              ),
                            ),

                      // Centered button to toggle between cart and map views
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(75),
                              ),
                            ),
                            onPressed: _toggleView,
                            child: _showCart
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        Icon(Icons.navigation_outlined),
                                        SizedBox(width: 10),
                                        Text(
                                          "View Map",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        SizedBox(width: 10),
                                      ])
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        Icon(Icons
                                            .shopping_cart_checkout_outlined),
                                        SizedBox(width: 10),
                                        Text(
                                          "View Cart",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        SizedBox(width: 10),
                                      ]),
                          ),
                        ),
                      ),
                      if (!_showCart)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(75),
                                ),
                              ),
                              onPressed: () {},
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
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
