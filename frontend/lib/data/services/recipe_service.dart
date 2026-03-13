import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';
import '../../data/services/auth_service.dart';

class RecipeService {
  static const String baseUrl = 'http://10.9.42.227:3000/api';

  // State notifier to trigger UI rebuilds when favorites change
  static final ValueNotifier<int> favoritesNotifier = ValueNotifier<int>(0);

  static Map<String, String> get headers {
    final token = AuthService.instance.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static void _checkAuth() {
    if (!AuthService.instance.isAuthenticated) {
      throw Exception('Lütfen önce giriş yapın');
    }
  }

  static Future<List<Recipe>> getRecipes([String? category]) async {
    final query = category != null && category != 'Tümü' ? '?category=$category' : '';
    final response = await http.get(Uri.parse('$baseUrl/recipes$query'), headers: headers);
    
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Recipe>.from(l.map((model) => Recipe.fromJson(model)));
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  static Future<Recipe> getRecipe(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/recipes/$id'), headers: headers);
    
    if (response.statusCode == 200) {
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load recipe');
    }
  }
  
  static Future<List<Recipe>> getFavorites() async {
    final response = await http.get(Uri.parse('$baseUrl/favorites'), headers: headers);
    
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      // The backend returns an array of Favorite documents which populate 'recipeId'.
      return List<Recipe>.from(
        l.where((model) => model['recipeId'] != null)
         .map((model) => Recipe.fromJson(model['recipeId']))
      );
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  static Future<void> addFavorite(String recipeId) async {
    _checkAuth();
    final response = await http.post(
      Uri.parse('$baseUrl/favorites/$recipeId'), 
      headers: headers
    );
    if (response.statusCode != 201 && response.statusCode != 400) {
       throw Exception('Failed to add favorite');
    }
    // Notify listeners
    favoritesNotifier.value++;
  }

  static Future<void> removeFavorite(String recipeId) async {
    _checkAuth();
    final response = await http.delete(
       Uri.parse('$baseUrl/favorites/$recipeId'), 
       headers: headers
    );
    if (response.statusCode != 200) {
       throw Exception('Failed to remove favorite');
    }
    // Notify listeners
    favoritesNotifier.value++;
  }

  static Future<Recipe> createRecipe(Map<String, dynamic> recipeData) async {
    _checkAuth();
    final response = await http.post(
      Uri.parse('$baseUrl/recipes'),
      headers: headers,
      body: json.encode(recipeData),
    );

    if (response.statusCode == 201) {
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create recipe: ${response.body}');
    }
  }

  static Future<void> deleteRecipe(String id) async {
    _checkAuth();
    final response = await http.delete(
      Uri.parse('$baseUrl/recipes/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete recipe: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateRecipe(String id, Map<String, dynamic> recipeData) async {
    _checkAuth();
    final response = await http.put(
      Uri.parse('$baseUrl/recipes/$id'),
      headers: headers,
      body: json.encode(recipeData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update recipe: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> rateRecipe(String id, double score) async {
    _checkAuth();
    final response = await http.post(
      Uri.parse('$baseUrl/recipes/$id/rate'),
      headers: headers,
      body: json.encode({'score': score}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to rate recipe: ${response.body}');
    }
  }
}
