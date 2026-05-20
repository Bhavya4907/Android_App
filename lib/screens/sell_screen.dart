import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/product_service.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen>
    with SingleTickerProviderStateMixin {
  File? selectedImage;
  bool _isUploading = false;

  final picker = ImagePicker();
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final hostelController = TextEditingController();
  final phoneController = TextEditingController();
  final productService = ProductService();

  static const Color _bg = Color(0xFF0D0D0D);
  static const Color _surface = Color(0xFF1A1A1A);
  static const Color _surfaceBorder = Color(0xFF2A2A2A);
  static const Color _accent = Color(0xFFEEEDFE);
  static const Color _accentText = Color(0xFF3C3489);

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    titleController.dispose();
    priceController.dispose();
    hostelController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;
    setState(() => selectedImage = File(image.path));
  }

  Future<void> _handleUpload() async {
    if (selectedImage == null) {
      _showSnack("Please select an image");
      return;
    }
    if (titleController.text.isEmpty ||
        priceController.text.isEmpty ||
        hostelController.text.isEmpty ||
        phoneController.text.isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }
    if (int.tryParse(priceController.text) == null) {
      _showSnack("Price must be a valid number");
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
      if (mounted) _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: _surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _surfaceBorder),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _surfaceBorder),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
          ),
        ),
        title: const Text(
          'Sell Product',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePicker(),
                const SizedBox(height: 24),
                _sectionLabel('Product details'),
                const SizedBox(height: 12),
                _InputField(
                  controller: titleController,
                  hint: 'Product name',
                  icon: Icons.inventory_2_outlined,
                ),
                const SizedBox(height: 10),
                _InputField(
                  controller: priceController,
                  hint: 'Price (₹)',
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                _sectionLabel('Contact & location'),
                const SizedBox(height: 12),
                _InputField(
                  controller: hostelController,
                  hint: 'Hostel name',
                  icon: Icons.home_outlined,
                ),
                const SizedBox(height: 10),
                _InputField(
                  controller: phoneController,
                  hint: 'Phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),
                _buildUploadButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.35),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: selectedImage != null ? 200 : 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedImage != null ? _accentText.withOpacity(0.4) : _surfaceBorder,
            width: selectedImage != null ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: selectedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(selectedImage!, fit: BoxFit.cover),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_outlined, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: _accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap to add photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG supported',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: GestureDetector(
        onTap: _isUploading ? null : _handleUpload,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isUploading ? _accent.withOpacity(0.6) : _accent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _accentText,
                    ),
                  )
                : const Text(
                    'List for sale',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _accentText,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white.withOpacity(0.3)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.2),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}