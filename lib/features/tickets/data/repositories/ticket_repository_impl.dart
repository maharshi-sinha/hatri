import 'package:flutter/foundation.dart';

import '../../../../backend/api/api_exception.dart' as api;
import '../../../../backend/models/ticket_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either_x.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/tickets_remote_data_source.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketsRemoteDataSource _remote;
  const TicketRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, ApiTicket>> rsvp(String eventId) =>
      _guard(() => _remote.rsvp(eventId));

  @override
  Future<Either<Failure, void>> cancel(String eventId) =>
      _guard(() => _remote.cancel(eventId));

  @override
  Future<Either<Failure, ApiTicket?>> myTicketFor(String eventId) =>
      _guard(() => _remote.myTicketFor(eventId));

  @override
  Future<Either<Failure, List<ApiTicket>>> myTickets() =>
      _guard(() => _remote.myTickets());

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() op) async {
    try {
      return Right(await op());
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
      debugPrint('TicketRepositoryImpl: unexpected $e\n$s');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
