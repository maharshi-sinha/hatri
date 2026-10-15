import 'package:flutter/foundation.dart';

import '../../../../backend/api/api_exception.dart' as api;
import '../../../../backend/models/marquee_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either_x.dart';
import '../../domain/repositories/marquee_repository.dart';
import '../datasources/marquee_remote_data_source.dart';

class MarqueeRepositoryImpl implements MarqueeRepository {
  final MarqueeRemoteDataSource _remote;
  const MarqueeRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<ApiMarqueeItem>>> list({String? city}) async {
    try {
      return Right(await _remote.list(city: city));
    } on api.UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on api.NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on api.ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on api.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e, s) {
      debugPrint('MarqueeRepositoryImpl: unexpected $e\n$s');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
