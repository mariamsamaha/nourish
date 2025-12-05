import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Service for interacting with Spoonacular API for food detection and nutrition analysis

class SpoonacularService {
  // Replace with your actual Spoonacular API key
  static const String _apiKey = 'ae4fe43e5d144a2385b1d5d9814ccbfb';
  static const String _baseURL = 'api.spoonacular.com';

  SpoonacularService._();
  static final SpoonacularService instance = SpoonacularService._();

  /// Returns a map with detected ingredients and nutrition information
  Future<Map<String, dynamic>> analyzeFoodImage(String imagePath) async {
    print('🔍 [Spoonacular] Starting food image analysis');
    print('📂 [Spoonacular] Image path: $imagePath');

    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        print('❌ [Spoonacular] Image file not found at path: $imagePath');
        throw Exception('Image file not found');
      }

      print(
        '✅ [Spoonacular] Image file exists, size: ${await imageFile.length()} bytes',
      );

      // CRITICAL: API key MUST be in URL query parameters (not request.fields)
      final uri = Uri.https(_baseURL, '/food/images/analyze', {
        'apiKey': _apiKey, // ← This is the ONLY correct way
      });

      print('🌐 [Spoonacular] API URL: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Add the image file
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      print('📤 [Spoonacular] Sending image to Spoonacular API...');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 [Spoonacular] Response Status Code: ${response.statusCode}');
      print('📥 [Spoonacular] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [Spoonacular] Successfully analyzed image!');
        print('📊 [Spoonacular] Response data: $data');
        return data;
      } else {
        print(
          '❌ [Spoonacular] API Error ${response.statusCode}: ${response.body}',
        );
        throw Exception(
          'Failed to analyze image: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ [Spoonacular] Exception: $e');
      throw Exception('Error analyzing food image: $e');
    }
  }

  /// Analyze food image using bytes (works for web and mobile)
  Future<Map<String, dynamic>> analyzeFoodImageBytes(
    List<int> imageBytes,
    String filename,
  ) async {
    print('🔍 [Spoonacular] Starting food image analysis (bytes)');
    print('📏 [Spoonacular] Image bytes length: ${imageBytes.length}');

    try {
      final uri = Uri.https(_baseURL, '/food/images/analyze', {
        'apiKey': _apiKey,
      });

      print('🌐 [Spoonacular] API URL: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Add the image from bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename.split('/').last,
        ),
      );
      print(
        '📤 [Spoonacular] Sending ${imageBytes.length} bytes to Spoonacular API...',
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 [Spoonacular] Response Status Code: ${response.statusCode}');
      print('📥 [Spoonacular] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [Spoonacular] Successfully analyzed image!');
        print('📊 [Spoonacular] Response data: $data');
        return data;
      } else {
        print(
          '❌ [Spoonacular] API Error ${response.statusCode}: ${response.body}',
        );
        throw Exception(
          'Failed to analyze image: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ [Spoonacular] Exception: $e');
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
    print('🔬 [Spoonacular] Parsing analysis result...');
    print('📊 [Spoonacular] Raw analysis data: $analysisData');

    try {
      final categories = analysisData['category'] ?? {};
      final nutrition = analysisData['nutrition'] ?? {};
      final recipes = analysisData['recipes'] ?? [];

      print('🏷️  [Spoonacular] Categories: $categories');
      print('🍽️  [Spoonacular] Nutrition: $nutrition');
      print('📖 [Spoonacular] Recipes count: ${recipes.length}');

      // Extract detected ingredients
      List<String> ingredients = [];
      if (categories['name'] != null) {
        ingredients.add(categories['name'].toString());
        print('✅ [Spoonacular] Detected ingredient: ${categories['name']}');
      }

      // Extract nutrition information
      final calories = nutrition['calories']?['value']?.toDouble() ?? 0.0;
      final carbs = nutrition['carbs']?['value']?.toDouble() ?? 0.0;
      final fat = nutrition['fat']?['value']?.toDouble() ?? 0.0;
      final protein = nutrition['protein']?['value']?.toDouble() ?? 0.0;

      print(
        '📊 [Spoonacular] Nutrition - Calories: $calories, Carbs: $carbs, Fat: $fat, Protein: $protein',
      );

      final result = {
        'ingredients': ingredients,
        'calories': calories,
        'carbs': carbs,
        'fat': fat,
        'protein': protein,
        'recipes': recipes,
        'category': categories,
      };

      print('✅ [Spoonacular] Parsed result: $result');
      return result;
    } catch (e) {
      print('❌ [Spoonacular] Parse error: $e');
      throw Exception('Error parsing analysis result: $e');
    }
  }
}
