import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Service for identifying plants from images using Plant.id API
class ImageIdentificationService {
  ImageIdentificationService({String? apiKey}) : _apiKey = apiKey;

  final String? _apiKey;
  static const String _baseUrl = 'https://api.plant.id/v2/identify';

  /// Identifies a plant from an image file
  /// Returns a map with 'name' (plant name) and 'accuracy' (confidence score)
  Future<Map<String, dynamic>> identifyPlant(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      // Add API key if provided
      if (_apiKey != null) {
        request.headers['Api-Key'] = _apiKey;
      }

      // Add image file
      final imageBytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'images',
        imageBytes,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Add additional parameters if needed
      request.fields['modifiers'] = '["crops_fast", "similar_images"]';
      request.fields['plant_details'] =
          '["common_names", "url", "name_authority", "wiki_description", "taxonomy", "synonyms"]';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return _parseResponse(jsonData);
      } else {
        final errorBody = response.body;
        throw Exception(
          'Failed to identify plant: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error identifying plant: $e');
    }
  }

  /// Parse the API response to extract plant name and accuracy
  Map<String, dynamic> _parseResponse(Map<String, dynamic> json) {
    final suggestions = json['suggestions'] as List<dynamic>?;

    if (suggestions == null || suggestions.isEmpty) {
      throw Exception('No plant suggestions found in response');
    }

    // Get the top suggestion (highest confidence)
    final topSuggestion = suggestions[0] as Map<String, dynamic>;
    final plantDetails =
        topSuggestion['plant_details'] as Map<String, dynamic>?;

    // Extract plant name
    String plantName = 'Unknown Plant';
    if (plantDetails != null) {
      final commonNames = plantDetails['common_names'] as List<dynamic>?;
      if (commonNames != null && commonNames.isNotEmpty) {
        plantName = commonNames[0] as String;
      } else {
        plantName =
            plantDetails['scientific_name'] as String? ?? 'Unknown Plant';
      }
    } else {
      // Fallback to scientific name if available
      plantName = topSuggestion['plant_name'] as String? ?? 'Unknown Plant';
    }

    // Extract accuracy/confidence score
    final accuracy = (topSuggestion['probability'] as num?)?.toDouble() ?? 0.0;

    return {'name': plantName, 'accuracy': accuracy};
  }
}
