import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/plant.dart';

class PlantApiService {
  PlantApiService({String? apiKey}) : _apiKey = apiKey;

  final String? _apiKey;
  // Using Trefle.io API - free public access
  static const String _baseUrl = 'https://trefle.io/api/v1';

  /// Search for plants using a query string
  /// Returns a list of Plant objects matching the search query
  Future<List<Plant>> searchPlants(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    // Try Perenual API first (free tier, works with or without key)
    try {
      final perenualUri = Uri.parse(
        'https://perenual.com/api/species-list?key=$_apiKey&q=${Uri.encodeComponent(query)}&page=1',
      );
      final perenualResponse = await http
          .get(perenualUri)
          .timeout(const Duration(seconds: 10));

      if (perenualResponse.statusCode == 200) {
        final jsonData =
            json.decode(perenualResponse.body) as Map<String, dynamic>?;
        if (jsonData != null && jsonData.containsKey('data')) {
          final data = jsonData['data'] as List<dynamic>?;
          if (data != null && data.isNotEmpty) {
            final plants = data
                .map((item) {
                  try {
                    return _parsePlantFromPerenual(
                      item as Map<String, dynamic>,
                    );
                  } catch (e) {
                    return null;
                  }
                })
                .whereType<Plant>()
                .toList();
            if (plants.isNotEmpty) {
              return plants;
            }
          }
        }
      }
    } catch (e) {
      // Continue to next API
    }

    // Fallback to Trefle.io
    try {
      final uri = Uri.parse(
        '$_baseUrl/plants/search?q=${Uri.encodeComponent(query)}',
      );

      final headers = <String, String>{'Content-Type': 'application/json'};

      if (_apiKey != null && _apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_apiKey';
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>?;
        if (jsonData != null && jsonData.containsKey('data')) {
          final data = jsonData['data'] as List<dynamic>?;
          if (data != null && data.isNotEmpty) {
            return data
                .map((item) {
                  try {
                    return _parsePlantFromList(item as Map<String, dynamic>);
                  } catch (e) {
                    return null;
                  }
                })
                .whereType<Plant>()
                .toList();
          }
        }
      }
    } catch (e) {
      // Continue to fallback
    }

    // Final fallback - return sample data for demonstration
    return _getSamplePlants(query);
  }

  /// Get sample plants as fallback (for demonstration)
  List<Plant> _getSamplePlants(String query) {
    final queryLower = query.toLowerCase();
    final samplePlants = <Plant>[];

    // Common plants that might match the search
    final commonPlants = [
      {
        'name': 'Rose',
        'scientific': 'Rosa',
        'image':
            'https://images.unsplash.com/photo-1518621012420-8d0e1b8e3b8e?w=400',
        'description':
            'Roses are woody perennial flowering plants known for their beautiful, fragrant flowers.',
      },
      {
        'name': 'Sunflower',
        'scientific': 'Helianthus annuus',
        'image':
            'https://images.unsplash.com/photo-1597848212624-e593b98b5dc2?w=400',
        'description':
            'Sunflowers are tall annual plants with large, bright yellow flower heads.',
      },
      {
        'name': 'Tulip',
        'scientific': 'Tulipa',
        'image':
            'https://images.unsplash.com/photo-1520763185298-1b434c919102?w=400',
        'description':
            'Tulips are spring-blooming perennial herbaceous bulbiferous geophytes.',
      },
      {
        'name': 'Lavender',
        'scientific': 'Lavandula',
        'image':
            'https://images.unsplash.com/photo-1499002238440-d264edd596ec?w=400',
        'description':
            'Lavender is a flowering plant known for its fragrant purple flowers and calming properties.',
      },
      {
        'name': 'Basil',
        'scientific': 'Ocimum basilicum',
        'image':
            'https://images.unsplash.com/photo-1618375569909-2c8786f4ab33?w=400',
        'description':
            'Basil is a culinary herb of the family Lamiaceae, native to tropical regions.',
      },
    ];

    for (final plant in commonPlants) {
      if (plant['name']!.toString().toLowerCase().contains(queryLower) ||
          plant['scientific']!.toString().toLowerCase().contains(queryLower)) {
        samplePlants.add(
          Plant(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: plant['name'] as String,
            scientificName: plant['scientific'] as String,
            description: plant['description'] as String,
            medicinalUses: [],
            imageUrl: plant['image'] as String,
            sunlight: 'Full sun to partial shade',
            watering: 'Moderate',
            propagation: 'Seeds, cuttings',
            toxicity: 'Non-toxic',
          ),
        );
      }
    }

    // If no matches, return a generic result
    if (samplePlants.isEmpty) {
      samplePlants.add(
        Plant(
          id: '1',
          name: 'Plant: $query',
          scientificName: 'Search result',
          description:
              'Plant information for $query. This is a sample result. Connect to a plant API for detailed information.',
          medicinalUses: [],
          imageUrl:
              'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400',
          sunlight: 'Varies by species',
          watering: 'Varies by species',
          propagation: 'Varies by species',
          toxicity: 'Unknown',
        ),
      );
    }

    return samplePlants;
  }

