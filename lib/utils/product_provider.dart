import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/utils/global_variables.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ProductProvider with ChangeNotifier {
  final Map<int, List<dynamic>> _productPages = {}; // Map to store products by page
  List<dynamic> _recommendedProducts = [];
  final List<Map<String, dynamic>> _analytics = [];
  List<String> _searchHistory = [];
  List<Map<String, dynamic>> _pendingAnalyticsUploads = [];
  bool _isProductsFetched = false;
  int _currentPage = 1; // Current page for pagination
  double latitude = 0.0; // Persistent location
  double longitude = 0.0;
  bool _isLoading = false;
  String _errorMessage = '';
  String _lastSearchQuery = ''; // For search history

  // Flattened list of products from the last 3 pages

  List<dynamic> get recommendedProducts => _recommendedProducts;
  List<Map<String, dynamic>> get analytics => _analytics;
  List<Map<String, dynamic>> get pendingAnalyticsUploads =>
      _pendingAnalyticsUploads;
  List<String> get searchHistory => _searchHistory;
  bool get isProductsFetched => _isProductsFetched;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get lastSearchQuery => _lastSearchQuery;

// Fetch products from backend (paginated)
  // Getter for flattened products
  List<dynamic> get allProducts {
    final sortedPages = _productPages.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)); // Sort by page number
    return sortedPages.expand((entry) => entry.value).toList();
  }

  // Fetch products for a specific page
  Future<void> fetchProducts(int page) async {
    if (_isLoading || _productPages.containsKey(page)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final authtoken = prefs.getString('token');

      const String apiUrl = '$uri/api/products';

      final response = await http.get(
        Uri.parse('$apiUrl?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authtoken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final newProducts = data['products'] as List<dynamic>;
        print(newProducts.length);
        // Cache the new page
        _productPages[page] = newProducts;
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to fetch products: ${response.body}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch the next page
  Future<void> fetchNextPage() async {
    await fetchProducts(_currentPage + 1);
    _currentPage += 1;
  }

  // Fetch the previous page
  Future<void> fetchPreviousPage() async {
    if (_currentPage > 1) {
      await fetchProducts(_currentPage - 1);
      _currentPage -= 1;
    }
  }

  // Reset pagination and clear cached product list
  void resetProducts() {
    _productPages.clear();
    _currentPage = 1;
    _isProductsFetched = false;
    notifyListeners();
  }

  Future<void> initializeLocation() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        Location location = Location();
        bool serviceEnabled = await location.serviceEnabled();
        if (!serviceEnabled) serviceEnabled = await location.requestService();

        PermissionStatus permissionGranted = await location.hasPermission();
        if (permissionGranted == PermissionStatus.denied) {
          permissionGranted = await location.requestPermission();
        }

        if (serviceEnabled && permissionGranted == PermissionStatus.granted) {
          LocationData locationData = await location.getLocation();
          latitude = locationData.latitude ?? 0.0;
          longitude = locationData.longitude ?? 0.0;
        }
      } catch (e) {
        debugPrint("Error accessing location: $e");
      }
    }
  }

  // Add a pending analytics upload
  void addPendingAnalytics(Map<String, dynamic> trackedItem) {
    _pendingAnalyticsUploads.add(trackedItem);
    savePendingAnalyticsToStorage(); // Save to persistent storage
    notifyListeners();
  }

  // Save pending analytics to storage
  Future<void> savePendingAnalyticsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('pendingAnalytics', json.encode(_pendingAnalyticsUploads));
  }

  // Load pending analytics from storage
  Future<void> loadPendingAnalyticsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('pendingAnalytics');
    if (storedData != null) {
      _pendingAnalyticsUploads =
          List<Map<String, dynamic>>.from(json.decode(storedData));
      notifyListeners();
    }
  }

  // Sync pending analytics when network is available
  Future<void> syncPendingAnalytics() async {
    if (_pendingAnalyticsUploads.isEmpty) return;

    for (var trackedItem in List.from(_pendingAnalyticsUploads)) {
      try {
        const String analyticsUrl = '$uri/api/analytics';
        final response = await http.post(
          Uri.parse(analyticsUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(trackedItem),
        );

        if (response.statusCode == 200) {
          _pendingAnalyticsUploads.remove(trackedItem);
        }
      } catch (e) {
        debugPrint('Error uploading pending analytics: $e');
        break; // Stop the loop if network fails
      }
    }

    savePendingAnalyticsToStorage(); // Save updated list to storage
    notifyListeners();
  }

  // Monitor network status and sync when network is available
  void monitorNetworkStatus() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        syncPendingAnalytics();
      }
    });
  }

  // Update the last search query and add to history
  void updateLastSearchQuery(String query) {
    _lastSearchQuery = query;

    // Update search history
    if (!_searchHistory.contains(query)) {
      _searchHistory.insert(0, query); // Add to the beginning of the list
      if (_searchHistory.length > 10) {
        _searchHistory.removeLast(); // Limit history to 10 items
      }
      saveSearchHistoryToStorage(); // Save to persistent storage
    }

    notifyListeners();
  }

  // Save search history to storage
  Future<void> saveSearchHistoryToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('searchHistory', _searchHistory);
  }

  // Load search history from storage
  Future<void> loadSearchHistoryFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList('searchHistory') ?? [];
    notifyListeners();
  }

  // Track analytics (with location)
  void trackItem(String type, dynamic item, String userId) {
    final trackedItem = {
      'type': type,
      'item': item,
      'userId': userId,
      'location': {
        'type': 'Point',
        'coordinates': [longitude, latitude]
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
    _analytics.add(trackedItem);
    addPendingAnalytics(trackedItem); // Add to pending uploads
    notifyListeners();
  }

  // Publish analytics to the backend
  Future<void> publishAnalytics(Map<String, dynamic> trackedItem) async {
    try {
      const String analyticsUrl = '$uri/api/analytics';
      final response = await http.post(
        Uri.parse(analyticsUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(trackedItem),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to upload analytics: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error uploading analytics: $e');
    }
  }

  // Call this during app initialization
  Future<void> initializeProvider() async {
    await initializeLocation();
    await loadPendingAnalyticsFromStorage();
    await loadSearchHistoryFromStorage();
    monitorNetworkStatus();
  }

  // Add recommended products
  void addRecommendedProducts(List<dynamic> products) {
    _recommendedProducts = products;
    notifyListeners();
  }
}
