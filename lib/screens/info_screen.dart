import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gold_of_the_prairie/providers/image_provider.dart';
import 'package:gold_of_the_prairie/providers/project_provider.dart';
import 'package:gold_of_the_prairie/utils/const.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final index = args['index'] as int;
    final project = ref.watch(projectProvider);
    if (index >= project.entries.length) {
      return const Scaffold(
        backgroundColor: kBackground,
        body: Center(child: Text('Instrument not found.')),
      );
    }
    final entry = project.entries[index];
    final imagePath = ref.watch(imageProvider).getImagePath(entry.photoPath);
    final commodityColor = getCommodityColor(entry.commodity);
    final conditionColor = getConditionColor(entry.preservationSoundness);

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.38,
            stretch: true,
            backgroundColor: kPrimaryText,
            leadingWidth: 68.w,
            leading: _roundAction(
              Icons.arrow_back_rounded,
              () => Navigator.pop(context),
            ),
            actions: [
              _roundAction(
                Icons.delete_outline_rounded,
                () => _delete(context, ref, index),
              ),
              SizedBox(width: 8.w),
              _roundAction(Icons.edit_rounded, () {
                ref.read(projectProvider).fillInput(ref, index);
                Navigator.pushNamed(
                  context,
                  '/add_screen',
                  arguments: {'index': index, 'isEdit': true},
                );
              }),
              SizedBox(width: 16.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: imagePath != null && File(imagePath).existsSync()
                  ? Image.file(File(imagePath), fit: BoxFit.cover)
                  : Container(
                      color: kPrimaryText,
                      child: Center(
                        child: CustomPaint(
                          size: Size(130.w, 130.w),
                          painter: _DetailBucketPainter(
                            fraction: getCapacityFraction(
                              entry.inspectionClassification,
                            ),
                            color: kAccent,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(kRadiusLarge),
                ),
              ),
              padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 130.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _tag(entry.commodity.label, commodityColor),
                      SizedBox(width: 8.w),
                      _tag(
                        entry.era.isEmpty ? 'Era unlisted' : entry.era,
                        kAccent,
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 58.w,
                        height: 58.w,
                        child: CustomPaint(
                          painter: _DetailBucketPainter(
                            fraction: getCapacityFraction(
                              entry.inspectionClassification,
                            ),
                            color: conditionColor == kSecondaryAccent
                                ? kSecondaryAccent
                                : kAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    entry.artisanHallmark,
                    style: GoogleFonts.playfairDisplay(
                      color: kPrimaryText,
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    entry.granaryRegistryLedger,
                    style: GoogleFonts.jetBrainsMono(
                      color: kSecondaryText,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: kPanelBg,
                      borderRadius: BorderRadius.circular(kRadiusSubtle),
                      border: Border.all(color: kOutline),
                      boxShadow: const [kShadowSubtle],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          getClassificationIcon(entry.inspectionClassification),
                          color: kAccent,
                          size: 34.sp,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.inspectionClassification.label
                                    .toUpperCase(),
                                style: GoogleFonts.jetBrainsMono(
                                  color: kAccent,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                entry.volumetricCapacityBounds,
                                style: GoogleFonts.jetBrainsMono(
                                  color: kPrimaryText,
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'RATED CAPACITY',
                                style: GoogleFonts.inter(
                                  color: kSecondaryText,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (entry.harvestGroundZero.isNotEmpty) ...[
                    SizedBox(height: 18.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 11.h,
                      ),
                      decoration: BoxDecoration(
                        color: kGreenSurface,
                        borderRadius: BorderRadius.circular(kRadiusPill),
                        border: Border.all(
                          color: kSecondaryAccent.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.route_rounded,
                            color: kSecondaryAccent,
                            size: 15.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              entry.harvestGroundZero,
                              style: GoogleFonts.inter(
                                color: kSecondaryAccent,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 28.h),
                  _section('TECHNICAL CERTIFICATE'),
                  _spec('Sieve Mesh Geometry', entry.sieveMeshGeometry.label),
                  _spec(
                    'Balance Beam Graduation',
                    entry.balanceBeamGraduation.label,
                  ),
                  _spec(
                    'Millwork & Hardware Metallurgy',
                    entry.millworkHardwareMetallurgy.label,
                  ),
                  _spec('Physical Proportions', entry.physicalProportions),
                  _spec('Temperature Range', entry.temperatureRange),
                  _spec('Calibrated Site', entry.calibratedSite),
                  _condition(
                    'Preservation Soundness',
                    entry.preservationSoundness.label,
                    conditionColor,
                  ),
                  if (entry.notes.isNotEmpty) ...[
                    SizedBox(height: 26.h),
                    _section('ARCHIVAL NOTES'),
                    SizedBox(height: 10.h),
                    Text(
                      entry.notes,
                      style: GoogleFonts.inter(
                        color: kPrimaryText,
                        fontSize: 14.sp,
                        height: 1.65,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundAction(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(kRadiusPill),
      border: Border.all(color: color.withValues(alpha: 0.18)),
    ),
    child: Text(
      text.toUpperCase(),
      style: GoogleFonts.jetBrainsMono(
        color: color,
        fontSize: 9.sp,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _section(String title) => Row(
    children: [
      Container(width: 3.w, height: 15.h, color: kAccent),
      SizedBox(width: 10.w),
      Text(
        title,
        style: GoogleFonts.jetBrainsMono(
          color: kPrimaryText,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    ],
  );

  Widget _spec(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 13.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 138.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 12.5.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: kPrimaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _condition(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.only(top: 13.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 138.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 12.5.sp,
              ),
            ),
          ),
          Container(
            width: 8.w,
            height: 8.w,
            margin: EdgeInsets.only(top: 4.h, right: 8.w),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _delete(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kPanelBg,
        title: Text(
          'Remove from ledger?',
          style: GoogleFonts.playfairDisplay(
            color: kPrimaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This harvest instrument record will be deleted from the local archive.',
          style: GoogleFonts.inter(color: kSecondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(projectProvider).deleteEntry(index);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: kError)),
          ),
        ],
      ),
    );
  }
}

class _DetailBucketPainter extends CustomPainter {
  final double fraction;
  final Color color;
  _DetailBucketPainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 5;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = kOutline.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      center,
      radius * 0.62,
      Paint()
        ..color = color.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _DetailBucketPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.color != color;
}
