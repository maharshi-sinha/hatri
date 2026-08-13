import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';

abstract class CommunitiesState extends Equatable {
  const CommunitiesState();
  
  @override
  List<Object> get props => [];
}

class CommunitiesInitial extends CommunitiesState {}

class CommunitiesLoading extends CommunitiesState {}

class CommunitiesLoaded extends CommunitiesState {
  final List<Community> communities;

  const CommunitiesLoaded(this.communities);

  @override
  List<Object> get props => [communities];
}

class CommunitiesError extends CommunitiesState {
  final String message;

  const CommunitiesError(this.message);

  @override
  List<Object> get props => [message];
}
