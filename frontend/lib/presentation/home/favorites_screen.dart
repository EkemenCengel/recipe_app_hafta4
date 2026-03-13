import 'package:flutter/material.dart';
import '../../data/models/recipe_model.dart';
import '../../data/services/recipe_service.dart';
import '../shared/recipe_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Future<List<Recipe>>? _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
    RecipeService.favoritesNotifier.addListener(_fetchFavorites);
  }

  @override
  void dispose() {
    RecipeService.favoritesNotifier.removeListener(_fetchFavorites);
    super.dispose();
  }

  void _fetchFavorites() {
    setState(() {
      _favoritesFuture = RecipeService.getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Henüz favoriye eklenmiş tarif yok.', style: TextStyle(color: Colors.white)));
          }

          final recipes = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              _fetchFavorites();
            },
            color: Colors.deepOrange,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return RecipeCard(recipe: recipes[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
