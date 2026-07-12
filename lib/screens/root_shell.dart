import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/application_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/opportunity_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'applications/applications_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';

/// The four bottom-nav tabs 

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  late final OpportunityProvider _oppProvider;
  late final ApplicationProvider _appProvider;

  @override
  void initState() {
    super.initState();
    _oppProvider = context.read<OpportunityProvider>();
    _appProvider = context.read<ApplicationProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        _oppProvider.startListening(studentUid: uid);
        _appProvider.listenForStudent(uid);
      }
    });
  }

  @override
  void dispose() {
    _oppProvider.stopListening();
    _appProvider.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      HomeScreen(),
      HomeScreen(), 
      ApplicationsScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}