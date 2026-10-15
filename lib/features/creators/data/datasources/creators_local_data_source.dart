import '../../../../core/models/models.dart';
import '../../../../core/repositories/mock_repository.dart';

abstract class CreatorsLocalDataSource {
  Future<List<CreatorProfile>> getCreators();
  Future<CreatorProfile?> getById(String id);
}

class CreatorsLocalDataSourceImpl implements CreatorsLocalDataSource {
  const CreatorsLocalDataSourceImpl();

  @override
  Future<List<CreatorProfile>> getCreators() async =>
      MockRepository.mockCreators;

  @override
  Future<CreatorProfile?> getById(String id) async {
    for (final c in MockRepository.mockCreators) {
      if (c.id == id) return c;
    }
    return null;
  }
}
