import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Corrected line
import 'package:mime/mime.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  List<File> _imageFiles = [];
  bool _isUploading = false;

  String? _selectedCategory;
  final List<String> _categories = [
    'New & Refurbished',
    'Old & Antique',
    'Customized'
  ];

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isEmpty) return;

    List<File> validImages = [];

    for (var pickedFile in pickedFiles) {
      final file = File(pickedFile.path);
      final mimeType = lookupMimeType(file.path);
      final fileSize = await file.length();

      if (!(mimeType?.startsWith('image/') ?? false)) {
        _showError("Only image files are allowed.");
        continue;
      }
      if (fileSize > 5 * 1024 * 1024) {
        _showError("Each image must be under 5MB.");
        continue;
      }

      validImages.add(file);
    }

    if (validImages.length > 5) {
      _showError("A maximum of 5 images is allowed.");
      validImages = validImages.sublist(0, 5);
    }

    setState(() => _imageFiles = validImages);
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFiles.isEmpty) {
      _showError("Please upload at least one image.");
      return;
    }

    if (_selectedCategory == null) {
      _showError("Please select a category.");
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      _showError("Please enter a valid price.");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError("You must be logged in to add a product.");
      return;
    }

    setState(() => _isUploading = true);

    try {
      List<String> imageUrls = [];
      for (var file in _imageFiles) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('product_images/${user.uid}/$fileName');
        await storageRef.putFile(file);
        final url = await storageRef.getDownloadURL();
        imageUrls.add(url);
      }

      await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': price,
        'size': _sizeController.text.trim(),
        'color': _colorController.text.trim(),
        'category': _selectedCategory,
        'imageUrls': imageUrls,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'isApproved': false,
      });

      _showError("Product added successfully!");

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Failed to add product: $e");
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF101625);
    const Color maroon = Color(0xFF70142C);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: maroon,
        title:
        const Text("Add Product", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isUploading
          ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text("Uploading product...",
                  style: TextStyle(color: Colors.white70))
            ],
          ))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Product Name'),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description',
                  maxLines: 4),
              const SizedBox(height: 16),
              _buildTextField(_priceController, 'Price',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_sizeController, 'Size'),
              const SizedBox(height: 16),
              _buildTextField(_colorController, 'Color'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF2B222A),
                value: _selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2B222A),
                  hintText: "Select Category",
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                validator: (value) =>
                value == null ? 'Please select a category' : null,
                onChanged: (val) =>
                    setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imageFiles.isEmpty
                      ? const Center(
                    child: Text("Tap to upload up to 5 images",
                        style: TextStyle(color: Colors.white60)),
                  )
                      : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageFiles.length,
                    itemBuilder: (_, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFiles[index],
                              width: 150, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isUploading ? null : _saveProduct,
                  child: const Text("Save Product",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (val) => val == null || val.isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2B222A),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}