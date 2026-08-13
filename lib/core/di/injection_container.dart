import 'package:get_it/get_it.dart';
import '../../features/events/bloc/events_bloc.dart';
import '../../features/communities/bloc/communities_bloc.dart';
import '../repositories/event_repository.dart';
import '../repositories/community_repository.dart';
import '../repositories/creator_repository.dart';
import '../repositories/mock_repository.dart';

final sl = GetIt.instance;

void init() {
  // Blocs
  sl.registerFactory(() => EventsBloc(repository: sl()));
  sl.registerFactory(() => CommunitiesBloc(repository: sl()));

  // Repositories
  sl.registerLazySingleton<EventRepository>(() => MockEventRepository());
  sl.registerLazySingleton<CommunityRepository>(() => MockCommunityRepository());
  sl.registerLazySingleton<CreatorRepository>(() => MockCreatorRepository());
}
