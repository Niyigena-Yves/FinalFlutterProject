import 'dart:async';
import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../services/firebase_service.dart';


class OpportunityProvider extends ChangeNotifier {
  final FirebaseService _service;

  StreamSubscription? _oppSub;
  StreamSubscription? _bookmarkSub;

  List<Opportunity> _all = [];
  Set<String> _bookmarkedIds = {};
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  OpportunityProvider(this._service);

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  Set<String> get bookmarkedIds => _bookmarkedIds;

  List<Opportunity> get filtered {
    return _all.where((o) {
      final matchesCategory =
          _selectedCategory == 'All' || o.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          o.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.startupName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.skillsRequired
              .any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<Opportunity> get recommended {
    // Simple skill-matching heuristic: opportunities are pushed to
    // "Recommended" first if they were posted in the last 3 days.
    final now = DateTime.now();
    return _all
        .where((o) => now.difference(o.postedAt).inDays <= 3)
        .take(3)
        .toList();
  }

  /// Begins the real-time opportunities feed (and, if a student uid is
  /// given, their bookmarks). Call this once the user is signed in — e.g.
  /// from RootShell.initState. Safe to call again; it cancels any prior
  /// subscription first.
  void startListening({String? studentUid}) {
    _isLoading = true;
    _error = null;
    _oppSub?.cancel();
    _oppSub = _service.opportunitiesStream().listen(
      (list) {
        _all = list;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
        // ignore: avoid_print
        print('OpportunityProvider stream error: $e');
      },
    );

    if (studentUid != null) {
      listenBookmarks(studentUid);
    }
  }

  /// Cancels every active stream and clears cached data. Call this the
  /// moment the user signs out — otherwise these subscriptions keep trying
  /// to stream with a now-signed-out auth context and throw
  /// permission-denied repeatedly.
  void stopListening() {
    _oppSub?.cancel();
    _oppSub = null;
    _bookmarkSub?.cancel();
    _bookmarkSub = null;
    _all = [];
    _bookmarkedIds = {};
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void listenBookmarks(String studentUid) {
    _bookmarkSub?.cancel();
    _bookmarkSub = _service.bookmarkedIdsStream(studentUid).listen(
      (ids) {
        _bookmarkedIds = ids.toSet();
        notifyListeners();
      },
      onError: (e) {
        // ignore: avoid_print
        print('Bookmark stream error: $e');
      },
    );
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleBookmark(String studentUid, String opportunityId) {
    final isBookmarked = _bookmarkedIds.contains(opportunityId);
    return _service.toggleBookmark(studentUid, opportunityId, !isBookmarked);
  }

  Future<String> postOpportunity(Opportunity opportunity) {
    return _service.postOpportunity(opportunity);
  }

  @override
  void dispose() {
    _oppSub?.cancel();
    _bookmarkSub?.cancel();
    super.dispose();
  }
}