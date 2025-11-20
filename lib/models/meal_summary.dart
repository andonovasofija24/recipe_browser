// lib/models/meal_summary.dart
class MealSummary {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;

  MealSummary({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
  });

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb:
          json['strMealThumb'] ??
          '', // often present; safe fallback to empty string
    );
  }
}
