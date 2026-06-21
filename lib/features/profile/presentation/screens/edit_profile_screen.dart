import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/country_options.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/country_picker_field.dart';
import '../../data/models/profile_model.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static const int _maxProfilePhotoBytes = 5 * 1024 * 1024;

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsAppNumberController = TextEditingController();
  final _instagramController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _genderController = TextEditingController();
  final _practicingController = TextEditingController();
  final _sequenceController = TextEditingController();
  final _hoursPerWeekController = TextEditingController();
  final _fitnessLevelController = TextEditingController();
  final _flexibilityController = TextEditingController();
  final _motivationController = TextEditingController();
  final _whyYogaFxController = TextEditingController();
  final _findUsController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  String? _error;
  CountryOption? _selectedCountry;
  CountryOption? _selectedDialCountry;
  File? _selectedProfilePhoto;
  String? _selectedProfilePhotoName;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _whatsAppNumberController.dispose();
    _instagramController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _practicingController.dispose();
    _sequenceController.dispose();
    _hoursPerWeekController.dispose();
    _fitnessLevelController.dispose();
    _flexibilityController.dispose();
    _motivationController.dispose();
    _whyYogaFxController.dispose();
    _findUsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (profile) {
          _init(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfilePhotoSection(profile),
                  const SizedBox(height: 20),
                  _buildField(_firstNameController, 'First name'),
                  const SizedBox(height: 14),
                  _buildField(_lastNameController, 'Last name'),
                  const SizedBox(height: 14),
                  _buildField(_emailController, 'Email'),
                  const SizedBox(height: 14),
                  _buildWhatsAppField(),
                  const SizedBox(height: 14),
                  _buildField(_instagramController, 'Instagram'),
                  const SizedBox(height: 14),
                  CountryPickerField(
                    label: 'Country',
                    hintText: 'Select a country',
                    selectedOption: _selectedCountry,
                    onSelected: (option) {
                      setState(() {
                        _selectedCountry = option;
                        _selectedDialCountry = option;
                      });
                    },
                    validator: (value) {
                      if (_selectedCountry == null) {
                        return 'Country is required';
                      }
                      return null;
                    },
                    labelBuilder: (option) => option.name,
                  ),
                  const SizedBox(height: 14),
                  _buildField(_birthDateController, 'Birth date'),
                  const SizedBox(height: 14),
                  _buildField(_genderController, 'Gender'),
                  const SizedBox(height: 14),
                  _buildField(_practicingController, 'Practicing yoga for'),
                  const SizedBox(height: 14),
                  _buildField(
                    _sequenceController,
                    'Yoga sequence experience',
                  ),
                  const SizedBox(height: 14),
                  _buildField(_hoursPerWeekController, 'Hours per week'),
                  const SizedBox(height: 14),
                  _buildField(_fitnessLevelController, 'Current fitness level'),
                  const SizedBox(height: 14),
                  _buildField(_flexibilityController, 'Flexibility rating'),
                  const SizedBox(height: 14),
                  _buildField(_motivationController, 'Motivation', maxLines: 3),
                  const SizedBox(height: 14),
                  _buildField(_whyYogaFxController, 'Why YogaFX', maxLines: 3),
                  const SizedBox(height: 14),
                  _buildField(_findUsController, 'How did you find us',
                      maxLines: 3),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Saving...' : 'Save Profile'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _init(ProfileData profile) {
    if (_initialized) return;
    _initialized = true;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _emailController.text = profile.email;
    final phoneData = splitPhoneNumber(profile.whatsapp);
    _selectedDialCountry = phoneData.country;
    _whatsAppNumberController.text = phoneData.localNumber;
    _instagramController.text = profile.instagram ?? '';
    _selectedCountry = findCountryByName(profile.country);
    _selectedDialCountry ??= _selectedCountry;
    _birthDateController.text = profile.birthDate ?? '';
    _genderController.text = profile.gender ?? '';
    _practicingController.text = profile.practicingYogaFor ?? '';
    _sequenceController.text = profile.yogaSequenceExperience ?? '';
    _hoursPerWeekController.text = profile.hoursPerWeek?.toString() ?? '';
    _fitnessLevelController.text = profile.currentFitnessLevel ?? '';
    _flexibilityController.text = profile.flexibilityRating ?? '';
    _motivationController.text = profile.motivation ?? '';
    _whyYogaFxController.text = profile.whyYogafx ?? '';
    _findUsController.text = profile.howDidYouFindUs ?? '';
  }

  Widget _buildProfilePhotoSection(ProfileData profile) {
    ImageProvider? imageProvider;
    if (_selectedProfilePhoto != null) {
      imageProvider = FileImage(_selectedProfilePhoto!);
    } else if (profile.profilePhoto != null &&
        profile.profilePhoto!.isNotEmpty) {
      imageProvider = NetworkImage(profile.profilePhoto!);
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: AppColors.surfaceElevated,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Text(
                  _initials(profile.name),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    fontSize: 24,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _saving ? null : _pickProfilePhoto,
          child: const Text('Change Profile Photo'),
        ),
        const SizedBox(height: 6),
        const Text(
          'JPG atau JPEG, maksimal 5 MB.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if ((label == 'First name' ||
                label == 'Last name' ||
                label == 'Email') &&
            (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildWhatsAppField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: CountryPickerField(
            label: 'Code',
            hintText: 'Choose code',
            selectedOption: _selectedDialCountry,
            onSelected: (option) {
              setState(() => _selectedDialCountry = option);
            },
            labelBuilder: (option) => '${option.dialCode} ${option.name}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 7,
          child: TextFormField(
            controller: _whatsAppNumberController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'WhatsApp Number'),
          ),
        ),
      ],
    );
  }

  Future<void> _pickProfilePhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg'],
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final path = file.path;
    final name = file.name;
    final size = file.size;
    final lowerName = name.toLowerCase();

    if (path == null) {
      setState(() => _error = 'Failed to read the selected image.');
      return;
    }

    if (!(lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg'))) {
      setState(() => _error = 'Profile photo must be a JPG or JPEG image.');
      return;
    }

    if (size > _maxProfilePhotoBytes) {
      setState(() => _error = 'Profile photo must be 5 MB or smaller.');
      return;
    }

    setState(() {
      _selectedProfilePhoto = File(path);
      _selectedProfilePhotoName = name;
      _error = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
        {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'whatsapp_country_code': _selectedDialCountry?.dialCode ?? '',
          'whatsapp_number': _whatsAppNumberController.text.trim(),
          'instagram': _instagramController.text.trim(),
          'country': _selectedCountry?.name ?? '',
          'birth_date': _birthDateController.text.trim(),
          'gender': _genderController.text.trim(),
          'practicing_yoga_for': _practicingController.text.trim(),
          'yoga_sequence_experience': _sequenceController.text.trim(),
          'hours_per_week': int.tryParse(_hoursPerWeekController.text.trim()) ?? '',
          'current_fitness_level': _fitnessLevelController.text.trim(),
          'flexibility_rating': _flexibilityController.text.trim(),
          'motivation': _motivationController.text.trim(),
          'why_yogafx': _whyYogaFxController.text.trim(),
          'how_did_you_find_us': _findUsController.text.trim(),
        },
        profilePhotoPath: _selectedProfilePhoto?.path,
        profilePhotoFileName: _selectedProfilePhotoName,
      );
      ref.invalidate(profileProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'Y';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
