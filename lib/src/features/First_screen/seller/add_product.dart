import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/utils/global_variables.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final bool _isBatchMode = false;
  bool _isAutoCategorization = false;
  XFile? _selectedImageFile;
  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // For showing a loading indicator during API calls

  // Function to upload product image
  Future<void> _pickProductImage() async {
    if (kIsWeb) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _selectedImageFile = null;
        });
      }
    } else {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = pickedFile;
          _webImageBytes = null;
        });
      }
    }

    if (_isAutoCategorization) {
      await _categorizeProduct();
    }
  }

  // Function to categorize product using AI API
  Future<void> _categorizeProduct() async {
    if (_webImageBytes == null && _selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$uri/api/product-categorize'),
      );

      if (kIsWeb && _webImageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          _webImageBytes!,
          filename: 'uploaded_image.jpg',
        ));
      } else if (!kIsWeb && _selectedImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _selectedImageFile!.path,
        ));
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody.body);

        // Populate form fields with API response
        setState(() {
          _productNameController.text = data['productName'] ?? '';
          _skuController.text = data['internalSku'] ?? '';
          _descriptionController.text = data['tags']?.join(', ') ?? '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product details categorized successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to categorize product.')),
        );
      }
    } catch (e) {
      print('Error categorizing product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Submit individual product
  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$uri/api/seller/add-product'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      if (!kIsWeb && _selectedImageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _selectedImageFile!.path,
        ));
      } else if (kIsWeb && _webImageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          _webImageBytes!,
          filename: 'uploaded_image.jpg',
        ));
      }

      request.fields['name'] = _productNameController.text;
      request.fields['sku'] = _skuController.text;
      request.fields['price'] = _priceController.text;
      request.fields['stock'] = _stockController.text;
      request.fields['description'] = _descriptionController.text;

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        _clearForm();
      } else {
        final responseBody = await http.Response.fromStream(response);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${responseBody.body}')),
        );
      }
    } catch (e) {
      print('Error adding product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred.')),
      );
    }
  }

  // Clear form fields
  void _clearForm() {
    _productNameController.clear();
    _skuController.clear();
    _priceController.clear();
    _stockController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedImageFile = null;
      _webImageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const PageStorageKey('AddProductPageScroll'),
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Automatic Categorization'),
                  value: _isAutoCategorization,
                  onChanged: (value) {
                    setState(() {
                      _isAutoCategorization = value;
                    });
                  },
                ),
                _buildImagePreview(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickProductImage,
                  child: const Text('Upload Product Image'),
                ),
                if (_isLoading) const CircularProgressIndicator(),
                const SizedBox(height: 16),
                _buildFormFields(),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitProduct,
                    child: const Text('Save Product'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _webImageBytes != null) {
      return Image.memory(
        _webImageBytes!,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && _selectedImageFile != null) {
      return Image.file(
        File(_selectedImageFile!.path),
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      );
    } else {
      return const Icon(Icons.image, size: 150);
    }
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _productNameController,
          decoration: const InputDecoration(labelText: 'Product Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a product name.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _skuController,
          decoration: const InputDecoration(labelText: 'SKU'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _priceController,
          decoration: const InputDecoration(labelText: 'Price'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a price.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _stockController,
          decoration: const InputDecoration(labelText: 'Stock Quantity'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the stock quantity.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
          maxLines: 3,
        ),
      ],
    );
  }
}
