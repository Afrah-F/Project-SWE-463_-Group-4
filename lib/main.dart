
import 'package:flutter/material.dart';

void main() {
  runApp(const MizaniaApp());
}

class MizaniaApp extends StatelessWidget {
  const MizaniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mizania',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF315B49),
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Color(0xFF315B49),
            ),
            const SizedBox(height: 20),
            const Text(
              'MIZANIA',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Student Budget Tracker'),
            const SizedBox(height: 30),
            FilledButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppShell(),
                  ),
                );
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 0;

  final List<String> pages = [
    'Home',
    'History',
    'Budgets',
    'Savings',
    'Reports',
    'Settings',
  ];

  final List<IconData> icons = [
    Icons.home_outlined,
    Icons.receipt_long_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.savings_outlined,
    Icons.pie_chart_outline,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pages[selectedIndex]),
        backgroundColor: const Color(0xFF315B49),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '${pages[selectedIndex]} Screen',
          style: const TextStyle(fontSize: 26),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: List.generate(
          pages.length,
          (index) => NavigationDestination(
            icon: Icon(icons[index]),
            label: pages[index],
          ),
        ),
      ),
    );
  }
}
