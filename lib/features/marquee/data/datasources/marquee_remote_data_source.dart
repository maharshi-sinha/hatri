import '../../../../backend/api/marquee_api.dart';
import '../../../../backend/models/marquee_models.dart';

abstract class MarqueeRemoteDataSource {
  Future<List<ApiMarqueeItem>> list({String? city});
}

class MarqueeRemoteDataSourceImpl implements MarqueeRemoteDataSource {
  final MarqueeApi _api;
  const MarqueeRemoteDataSourceImpl(this._api);

  @override
  Future<List<ApiMarqueeItem>> list({String? city}) => _api.list(city: city);
}
