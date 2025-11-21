import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/plant.dart';
import '../services/plant_api_service.dart';
import '../services/user_preferences_service.dart';

class PlantDetailScreen extends StatefulWidget {
  const PlantDetailScreen({super.key});

  static const routeName = '/plant-detail';

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  Plant? _plant;
  bool _loadingDetails = false;
  String? _error;
  bool _trackedView = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (_plant == null && args is Plant) {
      _plant = args;
      _trackRecentlyViewed(args.id);
      _maybeFetchAdditionalDetails();
    }
  }

  Future<void> _trackRecentlyViewed(String plantId) async {
    if (_trackedView) return;
    _trackedView = true;
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    // ignore: discarded_futures
    context.read<UserPreferencesService>().addRecentlyViewed(plantId);
  }

  Future<void> _maybeFetchAdditionalDetails() async {
    final plant = _plant;
    if (plant == null) return;

    final needsMoreData =
        plant.description.isEmpty ||
        plant.sunlight.toLowerCase() == 'unknown' ||
        plant.watering.toLowerCase() == 'unknown' ||
        plant.medicinalUses.isEmpty;

    final numericId = int.tryParse(plant.id);
    if (!needsMoreData || numericId == null) {
      return;
    }

    setState(() {
      _loadingDetails = true;
      _error = null;
    });

    try {
      final api = context.read<PlantApiService>();
      final fresh = await api.getPlantDetails(numericId);
      if (!mounted) return;
      setState(() {
        _plant = _mergePlantData(plant, fresh);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load extended details. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingDetails = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plant = _plant;
    if (plant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Plant Details')),
        body: const Center(child: Text('No plant data provided.')),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Consumer<UserPreferencesService>(
            builder: (context, userPrefs, _) {
              final isFavorite = userPrefs.isFavorite(plant.id);
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    actions: [
                      IconButton(
                        tooltip: isFavorite
                            ? 'Remove from favourites'
                            : 'Add to favourites',
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? theme.colorScheme.error
                              : theme.colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          // ignore: discarded_futures
                          context.read<UserPreferencesService>().toggleFavorite(
                            plant.id,
                          );
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeroImage(theme, plant),
                      title: Text(plant.name),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plant.scientificName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_error != null)
                            _ErrorBanner(
                              message: _error!,
                              onRetry: _maybeFetchAdditionalDetails,
                            ),
                          if (plant.description.isNotEmpty) ...[
                            _buildSectionHeader(theme, 'Description'),
                            const SizedBox(height: 8),
                            Text(
                              plant.description,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 24),
                          ],
                          _buildSectionHeader(theme, 'Care Information'),
                          const SizedBox(height: 12),
                          _buildCareCard(
                            context,
                            theme,
                            Icons.wb_sunny,
                            'Sunlight',
                            plant.sunlight,
                            theme.colorScheme.primaryContainer,
                            theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(height: 12),
                          _buildCareCard(
                            context,
                            theme,
                            Icons.water_drop,
                            'Watering',
                            plant.watering,
                            theme.colorScheme.secondaryContainer,
                            theme.colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(height: 12),
                          _buildCareCard(
                            context,
                            theme,
                            Icons.grass,
                            'Propagation',
                            plant.propagation,
                            theme.colorScheme.tertiaryContainer,
                            theme.colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(height: 24),
                          if (plant.medicinalUses.isNotEmpty) ...[
                            _buildSectionHeader(theme, 'Medicinal Uses'),
                            const SizedBox(height: 12),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: plant.medicinalUses.map((use) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.medical_services,
                                            size: 20,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              use,
                                              style: theme.textTheme.bodyLarge,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          _buildSectionHeader(theme, 'Safety Information'),
                          const SizedBox(height: 12),
                          _buildToxicityCard(context, theme, plant.toxicity),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (_loadingDetails)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(ThemeData theme, Plant plant) {
    if (plant.imageUrl.isEmpty) {
      return Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.local_florist,
          size: 100,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return Image.network(
      plant.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.local_florist,
            size: 100,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

  Plant _mergePlantData(Plant base, Plant details) {
    return Plant(
      id: base.id,
      name: base.name.isNotEmpty ? base.name : details.name,
      scientificName: base.scientificName.isNotEmpty
          ? base.scientificName
          : details.scientificName,
      description: base.description.isNotEmpty
          ? base.description
          : details.description,
      medicinalUses: base.medicinalUses.isNotEmpty
          ? base.medicinalUses
          : details.medicinalUses,
      imageUrl: base.imageUrl.isNotEmpty ? base.imageUrl : details.imageUrl,
      sunlight: _preferField(base.sunlight, details.sunlight),
      watering: _preferField(base.watering, details.watering),
      propagation: _preferField(base.propagation, details.propagation),
      toxicity: _preferField(base.toxicity, details.toxicity),
    );
  }

  String _preferField(String primary, String fallback) {
    if (primary.trim().isEmpty || primary.toLowerCase() == 'unknown') {
      return fallback;
    }
    return primary;
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildCareCard(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    Color containerColor,
    Color onContainerColor,
  ) {
    return Card(
      color: containerColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: onContainerColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: onContainerColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: onContainerColor,
                      fontWeight: FontWeight.w500,
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

  Widget _buildToxicityCard(
    BuildContext context,
    ThemeData theme,
    String toxicity,
  ) {
    final isToxic = toxicity.toLowerCase().contains('toxic');
    final colorScheme = theme.colorScheme;

    return Card(
      color: isToxic
          ? colorScheme.errorContainer
          : colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isToxic ? Icons.warning : Icons.check_circle,
              color: isToxic
                  ? colorScheme.onErrorContainer
                  : colorScheme.onTertiaryContainer,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toxicity',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isToxic
                          ? colorScheme.onErrorContainer
                          : colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    toxicity,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isToxic
                          ? colorScheme.onErrorContainer
                          : colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w500,
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
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
