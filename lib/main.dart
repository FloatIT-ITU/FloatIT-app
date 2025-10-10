import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'src/app.dart';
import 'src/core/di/dependency_injection.dart';
import 'src/push_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependency injection container
  await DependencyInjection.instance.initialize();

  // Initialize push notifications
  final pushService = PushService();
  await pushService.initForCurrentUser();

  runApp(const FloatITApp());
}
