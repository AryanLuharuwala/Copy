import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/utils/global_variables.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _productList = [];
  DateTime? _lastUpdated; // Timestamp for the last sync with the server
  bool _hasUnsyncedChanges = false; // Track whether local changes exist

  // Getter for product list
  List<Map<String, dynamic>> get productList => _productList;

  // Getter for total price
  double get totalPrice => _productList.fold(
        0,
        (sum, item) {
          final price = double.parse(item['price'].toString());
          return sum + (price * item['quantity']);
        },
      );

  CartProvider() {
    _initializeCart(); // Initialize cart from local storage and server
  }

  /// Initialize cart: Load locally, then sync with the server
  Future<void> _initializeCart() async {
    await _loadCartLocally();
    await _syncCartWithServer(); // Sync only if needed
  }

  /// Load cart from local storage
  Future<void> _loadCartLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart');
    final lastUpdatedString = prefs.getString('last_updated');

    if (cartJson != null) {
      _productList = List<Map<String, dynamic>>.from(jsonDecode(cartJson));
    }

    if (lastUpdatedString != null) {
      _lastUpdated = DateTime.parse(lastUpdatedString);
    }

    notifyListeners();
  }

  /// Save cart to local storage
  Future<void> _saveCartLocally() async {
    print(_productList);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cart', jsonEncode(_productList));
    prefs.setString('last_updated', _lastUpdated?.toIso8601String() ?? '');
  }

  /// Sync cart with the server using `/cart/sync` endpoint
  Future<void> _syncCartWithServer() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http.post(
        Uri.parse('$uri/api/cart/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Replace with actual token
        },
        body: jsonEncode({
          'lastUpdated': _lastUpdated?.toIso8601String(),
          'cart': _productList,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['updated'] == true) {
          // Update local cart with server's cart
          _productList = List<Map<String, dynamic>>.from(data['cart']);
          _lastUpdated = DateTime.parse(data['lastUpdated']);
          _hasUnsyncedChanges = false; // Mark changes as synced
          await _saveCartLocally();
          notifyListeners();
        }
      } else {
        print('Failed to sync cart: ${response.statusCode}');
      }
    } catch (e) {
      print('Error syncing cart with server: $e');
    }
  }

  void increaseQuantity(int index) {
    _productList[index]['quantity'] += 1;
    _saveCartLocally(); // Save updated cart to local storage
    notifyListeners(); // Notify listeners to rebuild UI
  }

  void decreaseQuantity(int index) {
    if (_productList[index]['quantity'] > 1) {
      _productList[index]['quantity'] -= 1;
      _saveCartLocally(); // Save updated cart to local storage
      notifyListeners(); // Notify listeners to rebuild UI
    }
  }

  /// Add item to cart
  void addItem(Map<String, dynamic> item) {
    print(item);
    final existingItem = _productList.firstWhere(
      (cartItem) => cartItem['productId'] == item['productId'],
      orElse: () => <String, dynamic>{},
    );

    if (existingItem.isNotEmpty) {
      // Update quantity if the item already exists
      existingItem['quantity'] += item['quantity'];
    } else {
      // Add a new item
      _productList.add(item);
    }

    _lastUpdated = DateTime.now();
    _hasUnsyncedChanges = true; // Mark changes for sync
    _saveCartLocally();
    notifyListeners();
    _syncCartWithServer(); // Sync immediately after change
  }

  /// Remove item from cart
  void removeItem(int index) {
    _productList.removeAt(index);

    _lastUpdated = DateTime.now();
    _hasUnsyncedChanges = true; // Mark changes for sync
    _saveCartLocally();
    notifyListeners();
    _syncCartWithServer(); // Sync immediately after change
  }

  void clearCart() {
    _productList.clear();
    _lastUpdated = DateTime.now();
    _hasUnsyncedChanges = true;
    _saveCartLocally();
    notifyListeners();
    _syncCartWithServer(); // Sync to clear server-side cart as well
  }

  /// Sync changes with the server if there are unsynced changes
  Future<void> syncChanges() async {
    if (_hasUnsyncedChanges) {
      await _syncCartWithServer();
    }
  }

}
