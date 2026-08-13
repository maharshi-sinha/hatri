import '../models/models.dart';

abstract class CreatorRepository {
  Future<List<CreatorProfile>> getCreators();
  Future<CreatorProfile?> getById(String id);
}
