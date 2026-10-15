import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/either_x.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/communities_local_data_source.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunitiesLocalDataSource _local;
  const CommunityRepositoryImpl(this._local);

  @override
  Future<Either<Failure, List<Community>>> getCommunities() async {
    try {
      return Right(await _local.getCommunities());
    } catch (e, s) {
      debugPrint('CommunityRepositoryImpl: unexpected $e\n$s');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
