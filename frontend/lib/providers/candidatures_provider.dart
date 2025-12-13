import 'package:flutter/material.dart';
import '../models/candidature.dart';
import '../services/api_service.dart';

class CandidaturesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Candidature> _candidatures = [];
  bool _isLoading = false;
  String? _error;

  List<Candidature> get candidatures => _candidatures;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch my candidatures (CANDIDAT)
  Future<void> fetchMyCandidatures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _candidatures = await _apiService.getMyCandidatures();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit candidature
  Future<bool> submitCandidature({
    required int offreId,
    required String nom,
    required String prenom,
    String? dateNaissance,
    String? telephone,
    required String cne,
    required String mention,
    required String cinImagePath,
    required String bacImagePath,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final candidature = await _apiService.submitCandidature(
        offreId: offreId,
        nom: nom,
        prenom: prenom,
        dateNaissance: dateNaissance,
        telephone: telephone,
        cne: cne,
        mention: mention,
        cinImagePath: cinImagePath,
        bacImagePath: bacImagePath,
      );
      _candidatures.insert(0, candidature);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
