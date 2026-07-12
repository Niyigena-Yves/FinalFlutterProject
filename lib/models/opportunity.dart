enum CommitmentType { partTime, fullTime, projectBased, volunteer }

class Opportunity {
  final String id;
  final String startupId;
  final String startupName;
  final String startupLogoUrl;
  final bool startupVerified;
  final String title;
  final String description;
  final String category; // Design, Engineering, Marketing, Data, Other
  final List<String> skillsRequired;
  final CommitmentType commitment;
  final String hoursPerWeek; // e.g. "4-6 hrs/week"
  final String location; // e.g. "Remote", "On-campus", "Kigali"
  final bool isActive;
  final DateTime postedAt;
  final DateTime? deadline;
  final int applicantCount;

  Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.startupLogoUrl,
    required this.startupVerified,
    required this.title,
    required this.description,
    required this.category,
    required this.skillsRequired,
    required this.commitment,
    required this.hoursPerWeek,
    required this.location,
    required this.isActive,
    required this.postedAt,
    this.deadline,
    this.applicantCount = 0,
  });

  factory Opportunity.fromMap(String id, Map<String, dynamic> map) {
    return Opportunity(
      id: id,
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      startupLogoUrl: map['startupLogoUrl'] ?? '',
      startupVerified: map['startupVerified'] ?? false,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      skillsRequired: List<String>.from(map['skillsRequired'] ?? []),
      commitment: _commitmentFromString(map['commitment']),
      hoursPerWeek: map['hoursPerWeek'] ?? '',
      location: map['location'] ?? '',
      isActive: map['isActive'] ?? true,
      postedAt: _parseDateTime(map['postedAt']) ?? DateTime.now(),
      deadline: _parseNullableDateTime(map['deadline']),
      applicantCount: map['applicantCount'] ?? 0,
    );
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    // Firestore Timestamp
    try {
      if (v is DateTime) return v;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      // Timestamp from cloud_firestore has toDate()
      if (v is Map && v.containsKey('_seconds') && v.containsKey('_nanoseconds')) {
        final seconds = v['_seconds'] as int;
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
      // Some backends store ISO strings
      if (v is String) return DateTime.tryParse(v);
      // Fallback for Timestamp type
      if (v.runtimeType.toString().contains('Timestamp')) {
        // call toDate via dynamic
        final dt = (v as dynamic).toDate();
        if (dt is DateTime) return dt;
      }
    } catch (_) {}
    return null;
  }

  static DateTime? _parseNullableDateTime(dynamic v) => _parseDateTime(v);

  static CommitmentType _commitmentFromString(String? s) {
    switch (s) {
      case 'fullTime':
        return CommitmentType.fullTime;
      case 'projectBased':
        return CommitmentType.projectBased;
      case 'volunteer':
        return CommitmentType.volunteer;
      default:
        return CommitmentType.partTime;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'startupLogoUrl': startupLogoUrl,
      'startupVerified': startupVerified,
      'title': title,
      'description': description,
      'category': category,
      'skillsRequired': skillsRequired,
      'commitment': commitment.name,
      'hoursPerWeek': hoursPerWeek,
      'location': location,
      'isActive': isActive,
      'postedAt': postedAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'applicantCount': applicantCount,
    };
  }
}
