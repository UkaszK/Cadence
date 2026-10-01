import 'package:flutter/material.dart';

class TaskCategory {
  const TaskCategory({required this.name, required this.icon});

  final String name;
  final IconData icon;

  @override
  String toString() => name;
}
