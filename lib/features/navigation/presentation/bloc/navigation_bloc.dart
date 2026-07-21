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
  final bool scrollToServices;
  const TabChanged(this.index, {this.subIndex = 0, this.scrollToServices = false});
  @override
  List<Object> get props => [index, subIndex, scrollToServices];
}

// State
class NavigationState extends Equatable {
  final int currentIndex;
  final int requestsSubIndex;
  final bool scrollToServices;
  const NavigationState(
    this.currentIndex, {
    this.requestsSubIndex = 0,
    this.scrollToServices = false,
  });
  @override
  List<Object> get props => [currentIndex, requestsSubIndex, scrollToServices];
}

// BLoC
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState(0)) {
    on<TabChanged>((event, emit) {
      emit(NavigationState(
        event.index,
        requestsSubIndex: event.subIndex,
        scrollToServices: event.scrollToServices,
      ));
    });
  }
}
