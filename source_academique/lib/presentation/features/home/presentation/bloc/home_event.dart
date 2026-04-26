// home_event.dart
part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override List<Object?> get props => [];
}

class FetchHomeData extends HomeEvent {}

// 👇 NOUVEL ÉVÉNEMENT : Déclenché par le pull-to-refresh
class RefreshHomeData extends HomeEvent {}