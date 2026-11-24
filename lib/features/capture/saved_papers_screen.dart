import 'package:material_ui/material_ui.dart';

import '../../models/paper.dart';

class SavedPapersScreen extends StatelessWidget {
  const SavedPapersScreen({super.key, this.papers = const <Paper>[]});

  final List<Paper> papers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Papers')),
      body: papers.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open_outlined, size: 48),
                  SizedBox(height: 12),
                  Text('No saved papers yet.'),
                  SizedBox(height: 4),
                  Text('Papers you save will appear here.'),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: papers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final paper = papers[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(paper.title),
                    subtitle: Text(
                      '${paper.questions.length} questions',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
