import 'package:gold_of_the_prairie/enum/my_enums.dart';

class HarvestInstrumentModel {
  String id;
  String granaryRegistryLedger;
  HarvestCommodity commodity;
  InspectionClassification inspectionClassification;
  String artisanHallmark;
  String volumetricCapacityBounds;
  SieveMeshGeometry sieveMeshGeometry;
  BalanceBeamGraduation balanceBeamGraduation;
  Metallurgy millworkHardwareMetallurgy;
  String physicalProportions;
  PreservationSoundness preservationSoundness;
  String harvestGroundZero;
  String temperatureRange;
  String era;
  String calibratedSite;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  HarvestInstrumentModel({
    required this.id,
    required this.granaryRegistryLedger,
    required this.commodity,
    required this.inspectionClassification,
    required this.artisanHallmark,
    required this.volumetricCapacityBounds,
    required this.sieveMeshGeometry,
    required this.balanceBeamGraduation,
    required this.millworkHardwareMetallurgy,
    required this.physicalProportions,
    required this.preservationSoundness,
    required this.harvestGroundZero,
    required this.temperatureRange,
    required this.era,
    required this.calibratedSite,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'granaryRegistryLedger': granaryRegistryLedger,
    'commodity': commodity.name,
    'inspectionClassification': inspectionClassification.name,
    'artisanHallmark': artisanHallmark,
    'volumetricCapacityBounds': volumetricCapacityBounds,
    'sieveMeshGeometry': sieveMeshGeometry.name,
    'balanceBeamGraduation': balanceBeamGraduation.name,
    'millworkHardwareMetallurgy': millworkHardwareMetallurgy.name,
    'physicalProportions': physicalProportions,
    'preservationSoundness': preservationSoundness.name,
    'harvestGroundZero': harvestGroundZero,
    'temperatureRange': temperatureRange,
    'era': era,
    'calibratedSite': calibratedSite,
    'notes': notes,
    'photoPath': photoPath,
    'tags': tags,
    'dateAdded': dateAdded.toIso8601String(),
  };

  factory HarvestInstrumentModel.fromJson(Map<String, dynamic> json) {
    return HarvestInstrumentModel(
      id: json['id'] ?? '',
      granaryRegistryLedger: json['granaryRegistryLedger'] ?? '',
      commodity:
          HarvestCommodity.values.asNameMap()[json['commodity']] ??
          HarvestCommodity.wheat,
      inspectionClassification:
          InspectionClassification.values
              .asNameMap()[json['inspectionClassification']] ??
          InspectionClassification.coreSampler,
      artisanHallmark: _parseArtisanHallmark(json['artisanHallmark']),
      volumetricCapacityBounds: json['volumetricCapacityBounds'] ?? '',
      sieveMeshGeometry:
          SieveMeshGeometry.values.asNameMap()[json['sieveMeshGeometry']] ??
          SieveMeshGeometry.notApplicable,
      balanceBeamGraduation:
          BalanceBeamGraduation.values
              .asNameMap()[json['balanceBeamGraduation']] ??
          BalanceBeamGraduation.poundsPerBushel,
      millworkHardwareMetallurgy:
          Metallurgy.values.asNameMap()[json['millworkHardwareMetallurgy']] ??
          Metallurgy.sheetBrass,
      physicalProportions: json['physicalProportions'] ?? '',
      preservationSoundness:
          PreservationSoundness.values
              .asNameMap()[json['preservationSoundness']] ??
          PreservationSoundness.displayCondition,
      harvestGroundZero: json['harvestGroundZero'] ?? '',
      temperatureRange: json['temperatureRange'] ?? '',
      era: json['era'] ?? '',
      calibratedSite: json['calibratedSite'] ?? '',
      notes: json['notes'] ?? '',
      photoPath: json['photoPath'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
    );
  }
}

String _parseArtisanHallmark(dynamic value) {
  if (value == null) return '';
  final text = value.toString().trim();
  if (text.isEmpty) return '';
  final enumMatch = ArtisanHallmark.values.asNameMap()[text];
  return enumMatch?.label ?? text;
}
