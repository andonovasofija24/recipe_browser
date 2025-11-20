// lib/screens/meal_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_detail.dart';

class MealDetailScreen extends StatelessWidget {
  final MealDetail meal;
  const MealDetailScreen({super.key, required this.meal});

  void _openYoutube(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.strMeal),
        actions: [
          if (meal.strYoutube != null && meal.strYoutube!.isNotEmpty)
            IconButton(
              onPressed: () => _openYoutube(meal.strYoutube),
              icon: const Icon(Icons.play_circle_fill),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (meal.strMealThumb.isNotEmpty)
              Image.network(
                meal.strMealThumb,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.strMeal,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (meal.strCategory.isNotEmpty)
                        Chip(label: Text(meal.strCategory)),
                      const SizedBox(width: 8),
                      if (meal.strArea.isNotEmpty)
                        Chip(label: Text(meal.strArea)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: meal.ingredients.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final ing = meal.ingredients[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.food_bank),
                        title: Text(ing['ingredient'] ?? ''),
                        trailing: Text(ing['measure'] ?? ''),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Instructions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(meal.strInstructions),
                  const SizedBox(height: 12),
                  if (meal.strYoutube != null && meal.strYoutube!.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => _openYoutube(meal.strYoutube),
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text('Watch on YouTube'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
