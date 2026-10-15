import 'package:get_it/get_it.dart';

import '../../backend/services/avatar_upload_service.dart';
import '../../backend/services/user_service.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/profile_usecases.dart';

void registerProfileFeature(GetIt sl) {
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      users: sl<UserService>(),
      avatars: sl<AvatarUploadService>(),
    ),
  );
  sl.registerLazySingleton(() => FetchMe(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UpdateProfile(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => DeleteAccount(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UploadAvatar(sl<ProfileRepository>()));
}
