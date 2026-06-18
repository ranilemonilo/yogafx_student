// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileDataImpl _$$ProfileDataImplFromJson(Map<String, dynamic> json) =>
    _$ProfileDataImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      whatsapp: json['whatsapp'] as String?,
      instagram: json['instagram'] as String?,
      country: json['country'] as String?,
      birthDate: json['birth_date'] as String?,
      gender: json['gender'] as String?,
      practicingYogaFor: json['practicing_yoga_for'] as String?,
      yogaSequenceExperience: json['yoga_sequence_experience'] as String?,
      hoursPerWeek: (json['hours_per_week'] as num?)?.toInt(),
      currentFitnessLevel: json['current_fitness_level'] as String?,
      flexibilityRating: json['flexibility_rating'] as String?,
      motivation: json['motivation'] as String?,
      whyYogafx: json['why_yogafx'] as String?,
      howDidYouFindUs: json['how_did_you_find_us'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      profileCompleted: json['profile_completed'] as bool,
      accessTier:
          AccessTier.fromJson(json['access_tier'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProfileDataImplToJson(_$ProfileDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'whatsapp': instance.whatsapp,
      'instagram': instance.instagram,
      'country': instance.country,
      'birth_date': instance.birthDate,
      'gender': instance.gender,
      'practicing_yoga_for': instance.practicingYogaFor,
      'yoga_sequence_experience': instance.yogaSequenceExperience,
      'hours_per_week': instance.hoursPerWeek,
      'current_fitness_level': instance.currentFitnessLevel,
      'flexibility_rating': instance.flexibilityRating,
      'motivation': instance.motivation,
      'why_yogafx': instance.whyYogafx,
      'how_did_you_find_us': instance.howDidYouFindUs,
      'profile_photo': instance.profilePhoto,
      'profile_completed': instance.profileCompleted,
      'access_tier': instance.accessTier,
    };
