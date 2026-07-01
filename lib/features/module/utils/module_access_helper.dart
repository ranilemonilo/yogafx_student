String resolveModuleAccessStatus(
  String status, {
  bool hasGeneratedCertificate = false,
}) {
  final normalized = status.trim().toLowerCase();

  if (normalized == 'completed') {
    return 'completed';
  }

  return normalized;
}

bool canOpenModuleByStatus(
  String status, {
  bool hasGeneratedCertificate = false,
}) {
  final resolved = resolveModuleAccessStatus(
    status,
    hasGeneratedCertificate: hasGeneratedCertificate,
  );

  return resolved != 'locked' &&
      resolved != 'hidden' &&
      resolved != 'unavailable';
}
