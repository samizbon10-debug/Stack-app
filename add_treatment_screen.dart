import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class AddTreatmentScreen extends ConsumerStatefulWidget {
  final String patientId;
  final TreatmentModel? treatment;

  const AddTreatmentScreen({
    super.key,
    required this.patientId,
    this.treatment,
  });

  @override
  ConsumerState<AddTreatmentScreen> createState() => _AddTreatmentScreenState();
}

class _AddTreatmentScreenState extends ConsumerState<AddTreatmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  final _progressNotesController = TextEditingController();
  final _materialController = TextEditingController();
  final _toothNumberController = TextEditingController();

  TreatmentCategory _selectedCategory = TreatmentCategory.fillings;
  DateTime _selectedDate = DateTime.now();
  List<String> _materials = [];
  List<_PendingImage> _pendingImages = [];
  bool _isLoading = false;

  bool get _isEditing => widget.treatment != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _selectedCategory = widget.treatment!.category;
      _selectedDate = widget.treatment!.date;
      _diagnosisController.text = widget.treatment!.diagnosis;
      _notesController.text = widget.treatment!.treatmentNotes;
      _progressNotesController.text = widget.treatment!.progressNotes;
      _toothNumberController.text = widget.treatment!.toothNumber ?? '';
      _materials = List.from(widget.treatment!.materialsUsed);
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _notesController.dispose();
    _progressNotesController.dispose();
    _materialController.dispose();
    _toothNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Treatment' : 'Add Treatment'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTreatment,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Category selection
            _buildCategorySelector(),
            const SizedBox(height: 24),

            // Date picker
            _buildDatePicker(),
            const SizedBox(height: 16),

            // Tooth number (optional)
            _buildTextField(
              controller: _toothNumberController,
              label: 'Tooth Number (optional)',
              icon: Icons.looks_one,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Diagnosis
            _buildTextField(
              controller: _diagnosisController,
              label: 'Diagnosis',
              icon: Icons.assignment,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter diagnosis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Treatment notes
            _buildTextField(
              controller: _notesController,
              label: 'Treatment Notes',
              icon: Icons.note,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Progress notes
            _buildTextField(
              controller: _progressNotesController,
              label: 'Progress Notes',
              icon: Icons.trending_up,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Materials
            _buildMaterialsSection(),
            const SizedBox(height: 24),

            // Photos
            _buildPhotosSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Treatment Category',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: TreatmentCategory.values.map((category) {
            final isSelected = category == _selectedCategory;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getCategoryColor(category)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getCategoryColor(category),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        color: isSelected
                            ? Colors.white
                            : _getCategoryColor(category),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.displayName.split(' ').first,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : _getCategoryColor(category),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Treatment Date',
          prefixIcon: const Icon(Icons.calendar_today),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildMaterialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Materials Used',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _materials.map((material) {
            return Chip(
              label: Text(material),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() => _materials.remove(material)),
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _materialController,
                decoration: InputDecoration(
                  hintText: 'Add material',
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                ),
                onSubmitted: _addMaterial,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addMaterial(_materialController.text),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Clinical Photos',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Add Photo'),
              onPressed: _showPhotoOptions,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_pendingImages.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.textHint.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_a_photo,
                  size: 40,
                  color: AppTheme.textHint,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add clinical photos (Before/During/After)',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pendingImages.length,
              itemBuilder: (context, index) {
                final image = _pendingImages[index];
                return _buildPhotoCard(image, index);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoCard(_PendingImage image, int index) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    image.file,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLabelColor(image.label).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  image.labelDisplay,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getLabelColor(image.label),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => setState(() => _pendingImages.removeAt(index)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLabelColor(PhotoLabel label) {
    switch (label) {
      case PhotoLabel.before:
        return AppTheme.warningColor;
      case PhotoLabel.during:
        return AppTheme.primaryColor;
      case PhotoLabel.after:
        return AppTheme.successColor;
    }
  }

  Color _getCategoryColor(TreatmentCategory category) {
    switch (category) {
      case TreatmentCategory.orthodontics:
        return AppTheme.orthodonticsColor;
      case TreatmentCategory.fillings:
        return AppTheme.fillingsColor;
      case TreatmentCategory.scalingPolishing:
        return AppTheme.scalingColor;
    }
  }

  IconData _getCategoryIcon(TreatmentCategory category) {
    switch (category) {
      case TreatmentCategory.orthodontics:
        return Icons.straighten;
      case TreatmentCategory.fillings:
        return Icons.healing;
      case TreatmentCategory.scalingPolishing:
        return Icons.clean_hands;
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _addMaterial(String value) {
    if (value.trim().isNotEmpty && !_materials.contains(value.trim())) {
      setState(() {
        _materials.add(value.trim());
        _materialController.clear();
      });
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      // Show dialog to select label
      final label = await _showLabelDialog();
      if (label != null) {
        setState(() {
          _pendingImages.add(_PendingImage(
            file: File(pickedFile.path),
            label: label,
          ));
        });
      }
    }
  }

  Future<PhotoLabel?> _showLabelDialog() async {
    return await showDialog<PhotoLabel>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Photo Label'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: PhotoLabel.values.map((label) {
              return ListTile(
                leading: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _getLabelColor(label).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    label == PhotoLabel.before
                        ? Icons.play_arrow
                        : label == PhotoLabel.during
                            ? Icons.more_horiz
                            : Icons.check,
                    color: _getLabelColor(label),
                    size: 18,
                  ),
                ),
                title: Text(label.name[0].toUpperCase() + label.name.substring(1)),
                onTap: () => Navigator.pop(context, label),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _saveTreatment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final userId = firebaseService.currentUserId!;

      // Upload images
      List<TreatmentImage> uploadedImages = [];
      for (var pending in _pendingImages) {
        final image = await firebaseService.uploadTreatmentImage(
          widget.patientId,
          const Uuid().v4(),
          pending.file.path,
          pending.label,
        );
        uploadedImages.add(image);
      }

      final treatment = TreatmentModel(
        id: _isEditing ? widget.treatment!.id : '',
        patientId: widget.patientId,
        category: _selectedCategory,
        toothNumber: _toothNumberController.text.trim().isNotEmpty
            ? _toothNumberController.text.trim()
            : null,
        date: _selectedDate,
        diagnosis: _diagnosisController.text.trim(),
        treatmentNotes: _notesController.text.trim(),
        materialsUsed: _materials,
        progressNotes: _progressNotesController.text.trim(),
        images: uploadedImages,
        createdAt: _isEditing ? widget.treatment!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        userId: userId,
      );

      if (_isEditing) {
        await firebaseService.updateTreatment(treatment);
      } else {
        await firebaseService.createTreatment(treatment);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Treatment updated' : 'Treatment added',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class _PendingImage {
  final File file;
  final PhotoLabel label;

  _PendingImage({required this.file, required this.label});

  String get labelDisplay {
    return label.name[0].toUpperCase() + label.name.substring(1);
  }
}
