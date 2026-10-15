import 'package:get_it/get_it.dart';

import '../../backend/api/auth_api.dart';
import '../../backend/services/auth_service.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/request_otp.dart';
import 'domain/usecases/sign_in_with_msg91.dart';
import 'domain/usecases/sign_out.dart';
import 'domain/usecases/update_cached_user.dart';
import 'domain/usecases/verify_otp.dart';

/// Registers the clean-arch Auth graph alongside the existing AuthService
/// binding. AuthService itself stays alive and keeps owning the JWT
/// lifecycle, HttpClient wiring, secure-storage persistence, and the
/// reactive ValueNotifier<AuthState> that the UI reads.
void registerAuthFeature(GetIt sl) {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<AuthApi>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthService>()),
  );
  sl.registerLazySingleton(() => RequestOtp(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyOtp(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInWithMsg91(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOut(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UpdateCachedUser(sl<AuthRepository>()));
}
