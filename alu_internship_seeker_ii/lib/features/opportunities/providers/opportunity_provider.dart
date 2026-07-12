import 'package:flutter/foundation.dart';
import 'package:alu_internship_seeker_ii/models/opportunity_model.dart';

class OpportunityProvider extends ChangeNotifier {
  List<OpportunityModel> _allOpportunities = const [];
  List<OpportunityModel> _opportunities = const [];
  String _query = '';
  String _filter = 'All';
  bool _isLoading = false;

  List<OpportunityModel> get opportunities => _opportunities;
  bool get isLoading => _isLoading;

  Future<void> loadOpportunities() async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _allOpportunities = OpportunityModel.mockOpportunities;
    _isLoading = false;
    _applyFilters();
  }

  void searchOpportunities(String query) {
    _query = query.trim().toLowerCase();
    _applyFilters();
  }

  void filterOpportunities(String filter) {
    _filter = filter;
    _applyFilters();
  }

  void _applyFilters() {
    _opportunities = _allOpportunities.where((opportunity) {
      final matchesFilter = _filter == 'All' ||
          (_filter == 'Internship' && opportunity.title.contains('Intern')) ||
          opportunity.workType == _filter;
      final matchesQuery = _query.isEmpty ||
          opportunity.title.toLowerCase().contains(_query) ||
          opportunity.company.toLowerCase().contains(_query) ||
          opportunity.location.toLowerCase().contains(_query);
      return matchesFilter && matchesQuery;
    }).toList(growable: false);
    notifyListeners();
  }
}
