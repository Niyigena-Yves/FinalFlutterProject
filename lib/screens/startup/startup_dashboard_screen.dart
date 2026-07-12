import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/opportunity.dart';
import '../../models/startup.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import 'post_opportunity_screen.dart';

class StartupDashboardScreen extends StatelessWidget {
  const StartupDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final service = context.read<FirebaseService>();

    if (user?.startupId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Startup')),
        body: _CreateStartupForm(onCreated: () {}),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Startup')),
      body: StreamBuilder<Startup?>(
        stream: service.startupStream(user!.startupId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final startup = snapshot.data;
          if (startup == null) {
            return const Center(
                child: Text('Startup profile not found.'));
          }
          return _StartupOverview(startup: startup);
        },
      ),
    );
  }
}

class _CreateStartupForm extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreateStartupForm({required this.onCreated});

  @override
  State<_CreateStartupForm> createState() => _CreateStartupFormState();
}

class _CreateStartupFormState extends State<_CreateStartupForm> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _proofCtrl = TextEditingController();
  String _category = 'Engineering';
  bool _submitting = false;

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final service = context.read<FirebaseService>();
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _submitting = true);
    final startup = Startup(
      id: '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      logoUrl: '',
      category: _category,
      founderUids: [user.uid],
      verificationStatus: VerificationStatus.pending,
      alumniProofUrl:
          _proofCtrl.text.trim().isEmpty ? null : _proofCtrl.text.trim(),
      createdAt: DateTime.now(),
    );
    final startupId = await service.createStartup(startup);
    await service.updateUserProfile(user.uid, {'startupId': startupId});

    setState(() => _submitting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Startup profile submitted for ALU verification!'),
      ));
      widget.onCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Register your startup or venture. It'll need ALU verification before you can post opportunities — this keeps the platform trustworthy for students.",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(hintText: 'Startup name'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _descCtrl,
          maxLines: 3,
          decoration:
              const InputDecoration(hintText: 'What does your startup do?'),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _category,
          items: const ['Engineering', 'Design', 'Marketing', 'Data', 'Other']
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _category = v!),
          decoration: const InputDecoration(labelText: 'Primary category'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _proofCtrl,
          decoration: const InputDecoration(
              hintText:
                  'Link to ALU club registry / recognition proof (optional)'),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Submit for Verification'),
        ),
      ],
    );
  }
}

class _StartupOverview extends StatelessWidget {
  final Startup startup;
  const _StartupOverview({required this.startup});

  Color _statusColor(VerificationStatus s) {
    switch (s) {
      case VerificationStatus.verified:
        return AppColors.success;
      case VerificationStatus.rejected:
        return AppColors.danger;
      case VerificationStatus.pending:
        return AppColors.warning;
    }
  }

  String _statusLabel(VerificationStatus s) {
    switch (s) {
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.pending:
        return 'Pending verification';
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirebaseService>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(startup.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(startup.verificationStatus)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel(startup.verificationStatus),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(startup.verificationStatus),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const PostOpportunityScreen()),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Post'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16)),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Your posted opportunities',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<List<Opportunity>>(
            stream: service.startupOpportunitiesStream(startup.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final opportunities = snapshot.data!;
              if (opportunities.isEmpty) {
                return const Center(
                  child: Text("You haven't posted any opportunities yet.",
                      style: TextStyle(color: AppColors.textSecondary)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: opportunities.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final opp = opportunities[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(opp.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Text(
                                '${opp.applicantCount} applicant(s) • ${opp.isActive ? "Active" : "Closed"}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (opp.isActive)
                          TextButton(
                            onPressed: () =>
                                service.closeOpportunity(opp.id),
                            child: const Text('Close'),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}