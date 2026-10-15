import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../backend/api/api_exception.dart' as api;
import '../../../../core/error/failures.dart';
import '../../../../core/models/models.dart';
import '../../../../core/repositories/event_feed_page.dart';
import '../../../../core/utils/either_x.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/events_remote_data_source.dart';

/// Clean-arch implementation of [EventRepository]. Catches the typed
/// exceptions the datasource/service throws (`ApiException` tree) and
/// maps them to the sealed [Failure] type the domain layer exposes.
///
/// Note: the API-level [api.ApiException] class tree still lives under
/// `backend/api/`. A later PR migrates it into `core/error/exceptions.dart`
/// so there is only one exception hierarchy app-wide. Until then this is
/// the single adapter site that bridges the two.
class EventRepositoryImpl implements EventRepository {
  final EventsRemoteDataSource _remote;
  const EventRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, EventFeedPage>> getEvents({
    String? cursor,
    String? citySlug,
    String? category,
    int limit = 20,
  }) =>
      _guard(() => _remote.getFeedPage(
            cursor: cursor,
            citySlug: citySlug,
            category: category,
            limit: limit,
          ));

  @override
  Future<Either<Failure, List<Event>>> search({
    required String query,
    String? citySlug,
    int limit = 30,
  }) =>
      _guard(() => _remote.search(
            query: query,
            citySlug: citySlug,
            limit: limit,
          ));

  @override
  Future<Either<Failure, Event>> getById(String id) =>
      _guard(() => _remote.getById(id));

  @override
  Future<Either<Failure, Event>> getBySlug(String slug) =>
      _guard(() => _remote.getBySlug(slug));

  @override
  Future<Either<Failure, int>> save(String id) => _guard(() => _remote.save(id));

  @override
  Future<Either<Failure, int>> unsave(String id) =>
      _guard(() => _remote.unsave(id));

  @override
  Future<Either<Failure, bool>> react(String id, String reaction) =>
      _guard(() => _remote.react(id, reaction));

  @override
  Future<Either<Failure, int>> share(String id) =>
      _guard(() => _remote.share(id));

  @override
  Future<Either<Failure, String>> uploadCover(File file) =>
      _guard(() => _remote.uploadCover(file));

  @override
  Future<Either<Failure, Event>> createEvent(Map<String, dynamic> body) =>
      _guard(() => _remote.createEvent(body));

  /// Single translation point for every method. Runs the datasource call,
  /// catches the ApiException tree, and emits the matching Failure. Any
  /// unexpected throwable becomes UnknownFailure so the UI never sees a
  /// raw stack.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() op) async {
    try {
      final value = await op();
      return Right(value);
    } on api.UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on api.NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on api.ClientException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 422) {
        return Left(ValidationFailure(e.message));
      }
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on api.ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on api.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e, s) {
      debugPrint('EventRepositoryImpl: unexpected $e\n$s');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
