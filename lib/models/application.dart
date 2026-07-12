enum ApplicationStatus { applied, interview, accepted, rejected }

class Application {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupName;
  final String startupLogoUrl;
  final String studentUid;
  final String studentName;
  final String coverNote;
  final ApplicationStatus status;
  final DateTime appliedAt;

  Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupName,
    required this.startupLogoUrl,
    required this.studentUid,
    required this.studentName,
    required this.coverNote,
    required this.status,
    required this.appliedAt,
  });

  factory Application.fromMap(String id, Map<String, dynamic> map) {
    return Application(
      id: id,
      opportunityId: map['opportunityId'] ?? '',
      opportunityTitle: map['opportunityTitle'] ?? '',
      startupName: map['startupName'] ?? '',
      startupLogoUrl: map['startupLogoUrl'] ?? '',
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? '',
      coverNote: map['coverNote'] ?? '',
      status: _statusFromString(map['status']),
      appliedAt: _parseDateTime(map['appliedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    try {
      if (v is DateTime) return v;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) return DateTime.tryParse(v);
      if (v.runtimeType.toString().contains('Timestamp')) {
        final dt = (v as dynamic).toDate();
        if (dt is DateTime) return dt;
      }
      if (v is Map && v.containsKey('_seconds')) {
        final seconds = v['_seconds'] as int;
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    } catch (_) {}
    return null;
  }

  static ApplicationStatus _statusFromString(String? s) {
    switch (s) {
      case 'interview':
        return ApplicationStatus.interview;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.applied;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupName': startupName,
      'startupLogoUrl': startupLogoUrl,
      'studentUid': studentUid,
      'studentName': studentName,
      'coverNote': coverNote,
      'status': status.name,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }
}
