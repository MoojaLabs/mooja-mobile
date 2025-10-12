import 'dart:convert';

/// Model for pending organization verification data
/// Represents data collected across multiple screens during org verification flow
class PendingOrgData {
  final String? orgName;
  final String? country;
  final String? socialPlatform;
  final String? socialHandle;
  final String? orgUsername; // Backend-generated
  final String? applicationId; // Backend-generated

  const PendingOrgData({
    this.orgName,
    this.country,
    this.socialPlatform,
    this.socialHandle,
    this.orgUsername,
    this.applicationId,
  });

  /// Create a copy with updated fields
  PendingOrgData copyWith({
    String? orgName,
    String? country,
    String? socialPlatform,
    String? socialHandle,
    String? orgUsername,
    String? applicationId,
  }) {
    return PendingOrgData(
      orgName: orgName ?? this.orgName,
      country: country ?? this.country,
      socialPlatform: socialPlatform ?? this.socialPlatform,
      socialHandle: socialHandle ?? this.socialHandle,
      orgUsername: orgUsername ?? this.orgUsername,
      applicationId: applicationId ?? this.applicationId,
    );
  }

  /// Check if all user-input fields are complete
  bool get isComplete =>
      orgName != null &&
      country != null &&
      socialPlatform != null &&
      socialHandle != null;

  /// Check if application is ready for final submission
  bool get isReadyForSubmission =>
      isComplete && orgUsername != null && applicationId != null;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'orgName': orgName,
      'country': country,
      'socialPlatform': socialPlatform,
      'socialHandle': socialHandle,
      'orgUsername': orgUsername,
      'applicationId': applicationId,
    };
  }

  /// Create from JSON
  factory PendingOrgData.fromJson(Map<String, dynamic> json) {
    return PendingOrgData(
      orgName: json['orgName'] as String?,
      country: json['country'] as String?,
      socialPlatform: json['socialPlatform'] as String?,
      socialHandle: json['socialHandle'] as String?,
      orgUsername: json['orgUsername'] as String?,
      applicationId: json['applicationId'] as String?,
    );
  }

  /// Create from JSON string
  factory PendingOrgData.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return PendingOrgData.fromJson(json);
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() {
    return 'PendingOrgData('
        'orgName: $orgName, '
        'country: $country, '
        'socialPlatform: $socialPlatform, '
        'socialHandle: $socialHandle, '
        'orgUsername: $orgUsername, '
        'applicationId: $applicationId)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingOrgData &&
          runtimeType == other.runtimeType &&
          orgName == other.orgName &&
          country == other.country &&
          socialPlatform == other.socialPlatform &&
          socialHandle == other.socialHandle &&
          orgUsername == other.orgUsername &&
          applicationId == other.applicationId;

  @override
  int get hashCode =>
      orgName.hashCode ^
      country.hashCode ^
      socialPlatform.hashCode ^
      socialHandle.hashCode ^
      orgUsername.hashCode ^
      applicationId.hashCode;
}
