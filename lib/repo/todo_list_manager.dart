import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodoListManager{


  List<TodoItem> allTaskList = [];
  List<TodoItem> completedTaskList = [];
  

  CollectionReference todoList =
      FirebaseFirestore.instance.collection('todo-list');

  final firebaseAllTaskProvider =StreamProvider.autoDispose<List<TodoItem>>((ref){
    print('listening');
    final stream = FirebaseFirestore.instance.collection('todo-list').snapshots();
    return stream.map((snapshot) => snapshot.docs.map((doc) => TodoItem.fromSnapshot(doc)).toList());
  });
  Future<void> init() async {}

  Future<void> addTodoItem(BuildContext context,
      {required String title, required String description, bool? isComplete}) {
    // Call the user's CollectionReference to add a new user
    return todoList.add({
      'title': title,
      'description': description,
      'is_complete': isComplete??false,
    }).then((value) {
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Task Added',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ));
    }).catchError(
        (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'Failed to add Task: $error',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            )));
  }

  Future<void> updateTodoItem(BuildContext context,
      {required String title, required String description, required String docId}) {
    // Call the user's CollectionReference to add a new user
    return todoList.doc(docId).update({
      'title': title,
      'description': description,
    }).then((value) {
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Task Saved',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ));
    }).catchError(
        (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'Failed to update Task: $error',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            )));
  }

  Future<void> deleteTodoItem(BuildContext context,
      {required String docId}) {
    // Call the user's CollectionReference to add a new user
    return todoList.doc(docId).delete().then((value) {
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Task Deleted',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ));
    }).catchError(
        (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'Failed to delete Task: $error',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            )));
  }

  Future<void> checkToggle(BuildContext context,
      {required bool isComplete, required String docId}) {
    // Call the user's CollectionReference to add a new user
    return todoList.doc(docId).update({
      'is_complete': isComplete,
    }).then((value) {
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Updated Task',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ));
    }).catchError(
            (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Failed to update Task: $error',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).primaryColor,
        )));
  }

  List<TodoItem>get getTodoList {
    todoList.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        allTaskList.add(TodoItem.fromSnapshot(doc));
      });
    });
    return allTaskList;
  }
  
  get getCompletedTodoList {
    todoList.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.where((element) => TodoItem.fromSnapshot(element).isComplete==true).forEach((doc) {
        completedTaskList.add(TodoItem.fromSnapshot(doc));
      });
    });
  }
}

class TodoItem {
  final String id;
  final String title;
  final String description;
  final bool isComplete;

  TodoItem(
      {required this.id,
      required this.title,
      required this.description,
      required this.isComplete});

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        isComplete: json['is_complete']);
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "description": description,
        "is_complete": isComplete
      };

  factory TodoItem.fromSnapshot(DocumentSnapshot snapshot) {
    return TodoItem(
        id: '${snapshot.id}',
        title: snapshot['title'],
        description: snapshot['description'],
        isComplete: snapshot['is_complete'] as bool);
  }
}
