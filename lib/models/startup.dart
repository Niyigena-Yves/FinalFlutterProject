enum VerificationStatus { pending, verified, rejected }

class Startup {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String category; 
  final List<String> founderUids;
  final VerificationStatus verificationStatus;
  final String? alumniProofUrl;
  final DateTime createdAt;

  Startup({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.category,
    required this.founderUids,
    required this.verificationStatus,
    this.alumniProofUrl,
    required this.createdAt,
  });

  bool get isVerified => verificationStatus == VerificationStatus.verified;

  factory Startup.fromMap(String id, Map<String, dynamic> map) {
    return Startup(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      category: map['category'] ?? 'Other',
      founderUids: List<String>.from(map['founderUids'] ?? []),
      verificationStatus: _statusFromString(map['verificationStatus']),
      alumniProofUrl: map['alumniProofUrl'],
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
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

  static VerificationStatus _statusFromString(String? s) {
    switch (s) {
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'category': category,
      'founderUids': founderUids,
      'verificationStatus': verificationStatus.name,
      'alumniProofUrl': alumniProofUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
