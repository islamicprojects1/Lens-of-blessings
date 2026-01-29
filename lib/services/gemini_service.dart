import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lens_of_blessings/services/storage_service.dart';

/// Result of image analysis
class GeminiAnalysisResult {
  final List<String> blessings;
  final String? rawResponse;
  final String? usedModel;

  GeminiAnalysisResult({
    required this.blessings,
    this.rawResponse,
    this.usedModel,
  });
}

/// Metadata for Gemini models
class GeminiModelConfig {
  final String id;
  final String name;
  final int dailyLimit;

  const GeminiModelConfig({
    required this.id,
    required this.name,
    required this.dailyLimit,
  });
}

/// GeminiService - Optimized for gemini-2.5-flash
class GeminiService extends GetxService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  final StorageService _storageService = Get.find<StorageService>();

  static const List<GeminiModelConfig> availableModels = [
    GeminiModelConfig(
      id: 'gemini-2.5-flash',
      name: 'Gemini 2.5 Flash',
      dailyLimit: 20,
    ),
    GeminiModelConfig(
      id: 'gemini-2.5-flash-lite',
      name: 'Gemini 2.5 Flash Lite',
      dailyLimit: 20,
    ),
    GeminiModelConfig(
      id: 'gemini-3-flash',
      name: 'Gemini 3 Flash',
      dailyLimit: 20,
    ),
    GeminiModelConfig(
      id: 'gemini-2.5-flash-tts',
      name: 'Gemini 2.5 Flash TTS',
      dailyLimit: 10,
    ),
    GeminiModelConfig(
      id: 'gemini-robotics-er-1.5-preview',
      name: 'Gemini Robotics ER 1.5',
      dailyLimit: 20,
    ),
    GeminiModelConfig(
      id: 'gemma-3-27b',
      name: 'Gemma 3 27B',
      dailyLimit: 14400,
    ),
    GeminiModelConfig(
      id: 'gemma-3-12b',
      name: 'Gemma 3 12B',
      dailyLimit: 14400,
    ),
    GeminiModelConfig(id: 'gemma-3-4b', name: 'Gemma 3 4B', dailyLimit: 14400),
    GeminiModelConfig(id: 'gemma-3-2b', name: 'Gemma 3 2B', dailyLimit: 14400),
    GeminiModelConfig(id: 'gemma-3-1b', name: 'Gemma 3 1B', dailyLimit: 14400),
  ];

  /// Get models to try (selected first, then others if quota allows)
  List<String> _getModelsToTry() {
    final selectedId = _storageService.getSelectedGeminiModel();
    final models = [selectedId];

    // Add others as fallback if not selected
    for (var m in availableModels) {
      if (m.id != selectedId) {
        models.add(m.id);
      }
    }
    return models;
  }

  static const String _promptTemplate = '''
Analyze this image and identify exactly 3 distinct 'blessings' (graces or positive elements) that are CURRENTLY PRESENT in the photo. 
Focus on what is visible (e.g., the beauty of nature, the comfort of home, the gift of health, technology, knowledge, focus, etc.).

CRITICAL RULES:
1. Do NOT write prayers, supplications, or future wishes (No Duas). 
2. Do NOT use phrases like 'May God...', 'I wish...', or 'I hope...'.
3. Instead, ACKNOWLEDGE the existing grace as a present reality. (e.g., 'The blessing of knowledge and technology at your fingertips').
4. Be very specific to the unique details you see in the image. 
5. Each blessing should be 5-15 words.
6. Respond in {language}.
{userContext}

Return ONLY valid JSON:
{
  "blessings": ["blessing 1", "blessing 2", "blessing 3"]
}
''';

  static const Map<String, List<String>> _fallbackBlessings = {
    'en': [
      'The blessing of being present in this moment',
      'The blessing of being able to see and reflect',
      'The blessing of seeking beauty in life',
    ],
    'ar': [
      'نعمة أن تكون موجوداً في هذه اللحظة',
      'نعمة القدرة على الرؤية والتأمل',
      'نعمة البحث عن الجمال في الحياة',
    ],
  };

  Future<GeminiAnalysisResult> analyzeImage({
    required Uint8List imageBytes,
    required String language,
    String? userNote,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('❌ GeminiService: API key is missing');
      return GeminiAnalysisResult(blessings: getFallbackBlessings(language));
    }

    final modelsToTry = _getModelsToTry();

    for (String modelId in modelsToTry) {
      // Check quota
      final config = availableModels.firstWhere(
        (m) => m.id == modelId,
        orElse: () =>
            GeminiModelConfig(id: modelId, name: modelId, dailyLimit: 0),
      );

      final currentUsage = _storageService.getModelUsage(modelId);
      if (currentUsage >= config.dailyLimit && config.dailyLimit > 0) {
        print(
          '🚫 Quota reached for $modelId ($currentUsage/${config.dailyLimit})',
        );
        continue;
      }

      try {
        print(
          '🔎 GeminiService: Trying model [$modelId] ($currentUsage/${config.dailyLimit})...',
        );
        final result = await _attemptAnalysis(
          model: modelId,
          imageBytes: imageBytes,
          language: language,
          userNote: userNote,
          apiKey: apiKey,
        );

        if (result != null) {
          print('✅ SUCCESS with model: $modelId');
          // Update usage
          await _storageService.incrementModelUsage(modelId);
          _storageService.triggerUpdate(); // Trigger UI update
          
          return GeminiAnalysisResult(
            blessings: result.blessings,
            rawResponse: result.rawResponse,
            usedModel: modelId,
          );
        }
      } catch (e) {
        print('⚠️ Model [$modelId] failed: $e');
      }
    }

    print('❌ All models failed or quota reached. Returning fallback.');
    return GeminiAnalysisResult(blessings: getFallbackBlessings(language));
  }

  Future<GeminiAnalysisResult?> _attemptAnalysis({
    required String model,
    required Uint8List imageBytes,
    required String language,
    String? userNote,
    required String apiKey,
  }) async {
    final url = Uri.parse('$_baseUrl/$model:generateContent?key=$apiKey');
    final base64Image = base64Encode(imageBytes);
    final prompt = _buildPrompt(language, userNote);

    final bool isModernModel =
        model.contains('1.5') || model.contains('2.0') || model.contains('2.5');

    final Map<String, dynamic> generationConfig = {
      "temperature": 0.7,
      "maxOutputTokens": 2048,
    };

    if (isModernModel) {
      generationConfig["responseMimeType"] = "application/json";
    }

    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
            },
          ],
        },
      ],
      "generationConfig": generationConfig,
    };

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 40));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['candidates'] != null &&
          jsonResponse['candidates'].isNotEmpty) {
        final text =
            jsonResponse['candidates'][0]['content']['parts'][0]['text'];

        debugPrint('📄 AI Response: $text');

        return GeminiAnalysisResult(
          blessings: _parseResponse(text),
          rawResponse: text,
        );
      }
    } else if (response.statusCode == 400 && isModernModel) {
      print('🔄 Retrying [$model] without JSON mode...');
      return _attemptSimple(model, imageBytes, language, userNote, apiKey);
    }
    return null;
  }

  Future<GeminiAnalysisResult?> _attemptSimple(
    String model,
    Uint8List imageBytes,
    String language,
    String? userNote,
    String apiKey,
  ) async {
    final url = Uri.parse('$_baseUrl/$model:generateContent?key=$apiKey');
    final base64Image = base64Encode(imageBytes);
    final prompt = _buildPrompt(language, userNote);

    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
            },
          ],
        },
      ],
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final text = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      return GeminiAnalysisResult(
        blessings: _parseResponse(text),
        rawResponse: text,
      );
    }
    return null;
  }

  String _buildPrompt(String language, String? userNote) {
    String userContext = '';
    if (userNote != null && userNote.trim().isNotEmpty) {
      userContext = '\nUser context: "$userNote"';
    }

    return _promptTemplate
        .replaceAll('{language}', language == 'ar' ? 'Arabic' : 'English')
        .replaceAll('{userContext}', userContext);
  }

  List<String> _parseResponse(String text) {
    try {
      String cleanedText = text.trim();
      if (cleanedText.contains('```')) {
        final start = cleanedText.indexOf('{');
        final end = cleanedText.lastIndexOf('}');
        if (start != -1 && end != -1) {
          cleanedText = cleanedText.substring(start, end + 1);
        }
      }
      final Map<String, dynamic> data = jsonDecode(cleanedText);
      if (data['blessings'] != null) {
        return List<String>.from(data['blessings']);
      }
    } catch (e) {
      print('❌ Parse Error: $e');
    }
    return [];
  }

  List<String> getFallbackBlessings(String language) {
    return _fallbackBlessings[language] ?? _fallbackBlessings['en']!;
  }
}
