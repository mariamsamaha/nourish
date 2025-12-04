import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Service for interacting with Spoonacular API for food detection and nutrition analysis

class SpoonacularService {
  // Replace with your actual Spoonacular API key
  // Get your API key from: https://spoonacular.com/food-api
  static const String _apiKey = '3f09b6988a024610af31c558ba67af1f';
  static const String _baseURL = 'api.spoonacular.com';

  SpoonacularService._();
  static final SpoonacularService instance = SpoonacularService._();

  /// Returns a map with detected ingredients and nutrition information
  Future<Map<String, dynamic>> analyzeFoodImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Image file not found');
      }

      // CRITICAL: API key MUST be in URL query parameters (not request.fields)
      final uri = Uri.https(_baseURL, '/food/images/analyze', {
        'apiKey': _apiKey, // ← This is the ONLY correct way
      });

      final request = http.MultipartRequest('POST', uri);

      // Add the image file
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing food image: $e');
    }
  }

  /// Detect food items in an image using image URL
  Future<Map<String, dynamic>> detectFoodByImageUrl(String imageUrl) async {
    try {
      final uri = Uri.https(_baseURL, '/food/detect', {
        'apiKey': _apiKey,
        'imageUrl': imageUrl,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to detect food: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error detecting food: $e');
    }
  }

  /// Get nutrition information for detected ingredients
  Future<Map<String, dynamic>> getNutritionInfo(
    List<String> ingredients,
  ) async {
    try {
      final ingredientsString = ingredients.join(',');
      final uri = Uri.https(_baseURL, '/recipes/guessNutrition', {
        'apiKey': _apiKey,
        'title': ingredientsString,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get nutrition info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting nutrition info: $e');
    }
  }

  /// Get detailed recipe information by ID
  Future<Map<String, dynamic>> getRecipeInfo(int recipeId) async {
    try {
      final uri = Uri.https(_baseURL, '/recipes/$recipeId/information', {
        'apiKey': _apiKey,
        'includeNutrition': 'true',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get recipe info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting recipe info: $e');
    }
  }

  /// Extract ingredients and nutrition from analysis result
  Map<String, dynamic> parseAnalysisResult(Map<String, dynamic> analysisData) {
    try {
      final categories = analysisData['category'] ?? {};
      final nutrition = analysisData['nutrition'] ?? {};
      final recipes = analysisData['recipes'] ?? [];

      // Extract detected ingredients
      List<String> ingredients = [];
      if (categories['name'] != null) {
        ingredients.add(categories['name'].toString());
      }

      // Extract nutrition information
      final calories = nutrition['calories']?['value']?.toDouble() ?? 0.0;
      final carbs = nutrition['carbs']?['value']?.toDouble() ?? 0.0;
      final fat = nutrition['fat']?['value']?.toDouble() ?? 0.0;
      final protein = nutrition['protein']?['value']?.toDouble() ?? 0.0;

      return {
        'ingredients': ingredients,
        'calories': calories,
        'carbs': carbs,
        'fat': fat,
        'protein': protein,
        'recipes': recipes,
        'category': categories,
      };
    } catch (e) {
      throw Exception('Error parsing analysis result: $e');
    }
  }
}
