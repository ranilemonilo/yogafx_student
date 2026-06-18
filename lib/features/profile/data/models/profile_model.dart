import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/data/models/auth_user.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class ProfileData with _$ProfileData {
  const factory ProfileData({
    required int id,
    required String name,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    required String email,
    String? whatsapp,
    String? instagram,
    String? country,
    @JsonKey(name: 'birth_date') String? birthDate,
    String? gender,
    @JsonKey(name: 'practicing_yoga_for') String? practicingYogaFor,
    @JsonKey(name: 'yoga_sequence_experience') String? yogaSequenceExperience,
    @JsonKey(name: 'hours_per_week') int? hoursPerWeek,
    @JsonKey(name: 'current_fitness_level') String? currentFitnessLevel,
    @JsonKey(name: 'flexibility_rating') String? flexibilityRating,
    String? motivation,
    @JsonKey(name: 'why_yogafx') String? whyYogafx,
    @JsonKey(name: 'how_did_you_find_us') String? howDidYouFindUs,
    @JsonKey(name: 'profile_photo') String? profilePhoto,
    @JsonKey(name: 'profile_completed') required bool profileCompleted,
    @JsonKey(name: 'access_tier') required AccessTier accessTier,
  }) = _ProfileData;

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);
}