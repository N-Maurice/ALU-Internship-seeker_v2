import 'package:flutter/material.dart';
import 'package:alu_internship_seeker_ii/models/opportunity_model.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  int _updateCount = 3;
  List<OpportunityModel> _recommendedOpportunities = [];

  bool get isLoading => _isLoading;
  int get updateCount => _updateCount;
  List<OpportunityModel> get recommendedOpportunities => _recommendedOpportunities;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Load mock data
      _recommendedOpportunities = OpportunityModel.mockOpportunities;
      _updateCount = 3;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markUpdatesAsRead() {
    _updateCount = 0;
    notifyListeners();
  }
}