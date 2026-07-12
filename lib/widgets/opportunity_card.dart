import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../theme/app_theme.dart';

class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;
  final bool featured;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkToggle,
    this.featured = false,
  });

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: featured ? AppColors.gradient : null,
          color: featured ? null : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      featured ? Colors.white24 : AppColors.background,
                  backgroundImage: opportunity.startupLogoUrl.isNotEmpty
                      ? NetworkImage(opportunity.startupLogoUrl)
                      : null,
                  child: opportunity.startupLogoUrl.isEmpty
                      ? Icon(Icons.rocket_launch,
                          color: featured ? Colors.white : AppColors.primary,
                          size: 18)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: featured ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            opportunity.startupName,
                            style: TextStyle(
                              fontSize: 12,
                              color: featured
                                  ? Colors.white70
                                  : AppColors.textSecondary,
                            ),
                          ),
                          if (opportunity.startupVerified) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified,
                                size: 13,
                                color: featured
                                    ? Colors.white
                                    : AppColors.primary),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onBookmarkToggle,
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: featured ? Colors.white : AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: opportunity.skillsRequired.take(3).map((skill) {
                return Chip(
                  label: Text(skill),
                  backgroundColor:
                      featured ? Colors.white24 : const Color(0xFFF0EEFB),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    color: featured ? Colors.white : AppColors.textPrimary,
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  opportunity.hoursPerWeek,
                  style: TextStyle(
                    fontSize: 12,
                    color: featured ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Posted ${_timeAgo(opportunity.postedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: featured ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
