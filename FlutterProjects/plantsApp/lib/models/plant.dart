class Plant {
  const Plant({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.medicinalUses,
    required this.imageUrl,
    required this.sunlight,
    required this.watering,
    required this.propagation,
    required this.toxicity,
  });

  final String id;
  final String name;
  final String scientificName;
  final String description;
  final List<String> medicinalUses;
  final String imageUrl;
  final String sunlight;
  final String watering;
  final String propagation;
  final String toxicity;

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientificName'] as String,
      description: json['description'] as String,
      medicinalUses: (json['medicinalUses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imageUrl: json['imageUrl'] as String,
      sunlight: json['sunlight'] as String,
      watering: json['watering'] as String,
      propagation: json['propagation'] as String,
      toxicity: json['toxicity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'description': description,
      'medicinalUses': medicinalUses,
      'imageUrl': imageUrl,
      'sunlight': sunlight,
      'watering': watering,
      'propagation': propagation,
      'toxicity': toxicity,
    };
  }
}
