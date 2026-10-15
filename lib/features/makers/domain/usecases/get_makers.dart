import 'package:equatable/equatable.dart';

import '../../../../backend/models/maker_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/maker_repository.dart';

class GetMakers extends UseCase<ApiMakerFeed, GetMakersParams> {
  final MakerRepository repo;
  const GetMakers(this.repo);

  @override
  Future<Either<Failure, ApiMakerFeed>> call(GetMakersParams p) =>
      repo.list(
        citySlug: p.citySlug,
        category: p.category,
        cursor: p.cursor,
        q: p.q,
        limit: p.limit,
      );
}

class GetMakersParams extends Equatable {
  final String? citySlug;
  final String? category;
  final String? cursor;
  final String? q;
  final int limit;

  const GetMakersParams({
    this.citySlug,
    this.category,
    this.cursor,
    this.q,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [citySlug, category, cursor, q, limit];
}

class GetMakerById extends UseCase<ApiMakerDetail, String> {
  final MakerRepository repo;
  const GetMakerById(this.repo);

  @override
  Future<Either<Failure, ApiMakerDetail>> call(String id) => repo.getById(id);
}
