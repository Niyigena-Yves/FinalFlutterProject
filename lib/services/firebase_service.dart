import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/startup.dart';
import '../models/opportunity.dart';
import '../models/application.dart';

/// Centralizes every read/write to Firebase so that Providers never talk to
/// FirebaseAuth/Firestore directly

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- Auth ----------------

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  // ---------------- Users ----------------

  Future<void> createUserProfile(AppUser user) {
    return _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Stream<AppUser?> userProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).update(data);
  }

  // ---------------- Startups ----------------

  Future<String> createStartup(Startup startup) async {
    final ref = await _db.collection('startups').add(startup.toMap());
    return ref.id;
  }

  Stream<List<Startup>> pendingStartupsStream() {
    return _db
        .collection('startups')
        .where('verificationStatus', isEqualTo: 'pending')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Startup.fromMap(d.id, d.data())).toList());
  }

  Future<void> setStartupVerification(String startupId, String status) {
    return _db
        .collection('startups')
        .doc(startupId)
        .update({'verificationStatus': status});
  }

  Future<Startup?> getStartup(String startupId) async {
    final doc = await _db.collection('startups').doc(startupId).get();
    if (!doc.exists) return null;
    return Startup.fromMap(doc.id, doc.data()!);
  }

  Stream<Startup?> startupStream(String startupId) {
    return _db.collection('startups').doc(startupId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Startup.fromMap(doc.id, doc.data()!);
    });
  }

  // ---------------- Opportunities ----------------

  Stream<List<Opportunity>> opportunitiesStream({String? category}) {
    Query<Map<String, dynamic>> query = _db
        .collection('opportunities')
        .where('isActive', isEqualTo: true)
        .orderBy('postedAt', descending: true);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snap) =>
        snap.docs.map((d) => Opportunity.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Opportunity>> startupOpportunitiesStream(String startupId) {
    return _db
        .collection('opportunities')
        .where('startupId', isEqualTo: startupId)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Opportunity.fromMap(d.id, d.data())).toList());
  }

  Future<String> postOpportunity(Opportunity opportunity) async {
    final ref =
        await _db.collection('opportunities').add(opportunity.toMap());
    return ref.id;
  }

  Future<void> closeOpportunity(String opportunityId) {
    return _db
        .collection('opportunities')
        .doc(opportunityId)
        .update({'isActive': false});
  }

  // ---------------- Applications ----------------

  Future<void> submitApplication(Application application) async {
    final batch = _db.batch();
    final appRef = _db.collection('applications').doc();
    batch.set(appRef, application.toMap());

    final oppRef =
        _db.collection('opportunities').doc(application.opportunityId);
    batch.update(oppRef, {'applicantCount': FieldValue.increment(1)});

    await batch.commit();
  }

  Stream<List<Application>> studentApplicationsStream(String studentUid) {
    return _db
        .collection('applications')
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Application.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Application>> opportunityApplicationsStream(
      String opportunityId) {
    return _db
        .collection('applications')
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Application.fromMap(d.id, d.data())).toList());
  }

  Future<void> updateApplicationStatus(String applicationId, String status) {
    return _db
        .collection('applications')
        .doc(applicationId)
        .update({'status': status});
  }

  // ---------------- Bookmarks ----------------

  Future<void> toggleBookmark(
      String studentUid, String opportunityId, bool bookmarked) {
    final ref = _db
        .collection('users')
        .doc(studentUid)
        .collection('bookmarks')
        .doc(opportunityId);
    return bookmarked
        ? ref.set({'bookmarkedAt': DateTime.now().toIso8601String()})
        : ref.delete();
  }

  Stream<List<String>> bookmarkedIdsStream(String studentUid) {
    return _db
        .collection('users')
        .doc(studentUid)
        .collection('bookmarks')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }
}