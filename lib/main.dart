import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/main_navigation.dart';

import 'theme/app_theme.dart';

import 'package:provider/provider.dart';
import 'providers/sensor_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/health_provider.dart';

import 'services/supabase_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Smart Air Monitoring',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(themeProvider.themeColor, false),
          darkTheme: AppTheme.getTheme(themeProvider.themeColor, true),
          themeMode: themeProvider.themeMode,
          home: const MainNavigation(),
        );
      },
    );
  }
}
