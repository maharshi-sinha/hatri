import 'package:equatable/equatable.dart';

abstract class CommunitiesEvent extends Equatable {
  const CommunitiesEvent();

  @override
  List<Object> get props => [];
}

class LoadCommunities extends CommunitiesEvent {}
