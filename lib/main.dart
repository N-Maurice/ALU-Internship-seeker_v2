import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // Swallow init failures (e.g. the placeholder Firebase config) so the
    // app still boots — individual Auth/Firestore calls surface their own
    // friendly error state via core/errors rather than crashing here.
    initError = e.toString();
  }

  runApp(ProviderScope(child: AluVentureConnectApp(initError: initError)));
}

class AluVentureConnectApp extends ConsumerWidget {
  const AluVentureConnectApp({super.key, this.initError});

  final String? initError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Could not connect to Firebase.',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Run "flutterfire configure" to connect this app to a real Firebase project.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ALU Venture Connect',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
