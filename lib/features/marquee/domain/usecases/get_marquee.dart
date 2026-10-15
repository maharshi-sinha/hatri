import '../../../../backend/models/marquee_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/marquee_repository.dart';

class GetMarquee extends UseCase<List<ApiMarqueeItem>, String?> {
  final MarqueeRepository repo;
  const GetMarquee(this.repo);

  @override
  Future<Either<Failure, List<ApiMarqueeItem>>> call(String? city) =>
      repo.list(city: city);
}
