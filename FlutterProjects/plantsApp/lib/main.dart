import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/care_planner_screen.dart';
import 'screens/home_screen.dart';
import 'screens/identify_screen.dart';
import 'screens/login_screen.dart';
import 'screens/plant_knowledge_screen.dart';
import 'screens/plant_detail_screen.dart';
import 'screens/signup_screen.dart';
import 'services/auth_controller.dart';
import 'services/auth_service.dart';
import 'services/image_identification_service.dart';
import 'services/plant_api_service.dart';
import 'services/plant_care_schedule_service.dart';
import 'services/user_preferences_service.dart';
import 'services/plant_identifier_service.dart';
import 'services/plant_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Handle Firebase initialization errors gracefully
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const PlantsApp());
}

class PlantsApp extends StatelessWidget {
  const PlantsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        ChangeNotifierProvider(
          create: (context) => AuthController(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(create: (_) => UserPreferencesService()),
        ChangeNotifierProvider(create: (_) => PlantService()),
        ChangeNotifierProvider(create: (_) => PlantCareScheduleService()),
        ProxyProvider<PlantService, PlantIdentifierService>(
          update: (_, plantService, __) => PlantIdentifierService(plantService),
        ),
        Provider(
          create: (_) => PlantApiService(apiKey: 'sk-6DB8691e265be480813570'),
        ),
        Provider(
          create: (_) => ImageIdentificationService(
            // Add your Plant.id API key here if needed
            // apiKey: 'your-plant-id-api-key',
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Plant Identifier',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
        home: const _AuthGate(),
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          SignupScreen.routeName: (_) => const SignupScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          PlantDetailScreen.routeName: (_) => const PlantDetailScreen(),
          IdentifyScreen.routeName: (_) => const IdentifyScreen(),
          PlantCarePlannerScreen.routeName: (_) =>
              const PlantCarePlannerScreen(),
          PlantKnowledgeScreen.routeName: (_) => const PlantKnowledgeScreen(),
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (_, auth, __) {
        switch (auth.status) {
          case AuthStatus.authenticated:
            return const HomeScreen();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
          case AuthStatus.unknown:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
        }
      },
    );
  }
}
