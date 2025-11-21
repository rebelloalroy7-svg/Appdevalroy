import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/plant_care_task.dart';
import '../services/plant_care_schedule_service.dart';

class PlantCarePlannerScreen extends StatelessWidget {
  const PlantCarePlannerScreen({super.key});

  static const routeName = '/care-planner';

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<PlantCareScheduleService>().tasks;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Care Planner'),
            Text(
              'Stay on top of watering & feeding',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: tasks.isEmpty
          ? _EmptyState(onAdd: () => _showAddTaskSheet(context))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _TaskTile(
                  task: task,
                  onComplete: () => context
                      .read<PlantCareScheduleService>()
                      .markCompleted(task.id),
                  onDelete: () => context
                      .read<PlantCareScheduleService>()
                      .removeTask(task.id),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: tasks.length,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context),
        icon: const Icon(Icons.add_task),
        label: const Text('New Reminder'),
      ),
    );
  }

  Future<void> _showAddTaskSheet(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    var selectedCareType = CareType.watering;
    double frequency = 3;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: bottomInset > 0 ? bottomInset + 20 : 40,
            top: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create care reminder',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Plant name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a plant name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<CareType>(
                        decoration: const InputDecoration(
                          labelText: 'Care type',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: selectedCareType,
                        items: CareType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedCareType = value;
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Repeat every ${frequency.round()} day(s)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Slider(
                        value: frequency,
                        min: 1,
                        max: 14,
                        divisions: 13,
                        label: '${frequency.round()} days',
                        onChanged: (value) {
                          setModalState(() {
                            frequency = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? false) {
                              context.read<PlantCareScheduleService>().addTask(
                                plantName: nameController.text,
                                careType: selectedCareType,
                                frequencyDays: frequency.round(),
                                notes: notesController.text,
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Save reminder'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
    nameController.dispose();
    notesController.dispose();
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onComplete,
    required this.onDelete,
  });

  final PlantCareTask task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDue = task.isDue;
    final chipColor = isDue
        ? colorScheme.errorContainer
        : colorScheme.secondaryContainer;
    final chipOnColor = isDue
        ? colorScheme.onErrorContainer
        : colorScheme.onSecondaryContainer;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: colorScheme.onErrorContainer),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete reminder?'),
                content: const Text('This action cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task.plantName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                FilledButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Done'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(task.careType.label),
                  avatar: Icon(_iconForType(task.careType)),
                  backgroundColor: chipColor,
                  labelStyle: TextStyle(color: chipOnColor),
                ),
                Chip(label: Text('Every ${task.frequencyDays} day(s)')),
                Chip(
                  label: Text(
                    task.isDue
                        ? 'Due now'
                        : 'Next on ${_formatDate(task.nextDue)}',
                  ),
                ),
              ],
            ),
            if (task.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(task.notes, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconForType(CareType type) {
    switch (type) {
      case CareType.watering:
        return Icons.water_drop;
      case CareType.fertilizing:
        return Icons.bolt;
      case CareType.pruning:
        return Icons.content_cut;
      case CareType.misting:
        return Icons.cloud;
      case CareType.custom:
        return Icons.auto_fix_high;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text('No reminders yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Create watering or fertilizing reminders to build a routine.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Create first reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
