import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:proj/services/spoonacular_service.dart';

// Food Analysis Modal Widget
class FoodAnalysisModal extends StatefulWidget {
  final String imagePath;
  final List<int> imageBytes;

  const FoodAnalysisModal({required this.imagePath, required this.imageBytes});

  @override
  State<FoodAnalysisModal> createState() => _FoodAnalysisModalState();
}

class _FoodAnalysisModalState extends State<FoodAnalysisModal> {
  bool _isLoading = true;
  String? _errorMessage;
  List<String> _detectedIngredients = [];
  double _calories = 0.0;
  double _carbs = 0.0;
  double _fat = 0.0;
  double _protein = 0.0;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    print('\n🚀 [FoodAnalysisModal] Starting image analysis');
    print('📂 [FoodAnalysisModal] Image path: ${widget.imagePath}');

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('⏳ [FoodAnalysisModal] Calling Spoonacular API...');

      final result = await SpoonacularService.instance.analyzeFoodImageBytes(
        widget.imageBytes,
        widget.imagePath,
      );

      print('✅ [FoodAnalysisModal] API call successful, parsing results...');
      final parsed = SpoonacularService.instance.parseAnalysisResult(result);

      print('📊 [FoodAnalysisModal] Parsed results: $parsed');

      setState(() {
        _detectedIngredients = List<String>.from(parsed['ingredients'] ?? []);
        _calories = parsed['calories']?.toDouble() ?? 0.0;
        _carbs = parsed['carbs']?.toDouble() ?? 0.0;
        _fat = parsed['fat']?.toDouble() ?? 0.0;
        _protein = parsed['protein']?.toDouble() ?? 0.0;
        _isLoading = false;
      });

      print('✅ [FoodAnalysisModal] Analysis complete!');
      print('🍽️  [FoodAnalysisModal] Ingredients: $_detectedIngredients');
      print(
        '📊 [FoodAnalysisModal] Nutrition - Calories: $_calories, Carbs: $_carbs, Fat: $_fat, Protein: $_protein',
      );
    } catch (e) {
      print('❌ [FoodAnalysisModal] Error during analysis: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Meal Analysis',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Analyzing your food...'),
                        ],
                      ),
                    )
                  : _errorMessage != null
                  ? Center(
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
                            const Text(
                              'Error analyzing image',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
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
                    )
                  : ListView(
                      controller: controller,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Image
                        Container(
                          height: 200,
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
                            child: Image.memory(
                              widget.imageBytes as Uint8List,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Detected Ingredients
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Detected Ingredients',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B5E20),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_detectedIngredients.isEmpty)
                                  const Text(
                                    'No ingredients detected. Try a clearer photo.',
                                    style: TextStyle(color: Colors.grey),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _detectedIngredients.map((
                                      ingredient,
                                    ) {
                                      return Chip(
                                        label: Text(ingredient),
                                        backgroundColor: const Color(
                                          0xFFE8F5E9,
                                        ),
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
                        ),
                        const SizedBox(height: 16),

                        // Nutrition
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nutrition Information',
                                  style: TextStyle(
                                    fontSize: 18,
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
                        ),
                      ],
                    ),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
