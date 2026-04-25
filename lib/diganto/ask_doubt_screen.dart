import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'doubt_model.dart';
import 'auth_service.dart';
import 'doubt_service.dart';
import 'app_theme.dart';

class AskDoubtScreen extends StatefulWidget {
  final String? defaultInputType;

  const AskDoubtScreen({super.key, this.defaultInputType});

  @override
  State<AskDoubtScreen> createState() => _AskDoubtScreenState();
}

class _AskDoubtScreenState extends State<AskDoubtScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DoubtSubject _selectedSubject = DoubtSubject.cse;
  DoubtInputType _inputType = DoubtInputType.text;
  File? _imageFile;
  bool _isPosting = false;
  List<String> _tags =[];
  final _tagController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    if (widget.defaultInputType == 'image') {
      _inputType = DoubtInputType.image;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _postDoubt() async {
    if (!_formKey.currentState!.validate()) return;
    if (_titleController.text.trim().isEmpty) {
      _showSnack('Please enter a title');
      return;
    }

    setState(() => _isPosting = true);

    try {

      final user = FirebaseAuth.instance.currentUser;
      final doubtService = DoubtService();
      final id = await doubtService.postDoubt(
        userId: user?.uid ?? '',
        userName: user?.email?.split('@').first ?? 'Anonymous',
        userPhotoUrl: null,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        subject: _selectedSubject,
        inputType: _inputType,
        imageFile: _imageFile,
        tags: _tags,
      );

      if (id != null && mounted) {
        _showSnack('Doubt posted successfully! 🎉');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 5) {
      setState(() => _tags.add(tag.toLowerCase()));
      _tagController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubjectPicker(),
                const SizedBox(height: 20),
                _buildTitleField(),
                const SizedBox(height: 20),
                _buildInputTypePicker(),
                const SizedBox(height: 16),
                _buildInputArea(),
                const SizedBox(height: 20),
                _buildTagsSection(),
                const SizedBox(height: 32),
                _buildPostButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.bgPrimary,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: const Icon(Icons.close,
              size: 18, color: AppTheme.textPrimary),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Ask a Doubt',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.neonPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppTheme.neonPurple.withValues(alpha: 0.3)),
            ),
            child: Text(
              '5 pts',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: AppTheme.neonPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Subject'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DoubtSubject.values.map((subject) {
            final isSelected = _selectedSubject == subject;
            return GestureDetector(
              onTap: () => setState(() => _selectedSubject = subject),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? subject.subjectColor.withValues(alpha: 0.2)
                      : AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? subject.subjectColor
                        : AppTheme.borderColor,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  subject.subjectLabel,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? subject.subjectColor
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Question Title'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          style:
              GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'e.g. How does quicksort work internally?',
            counterStyle:
                GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11),
          ),
          validator: (v) =>
              v?.isEmpty == true ? 'Please enter a title' : null,
        ),
      ],
    );
  }

  Widget _buildInputTypePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Post Method'),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTypeButton(
              icon: Icons.keyboard,
              label: 'Type',
              type: DoubtInputType.text,
            ),
            const SizedBox(width: 10),
            _buildTypeButton(
              icon: Icons.photo_camera,
              label: 'Photo',
              type: DoubtInputType.image,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required IconData icon,
    required String label,
    required DoubtInputType type,
  }) {
    final isSelected = _inputType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _inputType = type);
          if (type == DoubtInputType.image) _pickImage();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppTheme.neonPurple.withValues(alpha: 0.25),
                      AppTheme.neonPurple.withValues(alpha: 0.08),
                    ],
                  )
                : null,
            color: isSelected ? null : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isSelected ? AppTheme.neonPurple : AppTheme.borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? AppTheme.neonPurple
                    : AppTheme.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppTheme.neonPurple
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    switch (_inputType) {
      case DoubtInputType.image:
        return _buildImageInput();
      case DoubtInputType.text:
      default:
        return _buildTextInput();
    }
  }

  Widget _buildTextInput() {
    return TextFormField(
      controller: _descController,
      style:
          GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
      maxLines: 8,
      decoration: const InputDecoration(
        hintText: 'Describe your doubt in detail...',
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildImageInput() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _imageFile != null
                    ? AppTheme.neonPurple
                    : AppTheme.borderColor,
              ),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_imageFile!, fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _imageFile = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    Colors.black.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to upload an image',
                        style: GoogleFonts.inter(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JPG, PNG up to 10MB',
                        style: GoogleFonts.inter(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descController,
          style:
              GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add description for the image (optional)...',
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Tags (optional, max 5)'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagController,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'e.g. sorting, algorithms',
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                onFieldSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _addTag(_tagController.text),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.neonPurple.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '#$tag',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.neonPurpleLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => _tags.remove(tag)),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: AppTheme.neonPurpleLight,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPostButton() {
    return GestureDetector(
      onTap: _isPosting ? null : _postDoubt,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: _isPosting ? null : AppTheme.primaryGradient,
          color: _isPosting ? AppTheme.bgCard : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPosting ? null : AppTheme.neonShadow,
        ),
        child: Center(
          child: _isPosting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppTheme.neonPurple,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'Post Doubt',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}