import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/no_params.dart';
import '../../domain/usecases/get_communities.dart';
import 'communities_event.dart';
import 'communities_state.dart';

/// Communities bloc migrated to the clean-arch GetCommunities use case +
/// bloc_concurrency's `restartable()` so a second LoadCommunities while
/// the first is in flight cancels the first rather than racing. Behavior
/// for the UI is unchanged.
class CommunitiesBloc extends Bloc<CommunitiesEvent, CommunitiesState> {
  final GetCommunities _getCommunities;

  CommunitiesBloc({required GetCommunities getCommunities})
      : _getCommunities = getCommunities,
        super(CommunitiesInitial()) {
    on<LoadCommunities>(_onLoadCommunities, transformer: restartable());
  }

  Future<void> _onLoadCommunities(
    LoadCommunities event,
    Emitter<CommunitiesState> emit,
  ) async {
    emit(CommunitiesLoading());
    final result = await _getCommunities(const NoParams());
    result.fold(
      (failure) => emit(CommunitiesError(_messageFor(failure))),
      (communities) => emit(CommunitiesLoaded(communities)),
    );
  }

  String _messageFor(Failure f) => switch (f) {
        NetworkFailure() => 'No internet. Pull to retry.',
        AuthFailure() => 'Please sign in to continue.',
        NotFoundFailure() => 'Nothing to show here yet.',
        ValidationFailure() => f.message,
        ServerFailure() => 'Server hiccup. Try again in a moment.',
        CacheFailure() => f.message,
        UnknownFailure() => 'Something went wrong.',
      };
}
