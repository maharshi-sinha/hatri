import 'package:get_it/get_it.dart';

import '../../backend/services/events_service.dart';
import 'data/datasources/events_remote_data_source.dart';
import 'data/repositories/event_repository_impl.dart';
import 'domain/repositories/event_repository.dart' as domain;
import 'domain/usecases/create_event.dart';
import 'domain/usecases/get_event_by_id.dart';
import 'domain/usecases/get_event_by_slug.dart';
import 'domain/usecases/get_events.dart';
import 'domain/usecases/react_to_event.dart';
import 'domain/usecases/save_event.dart';
import 'domain/usecases/search_events.dart';
import 'domain/usecases/share_event.dart';
import 'domain/usecases/upload_event_cover.dart';

/// Registers the clean-arch Events graph alongside the existing legacy
/// bindings. Nothing here replaces an existing registration. Call once
/// from the root DI container.
///
/// The old `EventRepository` interface in `core/repositories/` and its
/// `BackendEventRepository` impl keep running every current feature. The
/// NEW `domain.EventRepository` (fpdart Either-returning) is bound here
/// so later PRs can swap one call site at a time to it.
void registerEventsFeature(GetIt sl) {
  // ─── Data layer ───
  sl.registerLazySingleton<EventsRemoteDataSource>(
    () => EventsRemoteDataSourceImpl(sl<EventsService>()),
  );

  // ─── Domain repository (clean-arch, fpdart Either-returning) ───
  sl.registerLazySingleton<domain.EventRepository>(
    () => EventRepositoryImpl(sl<EventsRemoteDataSource>()),
  );

  // ─── Use cases ───
  sl.registerLazySingleton(() => GetEvents(sl<domain.EventRepository>()));
  sl.registerLazySingleton(() => GetEventById(sl<domain.EventRepository>()));
  sl.registerLazySingleton(() => GetEventBySlug(sl<domain.EventRepository>()));
  sl.registerLazySingleton(() => SearchEvents(sl<domain.EventRepository>()));
  sl.registerLazySingleton(() => SaveEvent(sl<domain.EventRepository>()));
  sl.registerLazySingleton(() => UnsaveEvent(sl<domain.EventRepository>()));
  sl.registerLazySingleton(() => ReactToEvent(sl<domain.EventRepository>()));
  sl.registerLazySingleton(() => ShareEvent(sl<domain.EventRepository>()));
  sl.registerLazySingleton(() => UploadEventCover(sl<domain.EventRepository>()));
  sl.registerLazySingleton(() => CreateEvent(sl<domain.EventRepository>()));
}
