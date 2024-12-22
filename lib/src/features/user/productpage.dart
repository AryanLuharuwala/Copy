import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/features/user/widget/cart_popup.dart';
import 'package:myapp/utils/cart_provider.dart';

class ProductPage extends StatefulWidget {
  final Map<String, dynamic> productData; // Initial product data

  const ProductPage({
    super.key,
    required this.productData,
  });

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Map<String, dynamic> productData;

  @override
  void initState() {
    super.initState();
    productData = widget.productData; // Initialize product data
  }

  @override
  Widget build(BuildContext context) {
    print(productData);
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          productData['name'] ?? 'Product',
          style: TextStyle(
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkTheme ? Colors.black : Colors.grey[100],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImages(isDarkTheme),
                const SizedBox(height: 16),
                _buildDescriptionSection(isDarkTheme),
                const SizedBox(height: 16),
                _buildSellerInfo(isDarkTheme),
                const SizedBox(height: 16),
                _buildStockAndPrice(isDarkTheme),
              ],
            ),
          ),
          _buildBottomSection(isDarkTheme),
        ],
      ),
    );
  }

  Widget _buildProductImages(bool isDarkTheme) {
    final images =
        productData['images'] as List<dynamic>?; // Safely cast as a list
    if (images == null || images.isEmpty) {
      // Fallback if images are null or empty
      return Container(
        height: MediaQuery.of(context).size.height * 0.3,
        color: isDarkTheme ? Colors.black : Colors.grey[300],
        child: Center(
          child: Text(
            'No images available',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: PageView.builder(
        itemCount: images.length, // Access the length safely
        itemBuilder: (context, index) {
          final imageObject =
              images[index] as Map<String, dynamic>?; // Safely cast as a map
          final imageUrl = imageObject?['url'] ?? '';
          final altText = imageObject?['altText'] ?? 'Image';

          if (imageUrl.isEmpty) {
            // Fallback for missing image URL
            return Center(
              child: Text(
                altText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
            );
          }

          return Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 30.0),
                  const SizedBox(height: 8.0),
                  Text(
                    altText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }

  Widget _buildDescriptionSection(bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Description",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            productData['broadcast'] ?? 'No description available',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo(bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Seller Information",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Name: ${productData['sellerName'] ?? 'Unknown'}",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Location: ${productData['sellerLocation'] ?? 'Unknown'}",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Seller ID: ${productData['sellerId'] ?? 'Unknown'}",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStockAndPrice(bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Stock and Price",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Stock: ${productData['stock']}",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Price: ₹${productData['price']}",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(bool isDarkTheme) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false).addItem({
                    'productId': productData['productId'],
                    'sellerId': productData['sellerId'],
                    'name': productData['name'],
                    'price': productData['price'],
                    'image': productData['images'],
                    'quantity': 1,
                  });
                  showDialog(
                    context: context,
                    builder: (context) => CartPopupOverlay(
                      onClose: () => Navigator.of(context).pop(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                ),
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
