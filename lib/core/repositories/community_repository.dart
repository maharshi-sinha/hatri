import '../models/models.dart';

abstract class CommunityRepository {
  Future<List<Community>> getCommunities();
}
