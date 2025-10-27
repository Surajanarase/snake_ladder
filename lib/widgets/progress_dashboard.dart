// lib/widgets/progress_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';

class ProgressDashboard extends StatelessWidget {
  const ProgressDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameService>(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFf8f9fa),
      ),
      child: Column(
        children: [
          const Text(
            'Your Health Knowledge',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
            children: [
              _categoryCard(
                '🍎',
                'Nutrition',
                game.healthProgress['nutrition'] ?? 0,
              ),
              _categoryCard(
                '💪',
                'Exercise',
                game.healthProgress['exercise'] ?? 0,
              ),
              _categoryCard(
                '😴',
                'Sleep',
                game.healthProgress['sleep'] ?? 0,
              ),
              _categoryCard(
                '🧘',
                'Mental Health',
                game.healthProgress['mental'] ?? 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(String icon, String name, int progress) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFe0e0e0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}