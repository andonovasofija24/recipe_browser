import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/meal_card.dart';
import '../models/meal_summary.dart';
import '../screens/meal_detail_screen.dart';
import '../services/api_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirebaseService.instance.watchFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final favList = snapshot.data ?? [];
          if (favList.isEmpty) {
            return const Center(child: Text('No favorite recipes yet.'));
          }

          // Map favorites to MealSummary for MealCard
          final meals = favList
              .map(
                (f) => MealSummary(
                  idMeal: f['idMeal'],
                  strMeal: f['strMeal'],
                  strMealThumb: f['strMealThumb'] ?? '',
                ),
              )
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.78,
            ),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return MealCard(
                meal: meal,
                onTap: () async {
                  final detail = await ApiService.instance.fetchMealDetail(
                    meal.idMeal,
                  );
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MealDetailScreen(meal: detail),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
