import 'package:get_it/get_it.dart';

import 'data/datasources/communities_local_data_source.dart';
import 'data/repositories/community_repository_impl.dart';
import 'domain/repositories/community_repository.dart';
import 'domain/usecases/get_communities.dart';

void registerCommunitiesFeature(GetIt sl) {
  sl.registerLazySingleton<CommunitiesLocalDataSource>(
    () => const CommunitiesLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<CommunityRepository>(
    () => CommunityRepositoryImpl(sl<CommunitiesLocalDataSource>()),
  );
  sl.registerLazySingleton(() => GetCommunities(sl<CommunityRepository>()));
}
