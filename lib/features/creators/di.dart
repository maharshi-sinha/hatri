import 'package:get_it/get_it.dart';

import 'data/datasources/creators_local_data_source.dart';
import 'data/repositories/creator_repository_impl.dart';
import 'domain/repositories/creator_repository.dart';
import 'domain/usecases/get_creators.dart';

void registerCreatorsFeature(GetIt sl) {
  sl.registerLazySingleton<CreatorsLocalDataSource>(
    () => const CreatorsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<CreatorRepository>(
    () => CreatorRepositoryImpl(sl<CreatorsLocalDataSource>()),
  );
  sl.registerLazySingleton(() => GetCreators(sl<CreatorRepository>()));
  sl.registerLazySingleton(() => GetCreatorById(sl<CreatorRepository>()));
}
