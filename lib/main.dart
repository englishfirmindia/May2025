import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/pages/login_page.dart';
import 'ui/pages/signup_page.dart';
import 'ui/pages/user_page.dart';
import 'ui/pages/admin_page.dart';
import 'ui/pages/forgot_password_page.dart'; 
import 'services/firebase_auth_service.dart';
import 'services/firestore_service.dart';
import 'providers/auth_provider.dart';
import 'ui/theme.dart';
import 'firebase_options.dart';

import 'ui/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => FirebaseAuthService()),
        Provider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<FirebaseAuthService>(),
            context.read<FirestoreService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Englishfirm AI',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const TypingLoadingScreen(),
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignupPage(),
          '/user': (context) => UserPage(),
          '/admin': (context) => AdminPage(),
          '/forgot-password': (context) => ForgotPasswordPage(), // Add this route
        },
      ),
    );
  }
}