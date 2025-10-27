// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/game_service.dart';
import 'widgets/home_shell.dart';

void main() {
  runApp(const HealthSnakeLadderApp());
}

class HealthSnakeLadderApp extends StatelessWidget {
  const HealthSnakeLadderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameService>(
      create: (_) => GameService(),
      child: MaterialApp(
        title: 'Health Heroes',
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        debugShowCheckedModeBanner: false,
        home: const HomeShell(),
      ),
    );
  }
}
