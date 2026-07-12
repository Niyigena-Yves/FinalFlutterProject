import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../models/application.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../startup/startup_dashboard_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  ApplicationStatus? _filter; // null == "All"

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user?.role == UserRole.startupAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Applications')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fact_check_outlined,
                    size: 40, color: AppColors.textSecondary),
                const SizedBox(height: 12),
                const Text(
                  "As a startup founder, you review applicants from each opportunity's page under My Startup.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const StartupDashboardScreen()),
                  ),
                  child: const Text('Go to My Startup'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final provider = context.watch<ApplicationProvider>();
    final applications = provider.byStatus(_filter);

    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Couldn\'t load applications:\n${provider.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      _StatusChip(
                        label: 'Applied',
                        selected: _filter == ApplicationStatus.applied,
                        onTap: () => setState(
                            () => _filter = ApplicationStatus.applied),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: 'Interview',
                        selected: _filter == ApplicationStatus.interview,
                        onTap: () => setState(
                            () => _filter = ApplicationStatus.interview),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: 'Accepted',
                        selected: _filter == ApplicationStatus.accepted,
                        onTap: () => setState(
                            () => _filter = ApplicationStatus.accepted),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: 'All',
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: applications.isEmpty
                      ? const Center(
                          child: Text('No applications yet.',
                              style:
                                  TextStyle(color: AppColors.textSecondary)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: applications.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              _ApplicationTile(application: applications[i]),
                        ),
                ),
              ],
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: const Color(0xFFF0EEFB),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  final Application application;
  const _ApplicationTile({required this.application});

  Color _statusColor(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.accepted:
        return AppColors.success;
      case ApplicationStatus.interview:
        return AppColors.warning;
      case ApplicationStatus.rejected:
        return AppColors.danger;
      case ApplicationStatus.applied:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.rejected:
        return 'Closed';
      case ApplicationStatus.applied:
        return 'Under Review';
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()} week(s) ago';
    if (diff.inDays >= 1) return '${diff.inDays} days ago';
    return 'today';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            backgroundImage: application.startupLogoUrl.isNotEmpty
                ? NetworkImage(application.startupLogoUrl)
                : null,
            child: application.startupLogoUrl.isEmpty
                ? const Icon(Icons.rocket_launch, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(application.opportunityTitle,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(application.startupName,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text('Applied ${_timeAgo(application.appliedAt)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(application.status).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _statusLabel(application.status),
              style: TextStyle(
                  color: _statusColor(application.status),
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}