import 'package:get_it/get_it.dart';

import '../../backend/api/auth_api.dart';
import '../../backend/api/events_api.dart';
import '../../backend/api/http_client.dart';
import '../../backend/api/makers_api.dart';
import '../../backend/api/tickets_api.dart';
import '../../backend/services/auth_service.dart';
import '../../backend/services/avatar_upload_service.dart';
import '../../backend/services/events_service.dart';
import '../../backend/services/msg91_widget_service.dart';
import '../../backend/services/tickets_service.dart';
import '../../backend/services/user_service.dart';
import '../../features/communities/bloc/communities_bloc.dart';
import '../../features/events/bloc/events_bloc.dart';
import '../analytics/analytics_service.dart';
import '../notifications/notifications_service.dart';
import '../repositories/backend_event_repository.dart';
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
  sl.registerLazySingleton<TicketsApi>(() => TicketsApi(sl<HttpClient>()));

  // ─── Services ───
  sl.registerLazySingleton<AuthService>(
    () => AuthService(api: sl<AuthApi>(), http: sl<HttpClient>()),
  );
  sl.registerLazySingleton<UserService>(
    () => UserService(http: sl<HttpClient>(), auth: sl<AuthService>()),
  );
  sl.registerLazySingleton<AvatarUploadService>(
    () => AvatarUploadService(http: sl<HttpClient>(), auth: sl<AuthService>()),
  );
  sl.registerLazySingleton<EventsService>(
    () => EventsService(api: sl<EventsApi>()),
  );
  sl.registerLazySingleton<TicketsService>(
    () => TicketsService(api: sl<TicketsApi>()),
  );
  sl.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  sl.registerLazySingleton<NotificationsService>(() => NotificationsService());
  // MSG91 widget credentials are client-side identifiers (ship with the app,
  // like Firebase API keys). The server-side AUTH_KEY stays in Render env.
  sl.registerLazySingleton<Msg91WidgetService>(
    () => Msg91WidgetService(
      widgetId: '36696b66736e353530313738',
      tokenAuth: '569729TwfRkhlzvnH6aa39cc9P1',
    ),
  );

  // ─── Blocs ───
  sl.registerFactory(() => EventsBloc(repository: sl()));
  sl.registerFactory(() => CommunitiesBloc(repository: sl()));

  // ─── Repositories ───
  // Events: real backend, with tiered fallback (API → cache → mock).
  sl.registerLazySingleton<EventRepository>(
    () => BackendEventRepository(events: sl<EventsService>()),
  );
  // Communities + creators: still mock for now. Backend endpoints not built.
  sl.registerLazySingleton<CommunityRepository>(() => MockCommunityRepository());
  sl.registerLazySingleton<CreatorRepository>(() => MockCreatorRepository());
}

/// Loads persisted tokens and, if the access token expired, refreshes it.
/// Call from main() before runApp so the first frame already knows auth state.
Future<void> bootAuth() async {
  await sl<AuthService>().init();
}
