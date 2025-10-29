import 'package:flutter/material.dart';
import '../../widgets/gradient_card.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = const [
      {
        'name': 'Mindful Mondays',
        'members': 24,
        'desc': 'Weekly mindfulness and check-ins',
      },
      {
        'name': 'Exam Stress Support',
        'members': 36,
        'desc': 'Coping strategies during finals',
      },
      {
        'name': 'New Students Circle',
        'members': 18,
        'desc': 'Transition support & making friends',
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showCreateGroup(context),
            tooltip: 'Create group (mentor)',
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final g = groups[i];
          return GradientCard(
            colors: const [Color(0xFF5BA6F1), Color(0xFF4ED0C0)],
            child: ListTile(
              title: Text(g['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              subtitle: Text('${g['members']} members • ${g['desc']}', style: const TextStyle(color: Colors.white)),
              trailing: FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/chat'),
                child: const Text('Join'),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateGroup(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Group', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Group name')),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group created (demo)')));
                    },
                    child: const Text('Create'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}








