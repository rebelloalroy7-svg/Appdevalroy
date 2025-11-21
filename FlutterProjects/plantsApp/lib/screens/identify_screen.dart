import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/plant.dart';
import '../services/image_identification_service.dart';
import '../services/plant_api_service.dart';
import 'plant_detail_screen.dart';

class IdentifyScreen extends StatefulWidget {
  const IdentifyScreen({super.key});

  static const routeName = '/identify';

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends State<IdentifyScreen> {
  File? _selectedImage;
  Map<String, dynamic>? _identificationResult;
  Plant? _plantDetails;
  bool _isIdentifying = false;
  bool _isLoadingDetails = false;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return;

    setState(() {
      _selectedImage = File(pickedFile.path);
      _identificationResult = null;
      _plantDetails = null;
      _error = null;
    });

    await _identifyPlant();
  }

  Future<void> _identifyPlant() async {
    if (_selectedImage == null) return;

    setState(() {
      _isIdentifying = true;
      _error = null;
    });

    try {
      final imageService = context.read<ImageIdentificationService>();
      final result = await imageService.identifyPlant(_selectedImage!);

      if (!mounted) return;

      setState(() {
        _identificationResult = result;
        _isIdentifying = false;
      });

      // Auto-load detailed information
      await _loadPlantDetails(result['name'] as String);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isIdentifying = false;
      });
    }
  }

  Future<void> _loadPlantDetails(String plantName) async {
    setState(() {
      _isLoadingDetails = true;
      _error = null;
    });

    try {
      final apiService = context.read<PlantApiService>();
      final plants = await apiService.searchPlants(plantName);

      if (!mounted) return;

      if (plants.isNotEmpty) {
        // Use the first result (most relevant)
        setState(() {
          _plantDetails = plants.first;
          _isLoadingDetails = false;
        });
      } else {
        setState(() {
          _isLoadingDetails = false;
          _error = 'Plant details not found in database';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingDetails = false;
        _error = 'Failed to load plant details: ${e.toString()}';
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Identify Plant')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview Section
            Card(
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: 1,
                child: _selectedImage == null
                    ? Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No image selected',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            // Image Selection Buttons
            FilledButton.icon(
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Select Image'),
              onPressed: _isIdentifying || _isLoadingDetails
                  ? null
                  : _showImageSourceDialog,
            ),
            const SizedBox(height: 24),
            // Loading Indicator
            if (_isIdentifying)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Identifying plant...',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            // Identification Result
            if (_identificationResult != null && !_isIdentifying) ...[
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_florist,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Identified Plant',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _identificationResult!['name'] as String,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Confidence: ${((_identificationResult!['accuracy'] as double) * 100).toStringAsFixed(1)}%',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Loading Plant Details
            if (_isLoadingDetails)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading plant details...',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            // Plant Details Card
            if (_plantDetails != null && !_isLoadingDetails) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plant Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_plantDetails!.imageUrl.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _plantDetails!.imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        _plantDetails!.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _plantDetails!.scientificName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (_plantDetails!.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _plantDetails!.description,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.info_outline),
                        label: const Text('View Full Details'),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            PlantDetailScreen.routeName,
                            arguments: _plantDetails,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Error Message
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
