import 'package:get_it/get_it.dart';

import '../../backend/api/makers_api.dart';
import 'data/datasources/makers_remote_data_source.dart';
import 'data/repositories/maker_repository_impl.dart';
import 'domain/repositories/maker_repository.dart';
import 'domain/usecases/follow_maker.dart';
import 'domain/usecases/get_makers.dart';

void registerMakersFeature(GetIt sl) {
  sl.registerLazySingleton<MakersRemoteDataSource>(
    () => MakersRemoteDataSourceImpl(sl<MakersApi>()),
  );
  sl.registerLazySingleton<MakerRepository>(
    () => MakerRepositoryImpl(sl<MakersRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetMakers(sl<MakerRepository>()));
  sl.registerLazySingleton(() => GetMakerById(sl<MakerRepository>()));
  sl.registerLazySingleton(() => FollowMaker(sl<MakerRepository>()));
  sl.registerLazySingleton(() => UnfollowMaker(sl<MakerRepository>()));
}
