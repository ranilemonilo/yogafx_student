import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/profile_model.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsAppController = TextEditingController();
  final _instagramController = TextEditingController();
  final _countryController = TextEditingController();
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _whatsAppController.dispose();
    _instagramController.dispose();
    _countryController.dispose();
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
                  _buildField(_firstNameController, 'First name'),
                  const SizedBox(height: 14),
                  _buildField(_lastNameController, 'Last name'),
                  const SizedBox(height: 14),
                  _buildField(_emailController, 'Email'),
                  const SizedBox(height: 14),
                  _buildField(_whatsAppController, 'WhatsApp'),
                  const SizedBox(height: 14),
                  _buildField(_instagramController, 'Instagram'),
                  const SizedBox(height: 14),
                  _buildField(_countryController, 'Country'),
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
    _whatsAppController.text = profile.whatsapp ?? '';
    _instagramController.text = profile.instagram ?? '';
    _countryController.text = profile.country ?? '';
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(profileRepositoryProvider).updateProfile({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'whatsapp': _whatsAppController.text.trim(),
        'instagram': _instagramController.text.trim(),
        'country': _countryController.text.trim(),
        'birth_date': _birthDateController.text.trim(),
        'gender': _genderController.text.trim(),
        'practicing_yoga_for': _practicingController.text.trim(),
        'yoga_sequence_experience': _sequenceController.text.trim(),
        'hours_per_week': int.tryParse(_hoursPerWeekController.text.trim()),
        'current_fitness_level': _fitnessLevelController.text.trim(),
        'flexibility_rating': _flexibilityController.text.trim(),
        'motivation': _motivationController.text.trim(),
        'why_yogafx': _whyYogaFxController.text.trim(),
        'how_did_you_find_us': _findUsController.text.trim(),
      });
      ref.invalidate(profileProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
