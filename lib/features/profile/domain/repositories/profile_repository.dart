import 'dart:io';

import '../../../../backend/models/auth_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either_x.dart';

/// Clean-arch contract for Profile. Covers the /me surface + avatar
/// upload. Pulls together UserService + AvatarUploadService.
abstract class ProfileRepository {
  /// GET /me. Also refreshes the cached user via AuthService.
  Future<Either<Failure, ApiUser>> fetchMe();

  /// PATCH /me. Only non-null fields are sent.
  Future<Either<Failure, ApiUser>> updateProfile({
    String? displayName,
    String? dob,
    String? homeCitySlug,
    String? currentCitySlug,
    List<String>? interests,
    String? bio,
    String? gender,
    String? energy,
    bool? pushDailyVibes,
  });

  /// DELETE /me. Schedules a 7-day soft-delete and signs the user out.
  Future<Either<Failure, void>> deleteAccount();

  /// Compress + upload avatar. Returns the updated user object (the
  /// backend both uploads to storage and returns the new `avatarUrl`
  /// baked into a fresh ApiUser).
  Future<Either<Failure, ApiUser>> uploadAvatar(File file);
}
