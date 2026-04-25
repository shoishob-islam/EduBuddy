import 'package:app7/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:app7/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'auth_service.dart';
import 'Doubt/doubt_service.dart';
import 'notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notificationService = NotificationService();
  await notificationService.initializeNotifications();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(MultiProvider(
    providers: [
      Provider<NotificationService>(
        create: (_) => notificationService,
      ),
      Provider<AuthService>(
        create: (_) => AuthService(notificationService),
      ),
      Provider<DoubtService>(
        create: (context) => DoubtService(
          Provider.of<NotificationService>(context, listen: false),
        ),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const Wrapper(),
    );
  }
}
