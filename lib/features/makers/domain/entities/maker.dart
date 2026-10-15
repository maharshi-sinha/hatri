/// Makers domain entities barrel. Local-model `Maker` lives in
/// `core/models/makers.dart`; the API DTOs live in
/// `backend/models/maker_models.dart`. Later PR consolidates both
/// here.
library;

export '../../../../core/models/makers.dart';
export '../../../../backend/models/maker_models.dart'
    show ApiMakerFeed, ApiMakerDetail, FollowResult;
