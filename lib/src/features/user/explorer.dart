import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/features/user/Loading.dart';
import 'package:myapp/src/features/user/productpage.dart';
import 'package:myapp/src/settings/settings_controller.dart';
import 'package:myapp/utils/product_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  @override
  _ExplorerPageState createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Fetch the first page initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      productProvider.fetchProducts(0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    // Fetch next page when scrolling to the bottom
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !productProvider.isLoading) {
      productProvider.fetchNextPage();
    }

    // Fetch previous page when scrolling to the top
    if (_scrollController.position.pixels <= 200 &&
        !productProvider.isLoading) {
      productProvider.fetchPreviousPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    // Show "Coming Soon" page if no products are available
    if (productProvider.allProducts.isEmpty) {
      return const Loading();
    }

    return Stack(
      children: [
        // Main Product Grid
        GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: productProvider.allProducts.length +
              (productProvider.isLoading ? 3 : 0), // Add placeholders
          itemBuilder: (context, index) {
            // Show loading placeholders
            if (index >= productProvider.allProducts.length) {
              return _buildLoadingPlaceholder();
            }

            final product = productProvider.allProducts[index];
            return _buildProductCard(context, product);
          },
        ),

        // Loading Indicator for Fetching More Products
        if (productProvider.isLoading)
          const Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    int currentPage = 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productData: product,
              ),
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: (product['images'] is List<dynamic>)
                        ? PageView.builder(
                            itemCount: product['images'].length,
                            onPageChanged: (index) {
                              currentPage = index;
                            },
                            itemBuilder: (context, index) {
                              final imageObject = product['images'][index];
                              final imageUrl = imageObject['url'] ?? '';
                              final altText = imageObject['altText'] ?? 'Image';

                              return Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error,
                                            color: Colors.red, size: 30.0),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          altText,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                              );
                            },
                          )
                        : Image.network(
                            product['images']?[0]['url'] ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error, color: Colors.red),
                          ),
                  ),
                  if (product['images'] is List<dynamic>)
                    Positioned(
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product['images'].length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: 6.0,
                            height: 6.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentPage == index
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product['name'] ?? 'Unnamed Product',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Price: ₹${product['price']}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
