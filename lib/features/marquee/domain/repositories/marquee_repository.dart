import '../../../../backend/models/marquee_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either_x.dart';

abstract class MarqueeRepository {
  /// Fetch the ordered list of marquee items active for the given city.
  /// Pass null to fetch only globally scoped items.
  Future<Either<Failure, List<ApiMarqueeItem>>> list({String? city});
}
