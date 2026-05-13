import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/product_service.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  File? selectedImage;
  bool _isUploading = false;

  final picker = ImagePicker();
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final hostelController = TextEditingController();
  final phoneController = TextEditingController();
  final productService = ProductService();

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    hostelController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future pickImage() async {
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;
    setState(() {
      selectedImage = File(image.path);
    });
  }

  Future<void> _handleUpload() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    if (titleController.text.isEmpty ||
        priceController.text.isEmpty ||
        hostelController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (int.tryParse(priceController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Price must be a valid number")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await productService.addProduct(
        name: titleController.text,
        price: int.parse(priceController.text),
        hostel: hostelController.text,
        phone: phoneController.text,
        image: selectedImage!,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sell Product")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    selectedImage!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.photo),
                label: const Text("Choose Photo"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Product Name"),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price"),
              ),
              TextField(
                controller: hostelController,
                decoration: const InputDecoration(labelText: "Hostel"),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isUploading ? null : _handleUpload,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("UPLOAD"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}