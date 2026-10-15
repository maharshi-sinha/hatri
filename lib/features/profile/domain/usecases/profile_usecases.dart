import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../../backend/models/auth_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/profile_repository.dart';

/// A small cluster of profile use cases kept in one file for brevity.
/// Each wraps one call on [ProfileRepository].

class FetchMe extends UseCase<ApiUser, NoParams> {
  final ProfileRepository repo;
  const FetchMe(this.repo);
  @override
  Future<Either<Failure, ApiUser>> call(NoParams _) => repo.fetchMe();
}

class UpdateProfile extends UseCase<ApiUser, UpdateProfileParams> {
  final ProfileRepository repo;
  const UpdateProfile(this.repo);
  @override
  Future<Either<Failure, ApiUser>> call(UpdateProfileParams p) =>
      repo.updateProfile(
        displayName: p.displayName,
        dob: p.dob,
        homeCitySlug: p.homeCitySlug,
        currentCitySlug: p.currentCitySlug,
        interests: p.interests,
        bio: p.bio,
        gender: p.gender,
        energy: p.energy,
        pushDailyVibes: p.pushDailyVibes,
      );
}

class UpdateProfileParams extends Equatable {
  final String? displayName;
  final String? dob;
  final String? homeCitySlug;
  final String? currentCitySlug;
  final List<String>? interests;
  final String? bio;
  final String? gender;
  final String? energy;
  final bool? pushDailyVibes;

  const UpdateProfileParams({
    this.displayName,
    this.dob,
    this.homeCitySlug,
    this.currentCitySlug,
    this.interests,
    this.bio,
    this.gender,
    this.energy,
    this.pushDailyVibes,
  });

  @override
  List<Object?> get props => [
        displayName,
        dob,
        homeCitySlug,
        currentCitySlug,
        interests,
        bio,
        gender,
        energy,
        pushDailyVibes,
      ];
}

class DeleteAccount extends UseCase<void, NoParams> {
  final ProfileRepository repo;
  const DeleteAccount(this.repo);
  @override
  Future<Either<Failure, void>> call(NoParams _) => repo.deleteAccount();
}

class UploadAvatar extends UseCase<ApiUser, File> {
  final ProfileRepository repo;
  const UploadAvatar(this.repo);
  @override
  Future<Either<Failure, ApiUser>> call(File file) => repo.uploadAvatar(file);
}
