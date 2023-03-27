import 'package:nuthoughts/controllers/app_controller.dart';
import 'package:nuthoughts/controllers/persisted_data.dart';
import 'package:nuthoughts/routes/home/home_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PersistedData.openDatabases();
  Get.put(AppController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NuThoughts',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomeRoute(title: 'NuThoughts'),
    );
  }
}
