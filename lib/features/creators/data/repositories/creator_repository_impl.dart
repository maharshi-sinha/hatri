import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/either_x.dart';
import '../../domain/repositories/creator_repository.dart';
import '../datasources/creators_local_data_source.dart';

class CreatorRepositoryImpl implements CreatorRepository {
  final CreatorsLocalDataSource _local;
  const CreatorRepositoryImpl(this._local);

  @override
  Future<Either<Failure, List<CreatorProfile>>> getCreators() =>
      _guard(_local.getCreators);

  @override
  Future<Either<Failure, CreatorProfile?>> getById(String id) =>
      _guard(() => _local.getById(id));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() op) async {
    try {
      return Right(await op());
    } catch (e, s) {
      debugPrint('CreatorRepositoryImpl: unexpected $e\n$s');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
