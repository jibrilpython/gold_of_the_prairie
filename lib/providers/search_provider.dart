import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gold_of_the_prairie/models/project_model.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<HarvestInstrumentModel> filteredList(List<HarvestInstrumentModel> list) {
    final query = searchQuery.toLowerCase().trim();
    if (query.isEmpty) return list;
    return list.where((item) {
      return item.granaryRegistryLedger.toLowerCase().contains(query) ||
          item.artisanHallmark.toLowerCase().contains(query) ||
          item.harvestGroundZero.toLowerCase().contains(query) ||
          item.calibratedSite.toLowerCase().contains(query) ||
          item.era.toLowerCase().contains(query) ||
          item.inspectionClassification.label.toLowerCase().contains(query) ||
          item.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());
