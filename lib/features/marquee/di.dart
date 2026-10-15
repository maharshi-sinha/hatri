import 'package:get_it/get_it.dart';

import '../../backend/api/http_client.dart';
import '../../backend/api/marquee_api.dart';
import 'data/datasources/marquee_remote_data_source.dart';
import 'data/repositories/marquee_repository_impl.dart';
import 'domain/repositories/marquee_repository.dart';
import 'domain/usecases/get_marquee.dart';

void registerMarqueeFeature(GetIt sl) {
  sl.registerLazySingleton<MarqueeApi>(() => MarqueeApi(sl<HttpClient>()));
  sl.registerLazySingleton<MarqueeRemoteDataSource>(
    () => MarqueeRemoteDataSourceImpl(sl<MarqueeApi>()),
  );
  sl.registerLazySingleton<MarqueeRepository>(
    () => MarqueeRepositoryImpl(sl<MarqueeRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetMarquee(sl<MarqueeRepository>()));
}
