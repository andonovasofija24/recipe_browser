// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final String _base = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> fetchCategories() async {
    final url = Uri.parse('$_base/categories.php');
    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load categories');
    }
    final data = json.decode(resp.body);
    final List items = data['categories'] ?? [];
    return items.map((e) => Category.fromJson(e)).toList();
  }

  Future<List<MealSummary>> fetchMealsByCategory(String category) async {
    final url = Uri.parse(
      '$_base/filter.php?c=${Uri.encodeComponent(category)}',
    );
    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load meals for category $category');
    }
    final data = json.decode(resp.body);
    final List items = data['meals'] ?? [];
    return items.map((e) => MealSummary.fromJson(e)).toList();
  }

  /// Search across all meals by name (returns meals matching query).
  /// Note: this endpoint searches entire DB, you can filter client-side by category if desired.
  Future<List<MealSummary>> searchMeals(String query) async {
    if (query.trim().isEmpty) return [];
    final url = Uri.parse('$_base/search.php?s=${Uri.encodeComponent(query)}');
    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      throw Exception('Search failed');
    }
    final data = json.decode(resp.body);
    final List? items = data['meals'];
    if (items == null) return [];
    return items.map((e) => MealSummary.fromJson(e)).toList();
  }

  Future<MealDetail> fetchMealDetail(String id) async {
    final url = Uri.parse('$_base/lookup.php?i=${Uri.encodeComponent(id)}');
    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load meal detail');
    }
    final data = json.decode(resp.body);
    final List items = data['meals'] ?? [];
    if (items.isEmpty) throw Exception('Meal not found');
    return MealDetail.fromJson(items.first);
  }

  Future<MealDetail> fetchRandomMeal() async {
    final url = Uri.parse('$_base/random.php');
    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load random meal');
    }
    final data = json.decode(resp.body);
    final List items = data['meals'] ?? [];
    if (items.isEmpty) throw Exception('No random meal found');
    return MealDetail.fromJson(items.first);
  }
}
