import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NavigationEvent{}

class ChangePageEvent extends NavigationEvent{
  final int pageIndex;
  ChangePageEvent(this.pageIndex);
}

class NavigationState{
  final int selectedIndex;
  NavigationState(this.selectedIndex);
}

class NavigationBloc extends Bloc<NavigationEvent, NavigationState>{
   NavigationBloc() : super(NavigationState(0)) {
    on<ChangePageEvent>((event, emit) {
      emit(NavigationState(event.pageIndex));
    });
  }
}