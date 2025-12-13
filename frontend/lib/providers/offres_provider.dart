import 'package:flutter/material.dart';
import '../models/offre.dart';
import '../services/api_service.dart';

class OffresProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Offre> _offres = [];
  bool _isLoading = false;
  String? _error;

  List<Offre> get offres => _offres;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all offres
  Future<void> fetchOffres() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _offres = await _apiService.getOffres();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create offre (RECRUTEUR)
  Future<bool> createOffre(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newOffre = await _apiService.createOffre(data);
      _offres.insert(0, newOffre);
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

  // Update offre
  Future<bool> updateOffre(int id, Map<String, dynamic> data) async {
    try {
      final updatedOffre = await _apiService.updateOffre(id, data);
      final index = _offres.indexWhere((o) => o.id == id);
      if (index != -1) {
        _offres[index] = updatedOffre;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete offre
  Future<bool> deleteOffre(int id) async {
    try {
      await _apiService.deleteOffre(id);
      _offres.removeWhere((o) => o.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
