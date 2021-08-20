import 'package:collector/ui/AllTasksScreen.dart';
import 'package:collector/ui/CompletedTasksScreen.dart';
import 'package:collector/ui/CovidStatsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({Key? key}) : super(key: key);

  @override
  _ParentScreenState createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [CovidStatsScreen(), AllTaskScreen(), CompletedTaskScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded), label: 'All Task'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_outlined), label: 'Completed'),
        ],
      ),
    );
  }
}
