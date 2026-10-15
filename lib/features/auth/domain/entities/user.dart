/// Auth domain entity barrel. ApiUser is the JSON DTO Nest returns and
/// serves as the entity for now. A later PR introduces a plain `User`
/// entity in the domain layer and ApiUser becomes a data-layer DTO
/// (mapper fromJson -> User).
library;

export '../../../../backend/models/auth_models.dart'
    show ApiUser, OtpRequestResult, OtpVerifyResult, RefreshResult;
