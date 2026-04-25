import 'package:app7/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

      return const GetMaterialApp(
        title: 'EduBuddy',
        debugShowCheckedModeBanner: false,
        //theme: AppTheme.darkTheme,
        home: const Wrapper(),
      );
  }
}