  /// Get detailed information about a specific plant by ID
  /// Returns a Plant object with full details
  Future<Plant> getPlantDetails(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/plants/$id');
      final headers = <String, String>{'Content-Type': 'application/json'};

      if (_apiKey != null && _apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_apiKey';
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>?;
        if (jsonData != null && jsonData.containsKey('data')) {
          return _parsePlantFromDetails(
            jsonData['data'] as Map<String, dynamic>,
          );
        }
      }

      // Return basic plant info if details fetch fails
      return Plant(
        id: id.toString(),
        name: 'Plant Details',
        scientificName: 'Unknown',
        description: 'Details not available for this plant',
        medicinalUses: [],
        imageUrl: '',
        sunlight: 'Unknown',
        watering: 'Unknown',
        propagation: 'Unknown',
        toxicity: 'Unknown',
      );
    } catch (e) {
      throw Exception('Error getting plant details: $e');
    }
  }

  /// Parse a plant from Trefle API search response
  Plant _parsePlantFromList(Map<String, dynamic> json) {
    // Get image URL - Trefle provides image_url directly
    String imageUrl = json['image_url'] as String? ?? '';

    // If no direct image_url, try to get from images array
    if (imageUrl.isEmpty) {
      final images = json['images'] as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        final firstImage = images[0] as Map<String, dynamic>?;
        if (firstImage != null) {
          imageUrl =
              firstImage['url'] as String? ??
              firstImage['image_url'] as String? ??
              '';
        }
      }
    }

    return Plant(
      id: json['id']?.toString() ?? '0',
      name:
          json['common_name'] as String? ??
          (json['scientific_name'] as String? ?? 'Unknown Plant'),
      scientificName: json['scientific_name'] as String? ?? 'Unknown',
      description:
          json['description'] as String? ??
          json['observations'] as String? ??
          '',
      medicinalUses: _extractMedicinalUses(json),
      imageUrl: imageUrl,
      sunlight: _formatSunlight(json['sunlight']),
      watering: _formatWatering(
        json['watering'] ?? json['watering_general_benchmark'],
      ),
      propagation: _formatPropagation(json['propagation']),
      toxicity: _formatToxicity(json),
    );
  }

  /// Parse a plant from Perenual API
  Plant _parsePlantFromPerenual(Map<String, dynamic> json) {
    String imageUrl = '';
    final defaultImage = json['default_image'];
    if (defaultImage != null && defaultImage is Map<String, dynamic>) {
      imageUrl =
          defaultImage['regular_url'] as String? ??
          defaultImage['medium_url'] as String? ??
          defaultImage['thumbnail'] as String? ??
          '';
    }

    final commonName = json['common_name'] as String? ?? 'Unknown Plant';
    final scientificName = json['scientific_name'] as List<dynamic>?;
    final scientificNameStr =
        scientificName != null && scientificName.isNotEmpty
        ? scientificName[0].toString()
        : 'Unknown';

    return Plant(
      id: json['id']?.toString() ?? '0',
      name: commonName,
      scientificName: scientificNameStr,
      description: json['description'] as String? ?? '',
      medicinalUses: [],
      imageUrl: imageUrl,
      sunlight: _formatSunlight(json['sunlight']),
      watering: _formatWatering(
        json['watering'] ?? json['watering_general_benchmark'],
      ),
      propagation: _formatPropagation(json['propagation']),
      toxicity: _formatToxicityPerenual(json),
    );
  }

  /// Parse a plant from Trefle details API response
  Plant _parsePlantFromDetails(Map<String, dynamic> json) {
    String imageUrl = json['image_url'] as String? ?? '';

    if (imageUrl.isEmpty) {
      final images = json['images'] as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        final firstImage = images[0] as Map<String, dynamic>?;
        if (firstImage != null) {
          imageUrl =
              firstImage['url'] as String? ??
              firstImage['image_url'] as String? ??
              '';
        }
      }
    }

    return Plant(
      id: json['id']?.toString() ?? '0',
      name:
          json['common_name'] as String? ??
          (json['scientific_name'] as String? ?? 'Unknown Plant'),
      scientificName: json['scientific_name'] as String? ?? 'Unknown',
      description:
          json['description'] as String? ??
          json['observations'] as String? ??
          '',
      medicinalUses: _extractMedicinalUses(json),
      imageUrl: imageUrl,
      sunlight: _formatSunlight(json['sunlight']),
      watering: _formatWatering(
        json['watering'] ?? json['watering_general_benchmark'],
      ),
      propagation: _formatPropagation(json['propagation']),
      toxicity: _formatToxicity(json),
    );
  }

  /// Extract medicinal uses from the JSON data
  List<String> _extractMedicinalUses(Map<String, dynamic> json) {
    final uses = <String>[];
    final usesField = json['uses'];
    if (usesField is List) {
      uses.addAll(
        usesField.map((e) => e.toString()).where((e) => e.isNotEmpty),
      );
    } else if (usesField is String && usesField.isNotEmpty) {
      uses.add(usesField);
    }
    final medicinal = json['medicinal'];
    if (medicinal is String && medicinal.isNotEmpty) {
      uses.add(medicinal);
    }
    return uses;
  }

  /// Format sunlight array into a readable string
  String _formatSunlight(dynamic sunlight) {
    if (sunlight == null) {
      return 'Unknown';
    }
    if (sunlight is List) {
      if (sunlight.isEmpty) return 'Unknown';
      return sunlight.map((e) => e.toString()).join(', ');
    }
    return sunlight.toString();
  }

  /// Format propagation array into a readable string
  String _formatPropagation(dynamic propagation) {
    if (propagation == null) return 'Unknown';
    if (propagation is List) {
      if (propagation.isEmpty) return 'Unknown';
      return propagation.map((e) => e.toString()).join(', ');
    }
    return propagation.toString();
  }

  String _formatWatering(dynamic value) {
    if (value == null) return 'Unknown';
    if (value is String && value.isNotEmpty) return value;
    if (value is Map<String, dynamic>) {
      final amount = value['value'];
      final unit = value['unit'];
      if (amount != null && unit != null) {
        return '$amount $unit';
      }
      return value.values.join(' ');
    }
    if (value is List) {
      if (value.isEmpty) return 'Unknown';
      return value.map((e) => e.toString()).join(', ');
    }
    return value.toString();
  }

  /// Format toxicity information from Trefle
  String _formatToxicity(Map<String, dynamic> json) {
    final toxicity = json['toxicity'] as String?;
    if (toxicity != null && toxicity.isNotEmpty) {
      return toxicity;
    }
    // Check for other toxicity fields
    final edible = json['edible'] as bool?;
    if (edible != null) {
      return edible ? 'Edible' : 'Not edible';
    }
    return 'Unknown';
  }

  /// Format toxicity information from Perenual API
  String _formatToxicityPerenual(Map<String, dynamic> json) {
    final toxicity = json['poisonous_to_humans'] as int?;
    if (toxicity == 1) {
      return 'Toxic to humans';
    } else if (toxicity == 0) {
      return 'Non-toxic';
    }
    return 'Unknown';
  }
}
