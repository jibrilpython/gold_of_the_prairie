import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gold_of_the_prairie/enum/my_enums.dart';

const Color kBackground = Color(0xFFF7F4EE);
const Color kPrimaryText = Color(0xFF1A1508);
const Color kPanelBg = Color(0xFFFFFFFF);
const Color kSecondaryText = Color(0xFF7A7260);
const Color kAccent = Color(0xFFB5820A);
const Color kSecondaryAccent = Color(0xFF4A7C3F);
const Color kOutline = Color(0xFFE8E2D6);
const Color kError = Color(0xFFC0392B);
const Color kLedgerTint = Color(0xFFFBF6EA);
const Color kGreenSurface = Color(0xFFEAF2E6);
const Color kGoldSurface = Color(0xFFFFF6D8);

const double kRadiusSubtle = 10;
const double kRadiusStandard = 16;
const double kRadiusMedium = 24;
const double kRadiusLarge = 32;
const double kRadiusPill = 999;

const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 4),
  blurRadius: 16,
  spreadRadius: -4,
  color: Color(0x141A1508),
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 18),
  blurRadius: 34,
  spreadRadius: -16,
  color: Color(0x331A1508),
);

const double kBottomNavBarHeight = 68;
const double kBottomNavBarMargin = 16;
const double kAddButtonGapAboveNav = 12;

double bottomNavOverlayHeight(BuildContext context) {
  return MediaQuery.of(context).padding.bottom +
      kBottomNavBarMargin.h +
      kBottomNavBarHeight.h;
}

double homeAddButtonBottom(BuildContext context) {
  return bottomNavOverlayHeight(context) + kAddButtonGapAboveNav.h;
}

Color getCommodityColor(HarvestCommodity commodity) {
  switch (commodity) {
    case HarvestCommodity.wheat:
      return kAccent;
    case HarvestCommodity.corn:
      return const Color(0xFFD08B21);
    case HarvestCommodity.barley:
      return const Color(0xFF9B7A35);
    case HarvestCommodity.oats:
      return const Color(0xFF8B8A63);
    case HarvestCommodity.rye:
      return const Color(0xFF6F5D2C);
    case HarvestCommodity.sorghum:
      return const Color(0xFF9E3F2C);
  }
}

Color getConditionColor(PreservationSoundness state) {
  switch (state) {
    case PreservationSoundness.museumGrade:
    case PreservationSoundness.displayCondition:
      return kSecondaryAccent;
    case PreservationSoundness.meshTensionWeak:
    case PreservationSoundness.seasoningCracks:
      return kAccent;
    case PreservationSoundness.bubbleVialCompromised:
    case PreservationSoundness.brassTarnished:
      return kError;
  }
}

double getCapacityFraction(InspectionClassification classification) {
  switch (classification) {
    case InspectionClassification.testWeightScale:
      return 1.0;
    case InspectionClassification.seedDockingMill:
      return 0.86;
    case InspectionClassification.coreSampler:
      return 0.72;
    case InspectionClassification.triageSieve:
      return 0.58;
    case InspectionClassification.kernelCountBoard:
      return 0.42;
    case InspectionClassification.moistureComparator:
      return 0.28;
  }
}

IconData getClassificationIcon(InspectionClassification classification) {
  switch (classification) {
    case InspectionClassification.coreSampler:
      return Icons.straighten_rounded;
    case InspectionClassification.triageSieve:
      return Icons.grid_on_rounded;
    case InspectionClassification.testWeightScale:
      return Icons.balance_rounded;
    case InspectionClassification.seedDockingMill:
      return Icons.precision_manufacturing_rounded;
    case InspectionClassification.kernelCountBoard:
      return Icons.apps_rounded;
    case InspectionClassification.moistureComparator:
      return Icons.device_thermostat_rounded;
  }
}
