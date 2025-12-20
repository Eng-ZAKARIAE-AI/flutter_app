import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import '../models/food_item.dart';

class FoodService {
  final String _model = 'gemini-1.5-pro';

  String get _apiKey => dotenv.env['GOOGLE_AI_API_KEY'] ?? '';

  FoodService() {
    if (_apiKey.isEmpty) {
      throw Exception('Google AI API key not found in environment variables');
    }
    Gemini.init(apiKey: _apiKey);
  }

  Future<Either<String, FoodItem>> detectFoodAndCalories(File imageFile) async {
    try {
      if (!imageFile.existsSync()) {
        return Left('File not found: ${imageFile.path}');
      }

      final response = await Gemini.instance.textAndImage(
        text: '''
Analyze this image and identify the food.

Estimate:
- calories (kcal)
- protein (g)
- carbs (g)
- fat (g)

IMPORTANT:
Return ONLY valid JSON.
No markdown.
No explanations.

FORMAT:
{"name":"food name","calories":100,"protein":10,"carbs":20,"fat":5}
''',
        images: [imageFile.readAsBytesSync()],
      );

      final output = response?.output?.trim();
      if (output == null || output.isEmpty) {
        return Left('No response output from Gemini API');
      }

      // Nettoyage sécurisé (si Gemini ajoute ```json)
      final cleanedOutput = output
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      Map<String, dynamic> foodData;
      try {
        foodData = jsonDecode(cleanedOutput);
      } catch (_) {
        return Left('Invalid JSON returned: $cleanedOutput');
      }

      // Validation minimale
      if (!foodData.containsKey('name') ||
          !foodData.containsKey('calories') ||
          !foodData.containsKey('protein') ||
          !foodData.containsKey('carbs') ||
          !foodData.containsKey('fat')) {
        return Left('Incomplete nutrition data');
      }

      return Right(
        FoodItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: foodData['name'].toString(),
          calories: (foodData['calories'] as num).toDouble(),
          protein: (foodData['protein'] as num).toDouble(),
          carbs: (foodData['carbs'] as num).toDouble(),
          fat: (foodData['fat'] as num).toDouble(),
          quantity: 100.0,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      return Left('Failed to detect food: ${e.toString()}');
    }
  }
}
