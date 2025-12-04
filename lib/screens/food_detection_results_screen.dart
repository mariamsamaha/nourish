import 'dart:io';
import 'package:flutter/material.dart';
import 'package:proj/services/spoonacular_service.dart';

class FoodDetectionResultsScreen extends StatefulWidget {
  final String imagePath;

  const FoodDetectionResultsScreen({super.key, required this.imagePath});

  @override
  State<FoodDetectionResultsScreen> createState() =>
      _FoodDetectionResultsScreenState();
}

class _FoodDetectionResultsScreenState
    extends State<FoodDetectionResultsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _analysisResult;
  List<String> _detectedIngredients = [];
  double _calories = 0.0;
  double _carbs = 0.0;
  double _fat = 0.0;
  double _protein = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Analyze the food image
      final result =
          await SpoonacularService.instance.analyzeFoodImage(widget.imagePath);
      final parsed = SpoonacularService.instance.parseAnalysisResult(result);

      setState(() {
        _analysisResult = parsed;
        _detectedIngredients = List<String>.from(parsed['ingredients'] ?? []);
        _calories = parsed['calories']?.toDouble() ?? 0.0;
        _carbs = parsed['carbs']?.toDouble() ?? 0.0;
        _fat = parsed['fat']?.toDouble() ?? 0.0;
        _protein = parsed['protein']?.toDouble() ?? 0.0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Analysis'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      _buildImageSection(),
                      const SizedBox(height: 24),
                      // Detected Ingredients
                      _buildIngredientsSection(),
                      const SizedBox(height: 24),
                      // Nutrition Information
                      _buildNutritionSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error analyzing image',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _analyzeImage,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detected Ingredients',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 12),
            if (_detectedIngredients.isEmpty)
              const Text(
                'No ingredients detected. Try taking a clearer photo.',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _detectedIngredients.map((ingredient) {
                  return Chip(
                    label: Text(ingredient),
                    backgroundColor: const Color(0xFFE8F5E9),
                    labelStyle: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nutrition Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 16),
            _buildNutritionRow(
              'Calories',
              _calories.toStringAsFixed(0),
              Icons.local_fire_department,
              Colors.orange,
            ),
            const Divider(),
            _buildNutritionRow(
              'Protein',
              '${_protein.toStringAsFixed(1)} g',
              Icons.fitness_center,
              Colors.blue,
            ),
            const Divider(),
            _buildNutritionRow(
              'Carbs',
              '${_carbs.toStringAsFixed(1)} g',
              Icons.breakfast_dining,
              Colors.amber,
            ),
            const Divider(),
            _buildNutritionRow(
              'Fat',
              '${_fat.toStringAsFixed(1)} g',
              Icons.water_drop,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

