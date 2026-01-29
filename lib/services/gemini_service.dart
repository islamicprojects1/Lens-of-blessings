import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// GeminiService - Optimized for gemini-2.5-flash based on user logs
class GeminiService extends GetxService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // القائمة مرتبة بناءً على النجاح السابق: 2.5 أولاً!
  final List<String> _modelsToTry = [
    'gemini-2.5-flash', // هذا اشتغل سابقاً
    'gemini-1.5-flash',
    'gemini-pro-vision',
  ];

  /// Prompt template
  static const String _promptTemplate = '''
Analyze this image and return exactly 3 short, meaningful blessings (5-15 words each).
Be specific and genuine. Respond in {language}.
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

  Future<List<String>> analyzeImage({
    required Uint8List imageBytes,
    required String language,
    String? userNote,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('❌ GeminiService: API key is missing');
      return getFallbackBlessings(language);
    }

    for (String model in _modelsToTry) {
      try {
        print('� GeminiService: Trying model [$model]...');
        final result = await _attemptAnalysis(
          model: model,
          imageBytes: imageBytes,
          language: language,
          userNote: userNote,
          apiKey: apiKey,
        );

        if (result != null && result.isNotEmpty) {
          print('✅ SUCCESS with model: $model');
          return result;
        }
      } catch (e) {
        print('⚠️ Model [$model] failed.');
      }
    }

    print('❌ All models failed. Returning fallback.');
    return getFallbackBlessings(language);
  }

  Future<List<String>?> _attemptAnalysis({
    required String model,
    required Uint8List imageBytes,
    required String language,
    String? userNote,
    required String apiKey,
  }) async {
    final url = Uri.parse('$_baseUrl/$model:generateContent?key=$apiKey');
    final base64Image = base64Encode(imageBytes);
    final prompt = _buildPrompt(language, userNote);

    // التحقق مما إذا كان الموديل حديثاً ويدعم JSON mode
    final bool isModernModel =
        model.contains('1.5') || model.contains('2.0') || model.contains('2.5');

    final Map<String, dynamic> generationConfig = {
      "temperature": 0.7,
      "maxOutputTokens": 2048, // زدنا الرقم جداً لمنع البتر
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

        // استخدام debugPrint لرؤية النص كاملاً في الكونسول
        debugPrint('📄 AI Response: $text');

        return _parseResponse(text, language);
      }
    } else {
      print('❌ [$model] Status: ${response.statusCode}');
      // إذا فشل بسبب JSON mode، نجرب مرة أخيرة بدونه
      if (response.statusCode == 400 && isModernModel) {
        print('🔄 Retrying [$model] without JSON mode...');
        return _attemptSimple(model, imageBytes, language, userNote, apiKey);
      }
    }
    return null;
  }

  /// محاولة بسيطة بدون تعقيدات الإعدادات
  Future<List<String>?> _attemptSimple(
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
      return _parseResponse(text, language);
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

  List<String> _parseResponse(String text, String language) {
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
