// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/blocs.dart';
import '../blocs/todo_list/todo_list_state.dart';
import '../blocs/todo_search/todo_search_state.dart';
import '../models/todo_model.dart';

class ShowTodos extends StatelessWidget {
  const ShowTodos({Key? key}) : super(key: key);
  List<Todo> setFilteredTodos(
      Filter filter, List<Todo> todos, String searchTerm) {
    List<Todo> _filteredTodos;

    switch (filter) {
      case Filter.active:
        _filteredTodos = todos.where((Todo todo) => !todo.completed).toList();
        break;
      case Filter.completed:
        _filteredTodos = todos.where((Todo todo) => todo.completed).toList();
        break;
      case Filter.all:
      default:
        _filteredTodos = todos;
        break;
    }

    if (searchTerm.isNotEmpty) {
      _filteredTodos = todos
          .where((Todo todo) => todo.desc.toLowerCase().contains(searchTerm))
          .toList();
    }

    return _filteredTodos;
  }

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<FilteredTodosBloc>().state.filteredTodos;

    return MultiBlocListener(
      listeners: [
        BlocListener<TodoListBloc, TodoListState>(
          listener: (context, state) {
            final filteredTodos = setFilteredTodos(
                context.read<TodoFilterBloc>().state.filter,
                state.todos,
                context.read<TodoSearchBloc>().state.searchTerm);

            context
                .read<FilteredTodosBloc>()
                .add(CalculateFilteredTodosEvent(filteredTodos: filteredTodos));
          },
        ),
        BlocListener<TodoFilterBloc, TodoFilterState>(
          listener: (context, state) {
            final filteredTodos = setFilteredTodos(
                state.filter,
                context.read<TodoListBloc>().state.todos,
                context.read<TodoSearchBloc>().state.searchTerm);

            context
                .read<FilteredTodosBloc>()
                .add(CalculateFilteredTodosEvent(filteredTodos: filteredTodos));
          },
        ),
        BlocListener<TodoSearchBloc, TodoSearchState>(
          listener: (context, state) {
            final filteredTodos = setFilteredTodos(
                context.read<TodoFilterBloc>().state.filter,
                context.read<TodoListBloc>().state.todos,
                state.searchTerm);

            context
                .read<FilteredTodosBloc>()
                .add(CalculateFilteredTodosEvent(filteredTodos: filteredTodos));
          },
        ),
      ],
      child: ListView.separated(
        primary: false,
        shrinkWrap: true,
        separatorBuilder: (BuildContext buildContext, int index) {
          return Divider(color: Colors.grey);
        },
        itemCount: todos.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.all(6.0),
            child: Dismissible(
              key: ValueKey(todos[index].id),
              background: showDeleteBackground(0),
              secondaryBackground: showDeleteBackground(1),
              onDismissed: (_) {
                context
                    .read<TodoListBloc>()
                    .add(RemoveTodoEvent(todo: todos[index]));
              },
              confirmDismiss: (_) {
                return showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Are you sure?'),
                        content: Text('Do you really want to delete?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Yes'),
                          )
                        ],
                      );
                    });
              },
              child: TodoItem(todo: todos[index]),
            ),
          );
        },
      ),
    );
  }

  Widget showDeleteBackground(int direction) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      color: Colors.red,
      alignment: direction == 0 ? Alignment.centerLeft : Alignment.centerRight,
      child: Icon(
        Icons.delete,
        size: 20.0,
        color: Colors.white,
      ),
    );
  }
}

class TodoItem extends StatefulWidget {
  final Todo todo;
  TodoItem({
    Key? key,
    required this.todo,
  }) : super(key: key);

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  late final TextEditingController textController;
  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              bool _error = false;
              textController.text = widget.todo.desc;
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return AlertDialog(
                    title: Text('Edit Todo'),
                    content: TextField(
                      controller: textController,
                      autofocus: true,
                      decoration: InputDecoration(
                          errorText: _error ? "Value cannot be empty" : null),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              _error =
                                  textController.text.isEmpty ? true : false;
                              if (!_error) {
                                context.read<TodoListBloc>().add(EditTodoEvent(
                                    id: widget.todo.id,
                                    todoDesc: textController.text));

                                Navigator.pop(context, true);
                              }
                            });
                          },
                          child: Text('Edit')),
                    ],
                  );
                },
              );
            });
      },
      leading: Checkbox(
        value: widget.todo.completed,
        onChanged: (bool? checked) {
          context.read<TodoListBloc>().add(ToggleTodoEvent(id: widget.todo.id));
        },
      ),
      title: Text(widget.todo.desc),
    );
  }
}
