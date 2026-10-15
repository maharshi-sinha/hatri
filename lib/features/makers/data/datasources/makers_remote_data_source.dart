import '../../../../backend/api/makers_api.dart';
import '../../../../backend/models/maker_models.dart';

abstract class MakersRemoteDataSource {
  Future<ApiMakerFeed> list({
    String? citySlug,
    String? category,
    String? cursor,
    String? q,
    int limit,
  });

  Future<ApiMakerDetail> getById(String id);
  Future<FollowResult> follow(String id);
  Future<FollowResult> unfollow(String id);
}

class MakersRemoteDataSourceImpl implements MakersRemoteDataSource {
  final MakersApi _api;
  const MakersRemoteDataSourceImpl(this._api);

  @override
  Future<ApiMakerFeed> list({
    String? citySlug,
    String? category,
    String? cursor,
    String? q,
    int limit = 20,
  }) =>
      _api.list(
        citySlug: citySlug,
        category: category,
        cursor: cursor,
        q: q,
        limit: limit,
      );

  @override
  Future<ApiMakerDetail> getById(String id) => _api.getById(id);

  @override
  Future<FollowResult> follow(String id) => _api.follow(id);

  @override
  Future<FollowResult> unfollow(String id) => _api.unfollow(id);
}
