import 'package:flutter/foundation.dart';

import '../models/plant.dart';

class PlantService extends ChangeNotifier {
  PlantService() {
    _filteredPlants = _plants;
  }

  final List<Plant> _plants = [
    const Plant(
      id: '1',
      name: 'Monstera Deliciosa',
      scientificName: 'Monstera deliciosa',
      description: 'A tropical plant known for its split leaves.',
      medicinalUses: [],
      imageUrl:
          'https://images.unsplash.com/photo-1470246973918-29a93221c455?auto=format&fit=crop&w=600&q=80',
      sunlight: 'Bright, indirect light',
      watering: 'Water when top soil is dry',
      propagation: 'Stem cuttings',
      toxicity: 'Toxic to pets if ingested',
    ),
    const Plant(
      id: '2',
      name: 'Snake Plant',
      scientificName: 'Sansevieria trifasciata',
      description: 'A hardy plant that tolerates low light.',
      medicinalUses: ['Air purification'],
      imageUrl:
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=600&q=80',
      sunlight: 'Low to bright light',
      watering: 'Water sparingly',
      propagation: 'Division or leaf cuttings',
      toxicity: 'Mildly toxic to pets',
    ),
    const Plant(
      id: '3',
      name: 'Pilea Peperomioides',
      scientificName: 'Pilea peperomioides',
      description: 'Known as the Chinese money plant with round leaves.',
      medicinalUses: [],
      imageUrl:
          'https://images.unsplash.com/photo-1489602642804-64dea1e3ebc1?auto=format&fit=crop&w=600&q=80',
      sunlight: 'Bright, indirect light',
      watering: 'Water weekly',
      propagation: 'Offshoots or stem cuttings',
      toxicity: 'Non-toxic',
    ),
  ];

  late List<Plant> _filteredPlants;
  String _query = '';

  List<Plant> get plants => List.unmodifiable(_filteredPlants);
  List<Plant> get allPlants => List.unmodifiable(_plants);
  String get query => _query;

  Plant? byId(String id) => _plants.firstWhere(
    (plant) => plant.id == id,
    orElse: () => const Plant(
      id: '0',
      name: 'Unknown Plant',
      scientificName: 'Unknown',
      description: 'Details unavailable.',
      medicinalUses: [],
      imageUrl: '',
      sunlight: 'Unknown',
      watering: 'Unknown',
      propagation: 'Unknown',
      toxicity: 'Unknown',
    ),
  );

  void search(String value) {
    _query = value;
    if (value.trim().isEmpty) {
      _filteredPlants = _plants;
    } else {
      _filteredPlants = _plants
          .where(
            (plant) => plant.name.toLowerCase().contains(value.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }
}
