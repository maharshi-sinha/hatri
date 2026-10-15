import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/repositories/community_repository.dart';
import 'communities_event.dart';
import 'communities_state.dart';

class CommunitiesBloc extends Bloc<CommunitiesEvent, CommunitiesState> {
  final CommunityRepository repository;

  CommunitiesBloc({required this.repository}) : super(CommunitiesInitial()) {
    on<LoadCommunities>(_onLoadCommunities);
  }

  Future<void> _onLoadCommunities(LoadCommunities event, Emitter<CommunitiesState> emit) async {
    emit(CommunitiesLoading());
    try {
      // Simulate network delay for MVP UI effect
      await Future.delayed(const Duration(milliseconds: 800));
      final communities = await repository.getCommunities();
      emit(CommunitiesLoaded(communities));
    } catch (e) {
      emit(CommunitiesError(e.toString()));
    }
  }
}
