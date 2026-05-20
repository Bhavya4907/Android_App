import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/club_post_service.dart';

// ── Palette (mirrors the rest of the app) ────────────────────────────────────
const _bg = Color(0xFF0E0E14);
const _surface = Color(0xFF16161F);
const _card = Color(0xFF1C1C28);
const _border = Color(0x12FFFFFF);
const _accent = Color(0xFFFF6B35);
const _accentDim = Color(0x26FF6B35);
const _textPrimary = Color(0xFFF0EEF8);
const _textSecondary = Color(0xFF9896AA);
const _textMuted = Color(0xFF5C5B6B);

// ─────────────────────────────────────────────────────────────────────────────
// CreateClubPostScreen
// ─────────────────────────────────────────────────────────────────────────────
class CreateClubPostScreen extends StatefulWidget {
  final String club;

  const CreateClubPostScreen({
    super.key,
    required this.club,
  });

  @override
  State<CreateClubPostScreen> createState() => _CreateClubPostScreenState();
}

class _CreateClubPostScreenState extends State<CreateClubPostScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  final _clubService = ClubPostService();

  File? _selectedImage;
  bool _isPosting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() => _selectedImage = File(image.path));
  }

  bool get _canPost =>
      _selectedImage != null &&
      _titleController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty;

  Future<void> _post() async {
    if (!_canPost || _isPosting) return;
    setState(() => _isPosting = true);
    try {
      await _clubService.createPost(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        image: _selectedImage!,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post. Please try again.'),
            backgroundColor: Color(0xFFF87171),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              _AppBar(clubName: widget.club),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo picker
                      _PhotoPicker(
                        image: _selectedImage,
                        onTap: _pickImage,
                      ),
                      const SizedBox(height: 28),

                      _sectionLabel('Post details'),
                      const SizedBox(height: 12),

                      _DarkField(
                        controller: _titleController,
                        label: 'Title',
                        hint: 'Give your post a title…',
                        icon: Icons.title_rounded,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      _DarkField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'What\'s happening in your club?',
                        icon: Icons.notes_rounded,
                        maxLines: 5,
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: 36),

                      _PostButton(
                        canPost: _canPost,
                        isPosting: _isPosting,
                        onTap: _post,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          color: _textMuted,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w500,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final String clubName;
  const _AppBar({required this.clubName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _card,
                shape: BoxShape.circle,
                border: Border.all(color: _border, width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: _textSecondary, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clubName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: _textMuted,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'New Post',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Photo picker
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoPicker extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  const _PhotoPicker({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: image != null ? _accent.withOpacity(0.4) : _border,
            width: image != null ? 1 : 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: image != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(image!, fit: BoxFit.cover),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.15), width: 0.5),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 13, color: Colors.white),
                          SizedBox(width: 5),
                          Text('Change',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white)),
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
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _accentDim,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined,
                        color: _accent, size: 24),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Add a photo',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to choose from gallery',
                    style: TextStyle(fontSize: 12, color: _textMuted),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dark text field
// ─────────────────────────────────────────────────────────────────────────────
class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const _DarkField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: _textPrimary),
      cursorColor: _accent,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: _textMuted),
        labelStyle: const TextStyle(fontSize: 13, color: _textSecondary),
        floatingLabelStyle: const TextStyle(fontSize: 12, color: _accent),
        prefixIcon: Icon(icon, size: 18, color: _textMuted),
        filled: true,
        fillColor: _card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accent, width: 1),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Post button
// ─────────────────────────────────────────────────────────────────────────────
class _PostButton extends StatelessWidget {
  final bool canPost;
  final bool isPosting;
  final VoidCallback onTap;

  const _PostButton({
    required this.canPost,
    required this.isPosting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canPost ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: canPost ? _accent : _card,
          borderRadius: BorderRadius.circular(16),
          border: canPost ? null : Border.all(color: _border, width: 0.5),
        ),
        child: Center(
          child: isPosting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: canPost ? Colors.white : _textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Post',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: canPost ? Colors.white : _textMuted,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}