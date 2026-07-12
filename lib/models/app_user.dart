/// Represents an authenticated user in ALU Connect.
/// 
enum UserRole { student, startupAdmin }

class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final UserRole role;
  final String? photoUrl;
  final List<String> skills; 
  final List<String> interests;
  final String? startupId; // set only when role == startupAdmin
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.photoUrl,
    this.skills = const [],
    this.interests = const [],
    this.startupId,
    required this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: (map['role'] == 'startupAdmin')
          ? UserRole.startupAdmin
          : UserRole.student,
      photoUrl: map['photoUrl'],
      skills: List<String>.from(map['skills'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      startupId: map['startupId'],
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

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'role': role == UserRole.startupAdmin ? 'startupAdmin' : 'student',
      'photoUrl': photoUrl,
      'skills': skills,
      'interests': interests,
      'startupId': startupId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
