import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class AddPatientScreen extends ConsumerStatefulWidget {
  final PatientModel? patient;

  const AddPatientScreen({
    super.key,
    this.patient,
  });

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _notesController = TextEditingController();
  final _allergyController = TextEditingController();

  Gender _selectedGender = Gender.male;
  bool _smokingStatus = false;
  List<String> _allergies = [];
  File? _profileImage;
  String? _existingPhotoUrl;
  bool _isLoading = false;

  bool get _isEditing => widget.patient != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.patient!.name;
      _phoneController.text = widget.patient!.phone;
      _ageController.text = widget.patient!.age.toString();
      _medicalHistoryController.text = widget.patient!.medicalHistory;
      _notesController.text = widget.patient!.notes;
      _selectedGender = widget.patient!.gender;
      _smokingStatus = widget.patient!.smokingStatus;
      _allergies = List.from(widget.patient!.allergies);
      _existingPhotoUrl = widget.patient!.profilePhotoUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _medicalHistoryController.dispose();
    _notesController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Patient' : 'Add Patient'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePatient,
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
            // Profile photo
            _buildProfilePhotoSection(),
            const SizedBox(height: 24),

            // Basic info
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameController,
              label: 'Patient Name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter patient name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _ageController,
                    label: 'Age',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid age';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGenderDropdown(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Medical info
            _buildSectionTitle('Medical Information'),
            const SizedBox(height: 12),
            _buildAllergiesSection(),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Smoking Status',
              subtitle: 'Patient is a smoker',
              value: _smokingStatus,
              onChanged: (value) => setState(() => _smokingStatus = value),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _medicalHistoryController,
              label: 'Medical History',
              icon: Icons.medical_information,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Notes
            _buildSectionTitle('Additional Notes'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _notesController,
              label: 'Notes',
              icon: Icons.notes,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              image: _profileImage != null
                  ? DecorationImage(
                      image: FileImage(_profileImage!),
                      fit: BoxFit.cover,
                    )
                  : _existingPhotoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_existingPhotoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: _profileImage == null && _existingPhotoUrl == null
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: AppTheme.primaryColor,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: _showImageSourceDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
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

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(
          _selectedGender == Gender.male
              ? Icons.male
              : _selectedGender == Gender.female
                  ? Icons.female
                  : Icons.person,
          color: AppTheme.primaryColor,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: Gender.values.map((gender) {
        return DropdownMenuItem(
          value: gender,
          child: Text(gender.name[0].toUpperCase() + gender.name.substring(1)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedGender = value);
        }
      },
    );
  }

  Widget _buildAllergiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber, color: AppTheme.warningColor),
            const SizedBox(width: 8),
            const Text(
              'Allergies',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allergies.map((allergy) {
            return Chip(
              label: Text(allergy),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() => _allergies.remove(allergy));
              },
              backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
              labelStyle: TextStyle(color: AppTheme.errorColor),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _allergyController,
                decoration: InputDecoration(
                  hintText: 'Add allergy',
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onSubmitted: _addAllergy,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addAllergy(_allergyController.text),
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
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
              if (_profileImage != null || _existingPhotoUrl != null)
                ListTile(
                  leading: Icon(Icons.delete, color: AppTheme.errorColor),
                  title: Text(
                    'Remove Photo',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _profileImage = null;
                      _existingPhotoUrl = null;
                    });
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
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _existingPhotoUrl = null;
      });
    }
  }

  void _addAllergy(String value) {
    if (value.trim().isNotEmpty && !_allergies.contains(value.trim())) {
      setState(() {
        _allergies.add(value.trim());
        _allergyController.clear();
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      final userId = firebaseService.currentUserId!;

      String? photoUrl = _existingPhotoUrl;
      String? photoPath;

      // Upload new photo if selected
      if (_profileImage != null) {
        final patientId = _isEditing ? widget.patient!.id : const Uuid().v4();
        photoUrl = await firebaseService.uploadProfilePhoto(
          patientId,
          _profileImage!.path,
        );
        photoPath = 'users/$userId/patients/$patientId/profile';
      }

      final patient = PatientModel(
        id: _isEditing ? widget.patient!.id : '',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        medicalHistory: _medicalHistoryController.text.trim(),
        allergies: _allergies,
        smokingStatus: _smokingStatus,
        notes: _notesController.text.trim(),
        profilePhotoUrl: photoUrl,
        profilePhotoPath: photoPath,
        createdAt: _isEditing ? widget.patient!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        userId: userId,
      );

      if (_isEditing) {
        await firebaseService.updatePatient(patient);
      } else {
        await firebaseService.createPatient(patient);
      }

      if (mounted) {
        Navigator.of(context).pop(_isEditing ? patient : null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Patient updated successfully' : 'Patient added successfully',
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
