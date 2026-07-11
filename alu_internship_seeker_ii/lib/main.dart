import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alu_venture_connect/core/theme/app_theme.dart';
import 'package:alu_venture_connect/routes/app_routes.dart';
import 'package:alu_venture_connect/providers/app_providers.dart';
import 'package:alu_venture_connect/core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp(
        title: 'ALU Venture Connect',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.initial,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}