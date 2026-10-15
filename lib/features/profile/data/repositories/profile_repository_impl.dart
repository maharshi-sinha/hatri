import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../backend/api/api_exception.dart' as api;
import '../../../../backend/models/auth_models.dart';
import '../../../../backend/services/avatar_upload_service.dart';
import '../../../../backend/services/user_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either_x.dart';
import '../../domain/repositories/profile_repository.dart';

/// Wraps UserService + AvatarUploadService. Keeps the AuthService
/// side-effects (cached user sync, sign-out on delete) intact.
class ProfileRepositoryImpl implements ProfileRepository {
  final UserService _users;
  final AvatarUploadService _avatars;
  const ProfileRepositoryImpl({
    required UserService users,
    required AvatarUploadService avatars,
  })  : _users = users,
        _avatars = avatars;

  @override
  Future<Either<Failure, ApiUser>> fetchMe() => _guard(_users.fetchMe);

  @override
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
  }) =>
      _guard(() => _users.updateProfile(
            displayName: displayName,
            dob: dob,
            homeCitySlug: homeCitySlug,
            currentCitySlug: currentCitySlug,
            interests: interests,
            bio: bio,
            gender: gender,
            energy: energy,
            pushDailyVibes: pushDailyVibes,
          ));

  @override
  Future<Either<Failure, void>> deleteAccount() =>
      _guard(_users.deleteAccount);

  @override
  Future<Either<Failure, ApiUser>> uploadAvatar(File file) =>
      _guard(() => _avatars.uploadAvatar(file));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() op) async {
    try {
      return Right(await op());
    } on api.UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on api.NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on api.ClientException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 422) {
        return Left(ValidationFailure(e.message));
      }
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on api.ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on api.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e, s) {
      debugPrint('ProfileRepositoryImpl: unexpected $e\n$s');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
