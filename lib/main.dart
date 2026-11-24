import 'package:material_ui/material_ui.dart';

import 'core/theme/app_theme.dart';
import 'features/capture/new_paper_screen.dart';
import 'features/capture/saved_papers_screen.dart';

void main() {
  runApp(const QuesGenApp());
}

class QuesGenApp extends StatelessWidget {
  const QuesGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuesGen',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    NewPaperScreen(),
    SavedPapersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'New Paper',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder_open),
            label: 'Saved Papers',
          ),
        ],
      ),
    );
  }
}
