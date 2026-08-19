class SupportContact {
  final String? whatsapp;
  final String? email;

  const SupportContact({
    required this.whatsapp,
    required this.email,
  });

  factory SupportContact.fromJson(Map<String, dynamic> json) {
    return SupportContact(
      whatsapp: _asNullableString(json['whatsapp']),
      email: _asNullableString(json['email']),
    );
  }

  static String? _asNullableString(dynamic value) {
    final stringValue = value?.toString().trim();
    if (stringValue == null || stringValue.isEmpty || stringValue == 'null') {
      return null;
    }
    return stringValue;
  }
}
