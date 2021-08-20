import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collector/repo/todo_list_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompletedTaskScreen extends StatefulWidget {
  const CompletedTaskScreen({Key? key}) : super(key: key);

  @override
  _CompletedTaskScreenState createState() => _CompletedTaskScreenState();
}

class _CompletedTaskScreenState extends State<CompletedTaskScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final firebaseCompletedTaskProvider =
      StreamProvider.autoDispose<List<TodoItem>>((ref) {
    print('listening');
    final stream = FirebaseFirestore.instance
        .collection('todo-list')
        .where('is_complete', isEqualTo: true)
        .snapshots();
    return stream.map((snapshot) =>
        snapshot.docs.map((doc) => TodoItem.fromSnapshot(doc)).toList());
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Tasks'),
        actions: [
          IconButton(
            onPressed: () {
              _showAddTaskDialog();
            },
            icon: Icon(Icons.playlist_add_rounded),
          )
        ],
      ),
      body: Consumer(builder: (context, watch, child) {
        return watch(firebaseCompletedTaskProvider).maybeWhen(
            data: (todoList) {
              return ListView.separated(
                  padding: EdgeInsets.only(bottom: 64, top: 8),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Checkbox(
                        value: todoList[index].isComplete,
                        tristate: true,
                        onChanged: (bool? value) {
                          TodoListManager().checkToggle(context,
                              isComplete: value ?? false,
                              docId: todoList[index].id);
                        },
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(todoList[index].title)),
                          IconButton(
                            icon: CircleAvatar(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.white,
                                child: Icon(
                                  Icons.edit_rounded,
                                  size: 16,
                                  color: Colors.black,
                                )),
                            onPressed: () {
                              _showEditDialog(todoList[index]);
                            },
                          ),
                        ],
                      ),
                      subtitle: Text(todoList[index].description),
                      trailing: IconButton(
                          onPressed: () {
                            _showDeleteTaskAlertDialog(todoList[index]);
                          },
                          icon: Icon(Icons.remove_circle),
                          color: Theme.of(context).errorColor.withOpacity(0.5)),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Divider(),
                    );
                  },
                  itemCount: todoList.length);
            },
            loading: () => Center(
                  child: CircularProgressIndicator(),
                ),
            error: (err, stack) => Center(
                  child: Text(err.toString()),
                ),
            orElse: () => Text('nsns'));
      }),
    );
  }

  _showAddTaskDialog() async {
    TextEditingController titleTextEditingController = TextEditingController();
    TextEditingController descriptionTextEditingController =
        TextEditingController();
    final _formKey = GlobalKey<FormState>();
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              titlePadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(
                          Icons.close,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Add A Task',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              contentPadding: EdgeInsets.only(bottom: 16, left: 10, right: 10),
              content: SingleChildScrollView(
                  child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {});
                          },
                          controller: titleTextEditingController,
                          keyboardType: TextInputType.text,
                          autofocus: true,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color,
                              fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color,
                                fontSize: 12),
                            filled: true,
                            contentPadding: EdgeInsets.all(15),
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFF3F3F3), width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {});
                          },
                          maxLines: 3,
                          controller: descriptionTextEditingController,
                          keyboardType: TextInputType.text,
                          autofocus: true,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color,
                              fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Description',
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color,
                                fontSize: 12),
                            filled: true,
                            contentPadding: EdgeInsets.all(15),
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFF3F3F3), width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      child: Text('Add'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          addTodoItem(
                              title: titleTextEditingController.text,
                              description:
                                  descriptionTextEditingController.text);
                          Navigator.of(context).pop();
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              )),
            );
          });
        });
  }

  _showDeleteTaskAlertDialog(TodoItem item) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              titlePadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(
                          Icons.close,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Are you sure your want to delete ${item.title} task',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              contentPadding: EdgeInsets.only(bottom: 16, left: 10, right: 10),
              actions: [
                TextButton(
                    onPressed: () {
                      deleteTodoItem(docId: item.id);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Delete Task',
                      style: TextStyle(color: Theme.of(context).errorColor),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel')),
              ],
            );
          });
        });
  }

  _showEditDialog(TodoItem item) async {
    TextEditingController titleTextEditingController =
        TextEditingController(text: item.title);
    TextEditingController descriptionTextEditingController =
        TextEditingController(text: item.description);
    final _formKey = GlobalKey<FormState>();
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              titlePadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(
                          Icons.close,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Edit Task',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              contentPadding: EdgeInsets.only(bottom: 16, left: 10, right: 10),
              content: SingleChildScrollView(
                  child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {});
                          },
                          controller: titleTextEditingController,
                          keyboardType: TextInputType.text,
                          autofocus: true,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color,
                              fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color,
                                fontSize: 12),
                            filled: true,
                            contentPadding: EdgeInsets.all(15),
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFF3F3F3), width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {});
                          },
                          maxLines: 3,
                          controller: descriptionTextEditingController,
                          keyboardType: TextInputType.text,
                          autofocus: true,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color,
                              fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Description',
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color,
                                fontSize: 12),
                            filled: true,
                            contentPadding: EdgeInsets.all(15),
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFF3F3F3), width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      child: Text('Save'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          updateTodoItem(
                              title: titleTextEditingController.text,
                              description:
                                  descriptionTextEditingController.text,
                              docId: item.id);
                          Navigator.of(context).pop();
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              )),
            );
          });
        });
  }

  void addTodoItem({required String title, required String description}) {
    TodoListManager().addTodoItem(context,
        title: title, description: description, isComplete: true);
  }

  void updateTodoItem(
      {required String title,
      required String description,
      required String docId}) {
    TodoListManager().updateTodoItem(context,
        title: title, description: description, docId: docId);
  }

  void deleteTodoItem({required String docId}) {
    TodoListManager().deleteTodoItem(context, docId: docId);
  }
}
