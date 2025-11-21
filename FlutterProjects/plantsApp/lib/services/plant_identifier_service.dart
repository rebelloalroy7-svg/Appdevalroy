import 'dart:async';

import 'package:image_picker/image_picker.dart';

import '../models/plant.dart';
import 'plant_service.dart';

class PlantIdentifierService {
  PlantIdentifierService(this._plantService);

  final PlantService _plantService;
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage() {
    return _picker.pickImage(source: ImageSource.gallery);
  }

  Future<Plant?> identifyPlant(XFile image) async {
    // Placeholder ML logic. Replace with a real ML/vision API integration.
    await Future<void>.delayed(const Duration(seconds: 2));
    final plants = _plantService.allPlants;
    if (plants.isEmpty) return null;
    return plants.first;
  }
}
