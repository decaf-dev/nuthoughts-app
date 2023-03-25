import 'package:chisel_notes/controllers/app_controller.dart';
import 'package:chisel_notes/routes/home/home_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  Get.put(AppController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'chisel_notes App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomeRoute(title: 'chisel_notes'),
    );
  }
}
