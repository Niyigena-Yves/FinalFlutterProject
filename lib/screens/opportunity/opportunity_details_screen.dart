import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../models/application.dart';
import '../../models/opportunity.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';

class OpportunityDetailsScreen extends StatelessWidget {
  final String opportunityId;
  const OpportunityDetailsScreen({super.key, required this.opportunityId});

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity Details'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: StreamBuilder<List<Opportunity>>(
        stream: service.opportunitiesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final opp = snapshot.data!.where((o) => o.id == opportunityId);
          if (opp.isEmpty) {
            return const Center(child: Text('This opportunity is no longer available.'));
          }
          return _DetailsBody(opportunity: opp.first);
        },
      ),
    );
  }
}

class _DetailsBody extends StatefulWidget {
  final Opportunity opportunity;
  const _DetailsBody({required this.opportunity});

  @override
  State<_DetailsBody> createState() => _DetailsBodyState();
}

class _DetailsBodyState extends State<_DetailsBody> {
  bool _applying = false;

  Future<void> _apply() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final coverNote = await showDialog<String>(
      context: context,
      builder: (_) => _CoverNoteDialog(),
    );
    if (coverNote == null) return;

    setState(() => _applying = true);
    await context.read<ApplicationProvider>().apply(
          opportunity: widget.opportunity,
          studentUid: user.uid,
          studentName: user.fullName,
          coverNote: coverNote,
        );
    setState(() => _applying = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final opp = widget.opportunity;
    final user = context.watch<AuthProvider>().currentUser;

    // Only students can apply. Founders never see an Apply button — if
    // it's their own posting, they get a reviewer view instead; if it's
    // someone else's, they just see the read-only details.
    final isStudent = user?.role == UserRole.student;
    final isOwningFounder =
        user?.role == UserRole.startupAdmin && user?.startupId == opp.startupId;
    final alreadyApplied =
        isStudent && context.watch<ApplicationProvider>().hasAppliedTo(opp.id);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    backgroundImage: opp.startupLogoUrl.isNotEmpty
                        ? NetworkImage(opp.startupLogoUrl)
                        : null,
                    child: opp.startupLogoUrl.isEmpty
                        ? const Icon(Icons.rocket_launch,
                            color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opp.title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        Row(
                          children: [
                            Text(opp.startupName,
                                style: const TextStyle(
                                    color: AppColors.textSecondary)),
                            if (opp.startupVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified,
                                  size: 14, color: AppColors.primary),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: opp.skillsRequired
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
              const SizedBox(height: 20),
              _InfoRow(icon: Icons.schedule, text: opp.hoursPerWeek),
              _InfoRow(icon: Icons.place_outlined, text: opp.location),
              _InfoRow(
                  icon: Icons.event_outlined,
                  text: 'Posted ${_timeAgo(opp.postedAt)}'),
              const SizedBox(height: 20),
              const Text('About',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 6),
              Text(opp.description,
                  style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
              const SizedBox(height: 20),
              const Text('Skills required',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: opp.skillsRequired
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
              if (isOwningFounder) ...[
                const SizedBox(height: 28),
                Text('Applications under review (${opp.applicantCount})',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 10),
                _ApplicantsList(opportunityId: opp.id),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
        // Apply button only for students. Founders get no bottom action bar
        // at all here — managing applicants happens inline above.
        if (isStudent)
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: alreadyApplied || _applying ? null : _apply,
              child: _applying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(alreadyApplied ? 'Already Applied' : 'Apply Now'),
            ),
          ),
      ],
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays} days ago';
    if (diff.inHours >= 1) return '${diff.inHours} hours ago';
    return 'just now';
  }
}

/// Shown only to the founder who owns this opportunity. Lists every
/// student who applied, in real time, with buttons to move them through
/// the pipeline (Interview / Accept / Reject).
class _ApplicantsList extends StatelessWidget {
  final String opportunityId;
  const _ApplicantsList({required this.opportunityId});

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirebaseService>();

    return StreamBuilder<List<Application>>(
      stream: service.opportunityApplicationsStream(opportunityId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final applicants = snapshot.data!;
        if (applicants.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No applicants yet.',
                style: TextStyle(color: AppColors.textSecondary)),
          );
        }
        return Column(
          children: applicants
              .map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ApplicantTile(application: a, service: service),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _ApplicantTile extends StatelessWidget {
  final Application application;
  final FirebaseService service;
  const _ApplicantTile({required this.application, required this.service});

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

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: Text(
                  application.studentName.isNotEmpty
                      ? application.studentName[0]
                      : '?',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(application.studentName,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(application.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  application.status.name,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(application.status)),
                ),
              ),
            ],
          ),
          if (application.coverNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(application.coverNote,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _ActionChip(
                label: 'Interview',
                onTap: () => service.updateApplicationStatus(
                    application.id, 'interview'),
              ),
              _ActionChip(
                label: 'Accept',
                onTap: () => service.updateApplicationStatus(
                    application.id, 'accepted'),
              ),
              _ActionChip(
                label: 'Reject',
                onTap: () => service.updateApplicationStatus(
                    application.id, 'rejected'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      backgroundColor: const Color(0xFFF0EEFB),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _CoverNoteDialog extends StatefulWidget {
  @override
  State<_CoverNoteDialog> createState() => _CoverNoteDialogState();
}

class _CoverNoteDialogState extends State<_CoverNoteDialog> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a short note (optional)'),
      content: TextField(
        controller: _ctrl,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Tell the startup why you\'re a good fit...',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_ctrl.text.trim()),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}