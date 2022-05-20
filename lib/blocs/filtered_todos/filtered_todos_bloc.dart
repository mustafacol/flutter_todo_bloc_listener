// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/todo_model.dart';

part 'filtered_todos_event.dart';
part 'filtered_todos_state.dart';

class FilteredTodosBloc extends Bloc<FilteredTodosEvent, FilteredTodosState> {
  final List<Todo> initialTodos;

  

  FilteredTodosBloc({
    required this.initialTodos,
  }) : super(FilteredTodosState.initial()) {
    
    on<CalculateFilteredTodosEvent>((event, emit) {
      emit(state.copyWith(filteredTodos: event.filteredTodos));
    });
  }

  // void setFilteredTodos() {
  //   List<Todo> _filteredTodos;

  //   switch (todoFilterBloc.state.filter) {
  //     case Filter.active:
  //       _filteredTodos = todoListBloc.state.todos
  //           .where((Todo todo) => !todo.completed)
  //           .toList();
  //       break;
  //     case Filter.completed:
  //       _filteredTodos = todoListBloc.state.todos
  //           .where((Todo todo) => todo.completed)
  //           .toList();
  //       break;
  //     case Filter.all:
  //     default:
  //       _filteredTodos = todoListBloc.state.todos;
  //       break;
  //   }

  //   if (todoSearchBloc.state.searchTerm.isNotEmpty) {
  //     _filteredTodos = todoListBloc.state.todos
  //         .where((Todo todo) =>
  //             todo.desc.toLowerCase().contains(todoSearchBloc.state.searchTerm))
  //         .toList();
  //   }

  //   add(CalculateFilteredTodosEvent(filteredTodos: _filteredTodos));
  // }


}
