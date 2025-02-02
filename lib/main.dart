import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuthoughts/controllers/app_controller.dart';
import 'package:nuthoughts/controllers/persisted_storage.dart';
import 'package:nuthoughts/routes/home/home_route.dart';
import 'package:nuthoughts/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PersistedStorage.initDB();
  Get.put(AppController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NuThoughts',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeRoute(title: 'NuThoughts'),
    );
  }
}
