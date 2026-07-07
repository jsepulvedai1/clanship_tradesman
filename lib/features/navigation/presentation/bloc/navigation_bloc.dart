import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();
  @override
  List<Object> get props => [];
}

class TabChanged extends NavigationEvent {
  final int index;
  final int subIndex;
  const TabChanged(this.index, {this.subIndex = 0});
  @override
  List<Object> get props => [index, subIndex];
}

// State
class NavigationState extends Equatable {
  final int currentIndex;
  final int requestsSubIndex;
  const NavigationState(this.currentIndex, {this.requestsSubIndex = 0});
  @override
  List<Object> get props => [currentIndex, requestsSubIndex];
}

// BLoC
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState(0)) {
    on<TabChanged>((event, emit) {
      emit(NavigationState(event.index, requestsSubIndex: event.subIndex));
    });
  }
}
