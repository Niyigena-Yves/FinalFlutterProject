import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/opportunity_card.dart';
import '../opportunity/opportunity_details_screen.dart';
import '../startup/startup_dashboard_screen.dart';

const _categories = [
  {'label': 'Design', 'icon': Icons.brush_outlined},
  {'label': 'Engineering', 'icon': Icons.code_rounded},
  {'label': 'Marketing', 'icon': Icons.campaign_outlined},
  {'label': 'Data', 'icon': Icons.bar_chart_rounded},
  {'label': 'Other', 'icon': Icons.grid_view_rounded},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final oppProvider = context.watch<OpportunityProvider>();

    return Scaffold(
      floatingActionButton: user?.role == UserRole.startupAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const StartupDashboardScreen()),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Post Opportunity'),
            )
          : null,
      body: SafeArea(
        child: oppProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : oppProvider.error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Couldn\'t load opportunities:\n${oppProvider.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user?.fullName.split(' ').first ?? 'there'} 👋',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            const Text('Find meaningful ways to contribute.',
                                style:
                                    TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.notifications_none_rounded),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        backgroundImage: user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null,
                        child: user?.photoUrl == null
                            ? Text(
                                (user?.fullName.isNotEmpty ?? false)
                                    ? user!.fullName[0]
                                    : '?',
                                style:
                                    const TextStyle(color: AppColors.primary),
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (v) =>
                        context.read<OpportunityProvider>().setSearchQuery(v),
                    decoration: InputDecoration(
                      hintText: 'Search opportunities...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.tune, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (oppProvider.recommended.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recommended',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        TextButton(
                            onPressed: () {}, child: const Text('See all')),
                      ],
                    ),
                    SizedBox(
                      height: 190,
                      child: PageView.builder(
                        controller: PageController(viewportFraction: 1),
                        itemCount: oppProvider.recommended.length,
                        itemBuilder: (_, i) {
                          final opp = oppProvider.recommended[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: OpportunityCard(
                              opportunity: opp,
                              featured: true,
                              isBookmarked:
                                  oppProvider.bookmarkedIds.contains(opp.id),
                              onTap: () => _openDetails(context, opp.id),
                              onBookmarkToggle: () => _toggleBookmark(context, opp.id),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text('Browse by category',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _categories.map((c) {
                      final selected =
                          oppProvider.selectedCategory == c['label'];
                      return GestureDetector(
                        onTap: () => context
                            .read<OpportunityProvider>()
                            .setCategory(selected ? 'All' : c['label'] as String),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: selected
                                  ? AppColors.primary
                                  : const Color(0xFFF0EEFB),
                              child: Icon(c['icon'] as IconData,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.primary),
                            ),
                            const SizedBox(height: 6),
                            Text(c['label'] as String,
                                style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    oppProvider.selectedCategory == 'All'
                        ? 'Recent opportunities'
                        : '${oppProvider.selectedCategory} opportunities',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  if (oppProvider.filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text('No opportunities match right now.',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    )
                  else
                    ...oppProvider.filtered.map((opp) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OpportunityCard(
                            opportunity: opp,
                            isBookmarked:
                                oppProvider.bookmarkedIds.contains(opp.id),
                            onTap: () => _openDetails(context, opp.id),
                            onBookmarkToggle: () =>
                                _toggleBookmark(context, opp.id),
                          ),
                        )),
                ],
              ),
      ),
    );
  }

  void _openDetails(BuildContext context, String opportunityId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OpportunityDetailsScreen(opportunityId: opportunityId),
      ),
    );
  }

  void _toggleBookmark(BuildContext context, String opportunityId) {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid == null) return;
    context.read<OpportunityProvider>().toggleBookmark(uid, opportunityId);
  }
}