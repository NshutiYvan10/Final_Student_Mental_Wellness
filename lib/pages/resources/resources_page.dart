import 'package:flutter/material.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> items = const [
      {'title': 'Mindfulness Basics', 'type': 'Article', 'min': 5, 'category': 'Mindfulness'},
      {'title': 'Breathing Techniques', 'type': 'Video', 'min': 7, 'category': 'Mindfulness'},
      {'title': 'Coping with Anxiety', 'type': 'Guide', 'min': 10, 'category': 'Anxiety'},
      {'title': 'Sleep Hygiene 101', 'type': 'Article', 'min': 8, 'category': 'Sleep'},
      {'title': 'Guided Body Scan', 'type': 'Audio', 'min': 12, 'category': 'Mindfulness'},
      {'title': 'Gratitude Journaling', 'type': 'Guide', 'min': 6, 'category': 'Journaling'},
    ];

    final categories = <String>{ for (final r in items) r['category'] as String };

    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((c) => FilterChip(
              label: Text(c),
              selected: false,
              onSelected: (_) {},
            )).toList(),
          ),
          const SizedBox(height: 16),
          ...items.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              elevation: 2,
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                leading: CircleAvatar(child: Text((r['type'] as String)[0])),
                title: Text(r['title'] as String),
                subtitle: Text('${r['category']} • ${r['type']} • ${r['min']} min'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ),
          )),
        ],
      ),
    );
  }
}


