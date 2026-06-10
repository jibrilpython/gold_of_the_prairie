import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gold_of_the_prairie/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _granaryRegistryLedger = '';
  HarvestCommodity _commodity = HarvestCommodity.wheat;
  InspectionClassification _inspectionClassification =
      InspectionClassification.coreSampler;
  String _artisanHallmark = '';
  String _volumetricCapacityBounds = '';
  SieveMeshGeometry _sieveMeshGeometry = SieveMeshGeometry.notApplicable;
  BalanceBeamGraduation _balanceBeamGraduation =
      BalanceBeamGraduation.poundsPerBushel;
  Metallurgy _millworkHardwareMetallurgy = Metallurgy.sheetBrass;
  String _physicalProportions = '';
  PreservationSoundness _preservationSoundness =
      PreservationSoundness.displayCondition;
  String _harvestGroundZero = '';
  String _temperatureRange = '';
  String _era = '';
  String _calibratedSite = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  String get granaryRegistryLedger => _granaryRegistryLedger;
  HarvestCommodity get commodity => _commodity;
  InspectionClassification get inspectionClassification =>
      _inspectionClassification;
  String get artisanHallmark => _artisanHallmark;
  String get volumetricCapacityBounds => _volumetricCapacityBounds;
  SieveMeshGeometry get sieveMeshGeometry => _sieveMeshGeometry;
  BalanceBeamGraduation get balanceBeamGraduation => _balanceBeamGraduation;
  Metallurgy get millworkHardwareMetallurgy => _millworkHardwareMetallurgy;
  String get physicalProportions => _physicalProportions;
  PreservationSoundness get preservationSoundness => _preservationSoundness;
  String get harvestGroundZero => _harvestGroundZero;
  String get temperatureRange => _temperatureRange;
  String get era => _era;
  String get calibratedSite => _calibratedSite;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  set granaryRegistryLedger(String v) {
    _granaryRegistryLedger = v;
    notifyListeners();
  }

  set commodity(HarvestCommodity v) {
    _commodity = v;
    notifyListeners();
  }

  set inspectionClassification(InspectionClassification v) {
    _inspectionClassification = v;
    notifyListeners();
  }

  set artisanHallmark(String v) {
    _artisanHallmark = v;
    notifyListeners();
  }

  set volumetricCapacityBounds(String v) {
    _volumetricCapacityBounds = v;
    notifyListeners();
  }

  set sieveMeshGeometry(SieveMeshGeometry v) {
    _sieveMeshGeometry = v;
    notifyListeners();
  }

  set balanceBeamGraduation(BalanceBeamGraduation v) {
    _balanceBeamGraduation = v;
    notifyListeners();
  }

  set millworkHardwareMetallurgy(Metallurgy v) {
    _millworkHardwareMetallurgy = v;
    notifyListeners();
  }

  set physicalProportions(String v) {
    _physicalProportions = v;
    notifyListeners();
  }

  set preservationSoundness(PreservationSoundness v) {
    _preservationSoundness = v;
    notifyListeners();
  }

  set harvestGroundZero(String v) {
    _harvestGroundZero = v;
    notifyListeners();
  }

  set temperatureRange(String v) {
    _temperatureRange = v;
    notifyListeners();
  }

  set era(String v) {
    _era = v;
    notifyListeners();
  }

  set calibratedSite(String v) {
    _calibratedSite = v;
    notifyListeners();
  }

  set notes(String v) {
    _notes = v;
    notifyListeners();
  }

  set photoPath(String v) {
    _photoPath = v;
    notifyListeners();
  }

  set tags(List<String> v) {
    _tags = v;
    notifyListeners();
  }

  set dateAdded(DateTime v) {
    _dateAdded = v;
    notifyListeners();
  }

  void clearAll() {
    _granaryRegistryLedger = '';
    _commodity = HarvestCommodity.wheat;
    _inspectionClassification = InspectionClassification.coreSampler;
    _artisanHallmark = '';
    _volumetricCapacityBounds = '';
    _sieveMeshGeometry = SieveMeshGeometry.notApplicable;
    _balanceBeamGraduation = BalanceBeamGraduation.poundsPerBushel;
    _millworkHardwareMetallurgy = Metallurgy.sheetBrass;
    _physicalProportions = '';
    _preservationSoundness = PreservationSoundness.displayCondition;
    _harvestGroundZero = '';
    _temperatureRange = '';
    _era = '';
    _calibratedSite = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
