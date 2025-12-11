import 'package:flutter/material.dart';
import '../models/meal_summary.dart';
import '../services/api_service.dart';
import '../widgets/meal_card.dart';
import 'meal_detail_screen.dart';

class CategoryMealsScreen extends StatefulWidget {
  final String category;
  const CategoryMealsScreen({super.key, required this.category});

  @override
  State<CategoryMealsScreen> createState() => _CategoryMealsScreenState();
}

class _CategoryMealsScreenState extends State<CategoryMealsScreen> {
  final ApiService api = ApiService.instance;
  late Future<List<MealSummary>> _futureMeals;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futureMeals = api.fetchMealsByCategory(widget.category);
  }

  Future<void> _search(String query) async {
    setState(() => _searchQuery = query);
    if (query.trim().isNotEmpty) {
      final results = await api.searchMeals(query);
      setState(() {
        _futureMeals = Future.value(results.toList());
      });
    } else {
      setState(() {
        _futureMeals = api.fetchMealsByCategory(widget.category);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search dishes in ${widget.category}...',
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _search(''),
                      )
                    : null,
              ),
              onSubmitted: _search,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MealSummary>>(
              future: _futureMeals,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final meals = snapshot.data ?? [];
                if (meals.isEmpty) {
                  return const Center(child: Text('No meals found.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
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
                        final detail = await api.fetchMealDetail(meal.idMeal);
                        if (!mounted) return;
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
          ),
        ],
      ),
    );
  }
}
