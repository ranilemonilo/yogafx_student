import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/country_options.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_network_image.dart';
import '../../../../core/widgets/country_picker_field.dart';
import '../../data/models/profile_model.dart';
import '../providers/profile_provider.dart';

class _ProfileChoiceOption {
  final String value;
  final String label;

  const _ProfileChoiceOption({
    required this.value,
    required this.label,
  });
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static const int _maxProfilePhotoBytes = 5 * 1024 * 1024;
  static const List<_ProfileChoiceOption> _genderOptions = [
    _ProfileChoiceOption(value: 'male', label: 'Male'),
    _ProfileChoiceOption(value: 'female', label: 'Female'),
  ];
  static const List<_ProfileChoiceOption> _practicingYogaOptions = [
    _ProfileChoiceOption(value: 'beginner', label: 'Beginner'),
    _ProfileChoiceOption(value: '0_to_3_years', label: '0 to 3 years'),
    _ProfileChoiceOption(value: '4_to_6_years', label: '4 to 6 years'),
    _ProfileChoiceOption(value: '6_plus_years', label: '6+ years'),
  ];
  static const List<_ProfileChoiceOption> _hoursPerWeekOptions = [
    _ProfileChoiceOption(value: '0_3', label: '0-3'),
    _ProfileChoiceOption(value: '4_7', label: '4-7'),
    _ProfileChoiceOption(value: '7_10', label: '7-10'),
    _ProfileChoiceOption(value: '10_plus', label: '10+'),
  ];
  static const List<_ProfileChoiceOption> _fitnessLevelOptions = [
    _ProfileChoiceOption(value: 'poor', label: 'Poor'),
    _ProfileChoiceOption(value: 'average', label: 'Average'),
    _ProfileChoiceOption(value: 'good', label: 'Good'),
  ];
  static const List<_ProfileChoiceOption> _flexibilityOptions = [
    _ProfileChoiceOption(value: 'poor', label: 'Poor'),
    _ProfileChoiceOption(value: 'average', label: 'Average'),
    _ProfileChoiceOption(value: 'good', label: 'Good'),
  ];

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
  final Map<String, String> _fieldErrors = {};
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
      body: profileAsync.when(
        loading: () => const _EditProfileLoadingState(),
        error: (e, _) => _EditProfileErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (profile) {
          _init(profile);
          return _buildContent(context, profile);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProfileData profile) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          floating: true,
          snap: true,
          elevation: 0,
          titleSpacing: 4,
          leading: IconButton(
            onPressed: _saving ? null : () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              letterSpacing: 0.2,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileEditHero(
                    profile: profile,
                    selectedProfilePhoto: _selectedProfilePhoto,
                    saving: _saving,
                    onChangePhoto: _pickProfilePhoto,
                  ),
                  const SizedBox(height: 28),
                  _EditSectionCard(
                    title: 'Account',
                    icon: Icons.person_outline_rounded,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                _firstNameController,
                                'First name',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                _lastNameController,
                                'Last name',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildField(_emailController, 'Email'),
                        const SizedBox(height: 14),
                        _buildWhatsAppField(),
                        const SizedBox(height: 14),
                        _buildField(_instagramController, 'Instagram'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _EditSectionCard(
                    title: 'Personal',
                    icon: Icons.badge_outlined,
                    child: Column(
                      children: [
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
                        _buildField(
                          _birthDateController,
                          'Birth date',
                          fieldKey: 'birth_date',
                        ),
                        const SizedBox(height: 14),
                        _buildChoiceField(
                          controller: _genderController,
                          label: 'Gender',
                          fieldKey: 'gender',
                          options: _genderOptions,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _EditSectionCard(
                    title: 'Practice',
                    icon: Icons.self_improvement_outlined,
                    child: Column(
                      children: [
                        _buildChoiceField(
                          controller: _practicingController,
                          label: 'Practicing yoga for',
                          fieldKey: 'practicing_yoga_for',
                          options: _practicingYogaOptions,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          _sequenceController,
                          'Yoga sequence experience',
                          fieldKey: 'yoga_sequence_experience',
                        ),
                        const SizedBox(height: 14),
                        _buildChoiceField(
                          controller: _hoursPerWeekController,
                          label: 'Hours per week',
                          fieldKey: 'hours_per_week',
                          options: _hoursPerWeekOptions,
                        ),
                        const SizedBox(height: 14),
                        _buildChoiceField(
                          controller: _fitnessLevelController,
                          label: 'Current fitness level',
                          fieldKey: 'current_fitness_level',
                          options: _fitnessLevelOptions,
                        ),
                        const SizedBox(height: 14),
                        _buildChoiceField(
                          controller: _flexibilityController,
                          label: 'Flexibility rating',
                          fieldKey: 'flexibility_rating',
                          options: _flexibilityOptions,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _EditSectionCard(
                    title: 'Motivation',
                    icon: Icons.lightbulb_outline_rounded,
                    child: Column(
                      children: [
                        _buildField(
                          _motivationController,
                          'Motivation',
                          maxLines: 4,
                          fieldKey: 'motivation',
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          _whyYogaFxController,
                          'Why YogaFX',
                          maxLines: 4,
                          fieldKey: 'why_yogafx',
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          _findUsController,
                          'How did you find us',
                          maxLines: 4,
                          fieldKey: 'how_did_you_find_us',
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.card),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Cancel',
                          onTap: _saving ? null : () => context.pop(),
                          primary: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          label: _saving ? 'Saving...' : 'Save Profile',
                          onTap: _saving ? null : _save,
                          primary: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

  Widget _buildField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    String? fieldKey,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        errorText: fieldKey == null ? null : _fieldErrors[fieldKey],
      ),
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontFamily: 'Montserrat',
      ),
      validator: (value) {
        if ((label == 'First name' || label == 'Last name' || label == 'Email') &&
            (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        return null;
      },
      onChanged: (_) {
        if (fieldKey != null && _fieldErrors.containsKey(fieldKey)) {
          setState(() => _fieldErrors.remove(fieldKey));
        }
      },
    );
  }

  Widget _buildChoiceField({
    required TextEditingController controller,
    required String label,
    required String fieldKey,
    required List<_ProfileChoiceOption> options,
  }) {
    final normalizedValue = _normalizeChoiceValue(controller.text);
    final selectedValue =
        options.any((option) => option.value == normalizedValue)
            ? normalizedValue
            : null;

    return DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        errorText: _fieldErrors[fieldKey],
      ),
      dropdownColor: AppColors.surfaceElevated,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontFamily: 'Montserrat',
      ),
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option.value,
              child: Text(
                option.label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        controller.text = value ?? '';
        if (_fieldErrors.containsKey(fieldKey)) {
          setState(() => _fieldErrors.remove(fieldKey));
          return;
        }
        setState(() {});
      },
    );
  }

  String _normalizeChoiceValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    return trimmed
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
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
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontFamily: 'Montserrat',
            ),
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
      _fieldErrors.clear();
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
          'gender': _normalizeChoiceValue(_genderController.text),
          'practicing_yoga_for': _practicingController.text.trim(),
          'yoga_sequence_experience': _sequenceController.text.trim(),
          'hours_per_week': _normalizeChoiceValue(_hoursPerWeekController.text),
          'current_fitness_level': _normalizeChoiceValue(
            _fitnessLevelController.text,
          ),
          'flexibility_rating': _normalizeChoiceValue(
            _flexibilityController.text,
          ),
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
      if (e is ValidationException) {
        final fieldErrors = <String, String>{};
        e.errors?.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            fieldErrors[key] = value.first.toString();
          } else if (value != null) {
            fieldErrors[key] = value.toString();
          }
        });
        setState(() {
          _fieldErrors
            ..clear()
            ..addAll(fieldErrors);
          _error = 'Please review the highlighted fields and try again.';
        });
      } else {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _ProfileEditHero extends StatelessWidget {
  final ProfileData profile;
  final File? selectedProfilePhoto;
  final bool saving;
  final VoidCallback onChangePhoto;

  const _ProfileEditHero({
    required this.profile,
    required this.selectedProfilePhoto,
    required this.saving,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionEyebrow(text: 'Update Your Details'),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EditableProfileAvatar(
                profile: profile,
                selectedProfilePhoto: selectedProfilePhoto,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Keep your account information, personal background, and yoga practice details up to date.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      label: 'Change Profile Photo',
                      onTap: saving ? null : onChangePhoto,
                      primary: false,
                      compact: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'JPG atau JPEG, maksimal 5 MB.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableProfileAvatar extends StatelessWidget {
  final ProfileData profile;
  final File? selectedProfilePhoto;

  const _EditableProfileAvatar({
    required this.profile,
    required this.selectedProfilePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = profile.profilePhoto?.trim();
    final hasNetworkImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.avatar),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: selectedProfilePhoto != null
          ? Image.file(selectedProfilePhoto!, fit: BoxFit.cover)
          : hasNetworkImage
              ? AuthNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholderBuilder: (_) =>
                      _AvatarFallback(name: profile.name),
                  errorBuilderWidget: (_, __) =>
                      _AvatarFallback(name: profile.name),
                )
              : _AvatarFallback(name: profile.name),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;

  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _initials(name),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontFamily: 'Montserrat',
          fontSize: 26,
        ),
      ),
    );
  }
}

class _EditSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _EditSectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 15),
                const SizedBox(width: 8),
                Expanded(child: _SectionEyebrow(text: title)),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  final String text;

  const _SectionEyebrow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
              letterSpacing: 1.8,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final bool compact;

  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.primary,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 16,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: primary ? AppColors.primary : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: primary
                ? null
                : Border.all(
                    color: Colors.white.withOpacity(0.16),
                    width: 0.8,
                  ),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditProfileLoadingState extends StatefulWidget {
  const _EditProfileLoadingState();

  @override
  State<_EditProfileLoadingState> createState() =>
      _EditProfileLoadingStateState();
}

class _EditProfileLoadingStateState extends State<_EditProfileLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        final shimmerColor = Color.lerp(
          AppColors.shimmer,
          AppColors.shimmerHighlight,
          _animation.value,
        )!;

        return CustomScrollView(
          slivers: [
            const SliverAppBar(
              backgroundColor: AppColors.background,
              floating: true,
              snap: true,
              title: Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  children: [
                    _bone(
                      width: double.infinity,
                      height: 188,
                      radius: AppRadius.card,
                      color: shimmerColor,
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(
                      4,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _bone(
                          width: double.infinity,
                          height: 220,
                          radius: AppRadius.card,
                          color: shimmerColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _bone({
    required double width,
    required double height,
    required double radius,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _EditProfileErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EditProfileErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.25),
                ),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 148,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ),
          ],
        ),
      ),
    );
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
