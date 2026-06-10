import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gold_of_the_prairie/models/project_model.dart';
import 'package:gold_of_the_prairie/providers/image_provider.dart';
import 'package:gold_of_the_prairie/providers/input_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<HarvestInstrumentModel> entries = [];
  bool isLoading = true;
  int stateVersion = 0;
  static const String _storageKey = 'gop_harvest_instruments_v1';
  final _uuid = const Uuid();
  final _random = Random();

  void _sortEntries() =>
      entries.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

  String _generateLedgerCode(InputNotifier p) {
    final commodity = p.commodity.label.toUpperCase();
    final methodToken = p.inspectionClassification.label.split(' ').last;
    final suffix = methodToken.substring(0, 1).toUpperCase();
    final numeric = (1000 + _random.nextInt(9000)).toString();
    return 'GOP-GRAIN-$numeric-$commodity-$suffix';
  }

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        entries = (jsonDecode(jsonString) as List<dynamic>)
            .map((item) => HarvestInstrumentModel.fromJson(item))
            .toList();
        _sortEntries();
      }
    } catch (e) {
      debugPrint('Error loading harvest instruments: $e');
      entries = [];
    } finally {
      isLoading = false;
      stateVersion++;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  HarvestInstrumentModel _fromInput(
    WidgetRef ref, {
    HarvestInstrumentModel? existing,
  }) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    return HarvestInstrumentModel(
      id: existing?.id ?? _uuid.v4(),
      granaryRegistryLedger:
          existing?.granaryRegistryLedger ?? _generateLedgerCode(p),
      commodity: p.commodity,
      inspectionClassification: p.inspectionClassification,
      artisanHallmark: p.artisanHallmark,
      volumetricCapacityBounds: p.volumetricCapacityBounds,
      sieveMeshGeometry: p.sieveMeshGeometry,
      balanceBeamGraduation: p.balanceBeamGraduation,
      millworkHardwareMetallurgy: p.millworkHardwareMetallurgy,
      physicalProportions: p.physicalProportions,
      preservationSoundness: p.preservationSoundness,
      harvestGroundZero: p.harvestGroundZero,
      temperatureRange: p.temperatureRange,
      era: p.era,
      calibratedSite: p.calibratedSite,
      notes: p.notes,
      photoPath: imgProv.resultImage.isNotEmpty
          ? imgProv.resultImage
          : (existing?.photoPath ?? p.photoPath),
      tags: List<String>.from(p.tags),
      dateAdded: existing?.dateAdded ?? DateTime.now(),
    );
  }

  void addEntry(WidgetRef ref) {
    entries = [_fromInput(ref), ...entries];
    _sortEntries();
    _save();
    stateVersion++;
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    final newList = List<HarvestInstrumentModel>.from(entries);
    newList[index] = _fromInput(ref, existing: entries[index]);
    entries = newList;
    _sortEntries();
    _save();
    stateVersion++;
    notifyListeners();
  }

  void deleteEntry(int index) {
    final newList = List<HarvestInstrumentModel>.from(entries)..removeAt(index);
    entries = newList;
    _save();
    stateVersion++;
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];
    p.granaryRegistryLedger = entry.granaryRegistryLedger;
    p.commodity = entry.commodity;
    p.inspectionClassification = entry.inspectionClassification;
    p.artisanHallmark = entry.artisanHallmark;
    p.volumetricCapacityBounds = entry.volumetricCapacityBounds;
    p.sieveMeshGeometry = entry.sieveMeshGeometry;
    p.balanceBeamGraduation = entry.balanceBeamGraduation;
    p.millworkHardwareMetallurgy = entry.millworkHardwareMetallurgy;
    p.physicalProportions = entry.physicalProportions;
    p.preservationSoundness = entry.preservationSoundness;
    p.harvestGroundZero = entry.harvestGroundZero;
    p.temperatureRange = entry.temperatureRange;
    p.era = entry.era;
    p.calibratedSite = entry.calibratedSite;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;
    imgProv.resultImage = entry.photoPath;
    notifyListeners();
  }
}

final projectProvider = ChangeNotifierProvider<ProjectNotifier>(
  (ref) => ProjectNotifier(),
);
