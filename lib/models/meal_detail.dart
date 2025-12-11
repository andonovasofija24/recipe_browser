import 'meal_summary.dart';

class MealDetail {
  final String idMeal;
  final String strMeal;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strMealThumb;
  final String? strYoutube;
  final List<Map<String, String>> ingredients; // list of {ingredient: measure}

  MealDetail({
    required this.idMeal,
    required this.strMeal,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    required this.ingredients,
    this.strYoutube,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    final List<Map<String, String>> ingList = [];
    for (var i = 1; i <= 20; i++) {
      final ingKey = 'strIngredient$i';
      final meaKey = 'strMeasure$i';
      final ingredient = (json[ingKey] ?? '').toString().trim();
      final measure = (json[meaKey] ?? '').toString().trim();
      if (ingredient.isNotEmpty) {
        ingList.add({'ingredient': ingredient, 'measure': measure});
      }
    }

    return MealDetail(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strCategory: json['strCategory'] ?? '',
      strArea: json['strArea'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strYoutube: json['strYoutube'],
      ingredients: ingList,
    );
  }

  /// Convert MealDetail → MealSummary for displaying in cards
  MealSummary toSummary() {
    return MealSummary(
      idMeal: idMeal,
      strMeal: strMeal,
      strMealThumb: strMealThumb,
    );
  }
}
