// Shapes of /auth endpoint responses. These are API-layer types; the UI
// converts them into its own domain models where needed.

class ApiUser {
  final String id;
  final String phone;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? gender;
  final String? energy;
  /// ISO date `YYYY-MM-DD`. Backend sends a full ISO datetime; we store just
  /// the date part since onboarding only captures the day.
  final String? dob;
  final List<String> interests;
  final List<String> roles;
  /// Mood pings only (morning + evening + birthday). Essential notifications
  /// like ticket confirmed and event reminders fire regardless.
  final bool pushDailyVibes;

  const ApiUser({
    required this.id,
    required this.phone,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.gender,
    required this.energy,
    required this.dob,
    required this.interests,
    required this.roles,
    required this.pushDailyVibes,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) => ApiUser(
        id: json['id'] as String,
        phone: json['phone'] as String,
        displayName: json['displayName'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        bio: json['bio'] as String?,
        gender: json['gender'] as String?,
        energy: json['energy'] as String?,
        dob: (json['dob'] as String?)?.split('T').first,
        interests: (json['interests'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
        roles: (json['roles'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
        pushDailyVibes: json['pushDailyVibes'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'bio': bio,
        'gender': gender,
        'energy': energy,
        'dob': dob,
        'interests': interests,
        'roles': roles,
        'pushDailyVibes': pushDailyVibes,
      };
}

class OtpRequestResult {
  final bool ok;
  final int expiresIn;

  const OtpRequestResult({required this.ok, required this.expiresIn});

  factory OtpRequestResult.fromJson(Map<String, dynamic> json) =>
      OtpRequestResult(
        ok: json['ok'] as bool? ?? false,
        expiresIn: json['expiresIn'] as int? ?? 300,
      );
}

class OtpVerifyResult {
  final String accessToken;
  final String refreshToken;
  final ApiUser user;

  const OtpVerifyResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory OtpVerifyResult.fromJson(Map<String, dynamic> json) =>
      OtpVerifyResult(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        user: ApiUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class RefreshResult {
  final String accessToken;
  final String refreshToken;

  const RefreshResult({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshResult.fromJson(Map<String, dynamic> json) => RefreshResult(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}
