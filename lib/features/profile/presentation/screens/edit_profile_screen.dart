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

  // Design System Colors Configuration
  static const Color _bgColor = Color(0xFF060908); // Neutral / Black
  static const Color _appBarColor = Color(0xFF141110); // Neutral / Black (Header)
  static const Color _primaryRed = Color(0xFFDB202C); // Primary / Red
  static const Color _textMain = Color(0xFFFFFFFF); // Neutral / White
  static const Color _textSecondary = Color(0xA6FFFFFF); // Transparent White 65%
  static const Color _inputBg = Color(0x1AFFFFFF); // Transparent White 10%
  static const Color _inputBorder = Color(0x4DFFFFFF); // Transparent White 30%
  static const Color _btnSecondaryBg = Color(0x33FFFFFF); // Transparent White 20%

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
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _appBarColor,
        iconTheme: const IconThemeData(color: _textMain),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: _textMain,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600, // Semi Bold / Title 1 equivalent
            fontSize: 20,
          ),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primaryRed),
        ),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: const TextStyle(
              color: _textSecondary,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        data: (profile) {
          _init(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // 4% horizontal equivalent
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfilePhotoSection(profile),
                  const SizedBox(height: 32),
                  _buildField(_firstNameController, 'First name'),
                  const SizedBox(height: 16), // Adjusted to 16px grid logic
                  _buildField(_lastNameController, 'Last name'),
                  const SizedBox(height: 16),
                  _buildField(_emailController, 'Email'),
                  const SizedBox(height: 16),
                  _buildWhatsAppField(),
                  const SizedBox(height: 16),
                  _buildField(_instagramController, 'Instagram'),
                  const SizedBox(height: 16),
                  Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: _inputDecorationTheme(),
                    ),
                    child: CountryPickerField(
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
                  ),
                  const SizedBox(height: 16),
                  _buildField(_birthDateController, 'Birth date'),
                  const SizedBox(height: 16),
                  _buildField(_genderController, 'Gender'),
                  const SizedBox(height: 16),
                  _buildField(_practicingController, 'Practicing yoga for'),
                  const SizedBox(height: 16),
                  _buildField(
                    _sequenceController,
                    'Yoga sequence experience',
                  ),
                  const SizedBox(height: 16),
                  _buildField(_hoursPerWeekController, 'Hours per week'),
                  const SizedBox(height: 16),
                  _buildField(_fitnessLevelController, 'Current fitness level'),
                  const SizedBox(height: 16),
                  _buildField(_flexibilityController, 'Flexibility rating'),
                  const SizedBox(height: 16),
                  _buildField(_motivationController, 'Motivation', maxLines: 3),
                  const SizedBox(height: 16),
                  _buildField(_whyYogaFxController, 'Why YogaFX', maxLines: 3),
                  const SizedBox(height: 16),
                  _buildField(_findUsController, 'How did you find us',
                      maxLines: 3),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: _primaryRed,
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryRed,
                      foregroundColor: _textMain,
                      disabledBackgroundColor: _primaryRed.withOpacity(0.5),
                      disabledForegroundColor: _textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      minimumSize: const Size(double.infinity, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700, // Bold
                      ),
                    ),
                    child: Text(_saving ? 'Saving...' : 'Save Profile'),
                  ),
                  const SizedBox(height: 24),
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
    _hoursPerWeekController.text = profile.hoursPerWeek ?? '';
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
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _inputBorder, width: 1),
          ),
          child: CircleAvatar(
            radius: 42,
            backgroundColor: const Color(0xFF1A1A1A),
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Text(
              _initials(profile.name),
              style: const TextStyle(
                color: _textMain,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                fontSize: 24,
              ),
            )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _saving ? null : _pickProfilePhoto,
          style: TextButton.styleFrom(
            backgroundColor: _btnSecondaryBg,
            foregroundColor: _textMain,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(0, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700, // Bold
            ),
          ),
          child: const Text('Change Profile Photo'),
        ),
        const SizedBox(height: 8),
        const Text(
          'JPG atau JPEG, maksimal 5 MB.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 12,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Helper untuk Input Decoration general
  InputDecoration _customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(
        color: _textSecondary,
        fontSize: 16,
        fontFamily: 'Montserrat',
      ),
      floatingLabelStyle: const TextStyle(
        color: _textSecondary,
        fontSize: 12,
        fontFamily: 'Montserrat',
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: _inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: _textMain),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: _primaryRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: _primaryRed),
      ),
      errorStyle: const TextStyle(
        color: _primaryRed,
        fontSize: 12,
        fontFamily: 'Montserrat',
      ),
    );
  }

  // Theme support untuk widget custom / internal picker jika diperlukan
  InputDecorationTheme _inputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: _inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(
        color: _textSecondary,
        fontSize: 16,
        fontFamily: 'Montserrat',
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: _inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: _textMain),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: _primaryRed),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: _textMain,
        fontSize: 16,
        fontFamily: 'Montserrat',
      ),
      decoration: _customInputDecoration(label),
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
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: _inputDecorationTheme(),
            ),
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
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 7,
          child: TextFormField(
            controller: _whatsAppNumberController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              color: _textMain,
              fontSize: 16,
              fontFamily: 'Montserrat',
            ),
            decoration: _customInputDecoration('WhatsApp Number'),
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
          'hours_per_week': _hoursPerWeekController.text.trim(),
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