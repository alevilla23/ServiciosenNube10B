import 'package:flutter/material.dart';
import 'package:copylogin/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:copylogin/screens/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  String? token = await FirebaseMessaging.instance.getToken();
  print("TOKEN: $token");

  await FirebaseMessaging.instance.subscribeToTopic("prueba");


  await _initMessaging();
  runApp(const MyApp());
}

Future<void> _initMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Pedir permisos
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('Permiso: ${settings.authorizationStatus}');

  // Obtener token del dispositivo
  String? token = await messaging.getToken();
  print("TOKEN DEL DISPOSITIVO:");
  print(token);

  // Escuchar notificaciones cuando la app está abierta
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Mensaje recibido en primer plano: ${message.notification?.title}');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print("USER ACTUAL: ${snapshot.data}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    ),
  );
}
}
