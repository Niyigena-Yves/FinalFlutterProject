import 'dart:async';
import 'package:flutter/material.dart';
import '../models/application.dart';
import '../models/opportunity.dart';
import '../services/firebase_service.dart';

class ApplicationProvider extends ChangeNotifier {
  final FirebaseService _service;
  StreamSubscription? _sub;

  List<Application> _applications = [];
  bool _isLoading = true;
  String? _error;

  ApplicationProvider(this._service);

  List<Application> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Application> byStatus(ApplicationStatus? status) {
    if (status == null) return _applications;
    return _applications.where((a) => a.status == status).toList();
  }

  bool hasAppliedTo(String opportunityId) =>
      _applications.any((a) => a.opportunityId == opportunityId);

  void listenForStudent(String studentUid) {
    _sub?.cancel();
    _isLoading = true;
    _sub = _service.studentApplicationsStream(studentUid).listen(
      (list) {
        _applications = list;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
        // ignore: avoid_print
        print('ApplicationProvider stream error: $e');
      },
    );
  }

  Future<void> apply({
    required Opportunity opportunity,
    required String studentUid,
    required String studentName,
    required String coverNote,
  }) async {
    final application = Application(
      id: '',
      opportunityId: opportunity.id,
      opportunityTitle: opportunity.title,
      startupName: opportunity.startupName,
      startupLogoUrl: opportunity.startupLogoUrl,
      studentUid: studentUid,
      studentName: studentName,
      coverNote: coverNote,
      status: ApplicationStatus.applied,
      appliedAt: DateTime.now(),
    );
    await _service.submitApplication(application);
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
    _applications = [];
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}