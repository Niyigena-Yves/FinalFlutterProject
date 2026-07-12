import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../models/application.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../startup/startup_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final applications = context.watch<ApplicationProvider>().applications;
    final shortlisted = applications
        .where((a) => a.status == ApplicationStatus.interview)
        .length;
    final accepted = applications
        .where((a) => a.status == ApplicationStatus.accepted)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Text(
                          (user?.fullName.isNotEmpty ?? false)
                              ? user!.fullName[0]
                              : '?',
                          style: const TextStyle(
                              fontSize: 28, color: AppColors.primary),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(user?.fullName ?? '',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const Text('Kigali, Rwanda',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatBox(label: 'Applications', value: '${applications.length}'),
              _StatBox(label: 'Shortlisted', value: '$shortlisted'),
              _StatBox(label: 'Accepted', value: '$accepted'),
            ],
          ),
          const SizedBox(height: 24),
          if (user?.role == UserRole.startupAdmin)
            _MenuTile(
              icon: Icons.rocket_launch_outlined,
              label: 'My Startup',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const StartupDashboardScreen()),
              ),
            ),
          _MenuTile(icon: Icons.person_outline, label: 'My Profile'),
          _MenuTile(icon: Icons.star_outline, label: 'Skills & Interests'),
          _MenuTile(icon: Icons.bookmark_border, label: 'Saved Opportunities'),
          _MenuTile(icon: Icons.notifications_none, label: 'Notifications'),
          _MenuTile(icon: Icons.help_outline, label: 'Help & Support'),
          _MenuTile(
            icon: Icons.logout,
            label: 'Logout',
            color: AppColors.danger,
            onTap: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _MenuTile(
      {required this.icon, required this.label, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      contentPadding: EdgeInsets.zero,
    );
  }
}
