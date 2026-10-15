import 'package:flutter/foundation.dart';

import '../../../../backend/api/api_exception.dart' as api;
import '../../../../backend/models/maker_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either_x.dart';
import '../../domain/repositories/maker_repository.dart';
import '../datasources/makers_remote_data_source.dart';

class MakerRepositoryImpl implements MakerRepository {
  final MakersRemoteDataSource _remote;
  const MakerRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, ApiMakerFeed>> list({
    String? citySlug,
    String? category,
    String? cursor,
    String? q,
    int limit = 20,
  }) =>
      _guard(() => _remote.list(
            citySlug: citySlug,
            category: category,
            cursor: cursor,
            q: q,
            limit: limit,
          ));

  @override
  Future<Either<Failure, ApiMakerDetail>> getById(String id) =>
      _guard(() => _remote.getById(id));

  @override
  Future<Either<Failure, FollowResult>> follow(String id) =>
      _guard(() => _remote.follow(id));

  @override
  Future<Either<Failure, FollowResult>> unfollow(String id) =>
      _guard(() => _remote.unfollow(id));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() op) async {
    try {
      return Right(await op());
    } on api.UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on api.NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on api.ClientException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 422) {
        return Left(ValidationFailure(e.message));
      }
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on api.ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on api.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e, s) {
      debugPrint('MakerRepositoryImpl: unexpected $e\n$s');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
