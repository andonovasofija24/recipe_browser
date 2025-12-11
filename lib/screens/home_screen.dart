import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../widgets/category_card.dart';
import 'category_meals_screen.dart';
import '../screens/favorites_screen.dart';
import '../models/meal_detail.dart';
import 'meal_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService.instance;
  late Future<List<Category>> _futureCategories;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futureCategories = api.fetchCategories();
  }

  Future<void> _openRandomMeal() async {
    try {
      final MealDetail meal = await api.fetchRandomMeal();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load random meal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Random recipe',
            onPressed: _openRandomMeal,
            icon: const Icon(Icons.shuffle),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search categories...',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: _futureCategories,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final categories = snapshot.data ?? [];
                final filtered = _searchQuery.trim().isEmpty
                    ? categories
                    : categories
                          .where(
                            (c) => c.strCategory.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final cat = filtered[index];
                    return CategoryCard(
                      category: cat,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CategoryMealsScreen(category: cat.strCategory),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
