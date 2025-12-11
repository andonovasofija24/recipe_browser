import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/meal_summary.dart';
import '../services/firebase_service.dart';

class MealCard extends StatefulWidget {
  final MealSummary meal;
  final VoidCallback onTap;

  const MealCard({super.key, required this.meal, required this.onTap});

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool _isFavorite = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final fav = await FirebaseService.instance.isFavorite(widget.meal.idMeal);
    if (mounted) {
      setState(() {
        _isFavorite = fav;
        _loading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _loading = true);
    final fs = FirebaseService.instance;

    if (_isFavorite) {
      await fs.removeFavorite(widget.meal.idMeal);
    } else {
      await fs.addFavorite({
        'idMeal': widget.meal.idMeal,
        'strMeal': widget.meal.strMeal,
        'strMealThumb': widget.meal.strMealThumb,
      });
    }

    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.meal.strMealThumb,
                      fit: BoxFit.cover,
                      placeholder: (c, u) =>
                          Container(color: Colors.grey.shade200),
                      errorWidget: (c, u, e) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.meal.strMeal,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: _loading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.redAccent,
                      ),
                      onPressed: _toggleFavorite,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
