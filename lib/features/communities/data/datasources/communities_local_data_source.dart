import '../../../../core/models/models.dart';
import '../../../../core/repositories/mock_repository.dart';

/// Communities have no backend endpoint yet. For now the datasource is a
/// pure in-process fixture (hardcoded Community list from
/// `core/repositories/mock_repository.dart`). When the API ships this
/// becomes a RemoteDataSource and the local pattern stays as the
/// offline cache fallback.
abstract class CommunitiesLocalDataSource {
  Future<List<Community>> getCommunities();
}

class CommunitiesLocalDataSourceImpl implements CommunitiesLocalDataSource {
  const CommunitiesLocalDataSourceImpl();

  @override
  Future<List<Community>> getCommunities() async =>
      MockRepository.mockCommunities;
}
