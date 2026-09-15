import 'package:get_it/get_it.dart';

import '../../backend/api/auth_api.dart';
import '../../backend/api/events_api.dart';
import '../../backend/api/http_client.dart';
import '../../backend/api/makers_api.dart';
import '../../backend/services/auth_service.dart';
import '../../backend/services/user_service.dart';
import '../../features/communities/bloc/communities_bloc.dart';
import '../../features/events/bloc/events_bloc.dart';
import '../repositories/community_repository.dart';
import '../repositories/creator_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/mock_repository.dart';

final sl = GetIt.instance;

/// Synchronous DI registration. Async init (loading tokens etc.) happens
/// in [bootAuth] which main.dart awaits before runApp.
void init() {
  // ─── Backend plumbing ───
  sl.registerLazySingleton<HttpClient>(() => HttpClient());
  sl.registerLazySingleton<AuthApi>(() => AuthApi(sl<HttpClient>()));
  sl.registerLazySingleton<EventsApi>(() => EventsApi(sl<HttpClient>()));
  sl.registerLazySingleton<MakersApi>(() => MakersApi(sl<HttpClient>()));

  // ─── Services ───
  sl.registerLazySingleton<AuthService>(
    () => AuthService(api: sl<AuthApi>(), http: sl<HttpClient>()),
  );
  sl.registerLazySingleton<UserService>(
    () => UserService(http: sl<HttpClient>(), auth: sl<AuthService>()),
  );

  // ─── Blocs ───
  sl.registerFactory(() => EventsBloc(repository: sl()));
  sl.registerFactory(() => CommunitiesBloc(repository: sl()));

  // ─── Repositories (still mock — replaced with real services in F1c) ───
  sl.registerLazySingleton<EventRepository>(() => MockEventRepository());
  sl.registerLazySingleton<CommunityRepository>(() => MockCommunityRepository());
  sl.registerLazySingleton<CreatorRepository>(() => MockCreatorRepository());
}

/// Loads persisted tokens and, if the access token expired, refreshes it.
/// Call from main() before runApp so the first frame already knows auth state.
Future<void> bootAuth() async {
  await sl<AuthService>().init();
}
