import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/hydrobot_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HydrobotApp());
}

class HydrobotApp extends StatelessWidget {
  const HydrobotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HydrobotProvider(),
      child: MaterialApp(
        title: 'HydroBot',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
