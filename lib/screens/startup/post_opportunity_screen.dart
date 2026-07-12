import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/opportunity.dart';
import '../../models/startup.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';


class PostOpportunityScreen extends StatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _category = 'Engineering';
  CommitmentType _commitment = CommitmentType.partTime;
  bool _submitting = false;

  Future<void> _submit(Startup startup) async {
    setState(() => _submitting = true);
    final opportunity = Opportunity(
      id: '',
      startupId: startup.id,
      startupName: startup.name,
      startupLogoUrl: startup.logoUrl,
      startupVerified: startup.isVerified,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      skillsRequired: _skillsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      commitment: _commitment,
      hoursPerWeek: _hoursCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      isActive: true,
      postedAt: DateTime.now(),
    );
    await context.read<OpportunityProvider>().postOpportunity(opportunity);
    setState(() => _submitting = false);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Opportunity posted!')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final service = context.read<FirebaseService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Post an Opportunity')),
      body: StreamBuilder<Startup?>(
        stream: user?.startupId != null
            ? service.startupStream(user!.startupId!)
            : Stream<Startup?>.value(null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final startup = snapshot.data;
          if (startup == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No startup profile linked to this account yet. Create your startup profile first.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!startup.isVerified) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hourglass_top,
                        size: 40, color: AppColors.warning),
                    const SizedBox(height: 12),
                    Text(
                      startup.verificationStatus == VerificationStatus.rejected
                          ? '${startup.name} was not approved for the platform. Contact an admin for details.'
                          : '${startup.name} is pending ALU verification. You can post opportunities once approved.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(hintText: 'Opportunity title'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: const [
                  'Engineering',
                  'Design',
                  'Marketing',
                  'Data',
                  'Other'
                ]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _skillsCtrl,
                decoration: const InputDecoration(
                    hintText: 'Skills required)'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _hoursCtrl,
                decoration: const InputDecoration(
                    hintText: 'Time commitment'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                    hintText: 'Location'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<CommitmentType>(
                initialValue: _commitment,
                items: CommitmentType.values
                    .map((c) => DropdownMenuItem(
                        value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _commitment = v!),
                decoration: const InputDecoration(labelText: 'Commitment type'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitting ? null : () => _submit(startup),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Post Opportunity'),
              ),
            ],
          );
        },
      ),
    );
  }
}