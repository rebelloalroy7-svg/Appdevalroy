import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/plant.dart';
import '../services/plant_service.dart';
import '../services/user_preferences_service.dart';
import 'care_planner_screen.dart';
import 'identify_screen.dart';
import 'plant_detail_screen.dart';

class PlantKnowledgeScreen extends StatefulWidget {
  const PlantKnowledgeScreen({super.key});

  static const routeName = '/knowledge';

  @override
  State<PlantKnowledgeScreen> createState() => _PlantKnowledgeScreenState();
}

class _PlantKnowledgeScreenState extends State<PlantKnowledgeScreen> {
  final List<String> _lightFilters = const [
    'Bright light',
    'Low light',
    'Pet friendly',
  ];
  String _selectedFilter = 'Bright light';
  final List<_Tip> _tips = const [
    _Tip(
      title: 'Rotate pots monthly',
      body:
          'Rotating plants prevents them from leaning toward a single light source and promotes even growth.',
    ),
    _Tip(
      title: 'Group humidity lovers',
      body:
          'Placing humidity-loving plants together helps maintain moisture levels without constant misting.',
    ),
    _Tip(
      title: 'Feed during active growth',
      body:
          'Most houseplants benefit from diluted fertilizer every 4–6 weeks during spring and summer.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<UserPreferencesService>();
    final plantService = context.watch<PlantService>();
    final recommended = _filterPlants(plantService.allPlants);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Hub'),
        actions: [
          IconButton(
            tooltip: 'Open care planner',
            icon: const Icon(Icons.event_note),
            onPressed: () =>
                Navigator.pushNamed(context, PlantCarePlannerScreen.routeName),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Your plant snapshot',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Favourites',
                  value: prefs.favoritePlantIds.length.toString(),
                  icon: Icons.favorite,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Recent searches',
                  value: prefs.searchHistory.length.toString(),
                  icon: Icons.history,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Recently viewed',
                  value: prefs.recentPlantIds.length.toString(),
                  icon: Icons.visibility,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need to identify a plant?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jump straight into the identifier with one tap.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                  ),
                  onPressed: () =>
                      Navigator.pushNamed(context, IdentifyScreen.routeName),
                  icon: const Icon(Icons.photo_camera_back),
                  label: const Text('Open Identifier'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recommended for ${_selectedFilter.toLowerCase()}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _lightFilters
                .map(
                  (filter) => ChoiceChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (value) {
                      if (value) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          if (recommended.isEmpty)
            Text(
              'No matches yet. Add more plants to the library to unlock insights.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...recommended.map(
              (plant) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: plant.imageUrl.isNotEmpty
                        ? NetworkImage(plant.imageUrl)
                        : null,
                    child: plant.imageUrl.isEmpty
                        ? const Icon(Icons.local_florist)
                        : null,
                  ),
                  title: Text(plant.name),
                  subtitle: Text(plant.sunlight),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(
                    context,
                    PlantDetailScreen.routeName,
                    arguments: plant,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text('Care tips', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ..._tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(tip.title),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [Text(tip.body)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Plant> _filterPlants(List<Plant> plants) {
    switch (_selectedFilter) {
      case 'Low light':
        return plants
            .where((plant) => plant.sunlight.toLowerCase().contains('low'))
            .toList();
      case 'Pet friendly':
        return plants
            .where((plant) => plant.toxicity.toLowerCase().contains('non'))
            .toList();
      case 'Bright light':
      default:
        return plants
            .where((plant) => plant.sunlight.toLowerCase().contains('bright'))
            .toList();
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Tip {
  const _Tip({required this.title, required this.body});

  final String title;
  final String body;
}


