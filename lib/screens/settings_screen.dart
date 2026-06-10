import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gold_of_the_prairie/models/project_model.dart';
import 'package:gold_of_the_prairie/providers/project_provider.dart';
import 'package:gold_of_the_prairie/utils/const.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _leftIndex = 0;
  int _rightIndex = 1;

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final canCompare = entries.length >= 2;
    if (entries.isNotEmpty) {
      _leftIndex = _leftIndex.clamp(0, entries.length - 1);
      _rightIndex = _rightIndex.clamp(0, entries.length - 1);
      if (canCompare && _leftIndex == _rightIndex) {
        _rightIndex = (_leftIndex + 1) % entries.length;
      }
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24.h,
              bottom: 16.h,
            ),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPARISON BENCH',
                      style: GoogleFonts.jetBrainsMono(
                        color: kAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Spec\nComparator',
                      style: GoogleFonts.playfairDisplay(
                        color: kPrimaryText,
                        fontSize: 42.sp,
                        fontWeight: FontWeight.w700,
                        height: 0.98,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Place two harvest instruments on the bench and inspect where their lineage, material, and calibration story diverge.',
                      style: GoogleFonts.inter(
                        color: kSecondaryText,
                        fontSize: 12.sp,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 140.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                canCompare
                    ? [
                        _selectors(entries),
                        SizedBox(height: 14.h),
                        _scoreCard(entries[_leftIndex], entries[_rightIndex]),
                        SizedBox(height: 14.h),
                        _comparisonRows(entries[_leftIndex], entries[_rightIndex]),
                      ]
                    : [_emptyState(entries.length)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectors(List<HarvestInstrumentModel> entries) {
    final left = entries[_leftIndex];
    final right = entries[_rightIndex];
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _instrumentSelector('BENCH A', left, entries, true)),
            SizedBox(width: 10.w),
            Expanded(child: _instrumentSelector('BENCH B', right, entries, false)),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                Icons.swap_horiz_rounded,
                'SWAP POSITIONS',
                () => setState(() {
                  final nextLeft = _rightIndex;
                  _rightIndex = _leftIndex;
                  _leftIndex = nextLeft;
                }),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _actionButton(
                Icons.open_in_new_rounded,
                'OPEN BENCH A',
                () => Navigator.pushNamed(
                  context,
                  '/info_screen',
                  arguments: {'index': _leftIndex},
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _instrumentSelector(
    String label,
    HarvestInstrumentModel entry,
    List<HarvestInstrumentModel> entries,
    bool isLeft,
  ) {
    final color = getCommodityColor(entry.commodity);
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9.w,
                height: 9.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 7.w),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  color: kSecondaryText,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: isLeft ? _leftIndex : _rightIndex,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: color),
              dropdownColor: kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusSubtle),
              selectedItemBuilder: (_) => entries
                  .map(
                    (e) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        e.artisanHallmark,
                        style: GoogleFonts.playfairDisplay(
                          color: kPrimaryText,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              items: List.generate(
                entries.length,
                (index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text(
                    entries[index].artisanHallmark,
                    style: GoogleFonts.inter(
                      color: kPrimaryText,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  if (isLeft) {
                    _leftIndex = value;
                    if (_leftIndex == _rightIndex) {
                      _rightIndex = (_leftIndex + 1) % entries.length;
                    }
                  } else {
                    _rightIndex = value;
                    if (_leftIndex == _rightIndex) {
                      _leftIndex = (_rightIndex + 1) % entries.length;
                    }
                  }
                });
              },
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            entry.granaryRegistryLedger,
            style: GoogleFonts.jetBrainsMono(
              color: kSecondaryText,
              fontSize: 8.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadiusPill),
        child: Ink(
          height: 44.h,
          decoration: BoxDecoration(
            color: kPrimaryText,
            borderRadius: BorderRadius.circular(kRadiusPill),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 17.sp),
              SizedBox(width: 7.w),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreCard(HarvestInstrumentModel left, HarvestInstrumentModel right) {
    final matches = _matchCount(left, right);
    final score = (matches / 7 * 100).round();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: kAccent,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        boxShadow: [
          BoxShadow(
            color: kAccent.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68.w,
            height: 68.w,
            child: CustomPaint(
              painter: _CompareGaugePainter(score / 100),
              child: Center(
                child: Text(
                  '$score%',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HERITAGE OVERLAP',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  _scoreMessage(score),
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonRows(HarvestInstrumentModel left, HarvestInstrumentModel right) {
    final rows = [
      _CompareRow('Commodity', left.commodity.label, right.commodity.label),
      _CompareRow(
        'Method',
        left.inspectionClassification.label,
        right.inspectionClassification.label,
      ),
      _CompareRow(
        'Metallurgy',
        left.millworkHardwareMetallurgy.label,
        right.millworkHardwareMetallurgy.label,
      ),
      _CompareRow(
        'Soundness',
        left.preservationSoundness.label,
        right.preservationSoundness.label,
      ),
      _CompareRow('Capacity', left.volumetricCapacityBounds, right.volumetricCapacityBounds),
      _CompareRow('Era', left.era, right.era),
      _CompareRow('Ground Zero', left.harvestGroundZero, right.harvestGroundZero),
    ];

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        children: rows.map(_comparisonRow).toList(),
      ),
    );
  }

  Widget _comparisonRow(_CompareRow row) {
    final same = row.left == row.right && row.left.isNotEmpty;
    final color = same ? kSecondaryAccent : kAccent;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: same ? kGreenSurface : kLedgerTint,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                same ? Icons.check_circle_rounded : Icons.compare_arrows_rounded,
                color: color,
                size: 15.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                row.label.toUpperCase(),
                style: GoogleFonts.jetBrainsMono(
                  color: color,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(child: _valueBlock(row.left)),
              SizedBox(width: 8.w),
              Expanded(child: _valueBlock(row.right)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _valueBlock(String text) {
    return Text(
      text.isEmpty ? 'Not recorded' : text,
      style: GoogleFonts.inter(
        color: text.isEmpty ? kSecondaryText.withValues(alpha: 0.55) : kPrimaryText,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _emptyState(int count) {
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusStandard),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        children: [
          Icon(Icons.compare_rounded, color: kAccent, size: 42.sp),
          SizedBox(height: 14.h),
          Text(
            count == 0 ? 'NO INSTRUMENTS TO COMPARE' : 'ADD ONE MORE INSTRUMENT',
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              color: kPrimaryText,
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'The comparison bench needs at least two cataloged tools before it can calculate overlap and contrast.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: kSecondaryText,
              fontSize: 12.sp,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  int _matchCount(HarvestInstrumentModel left, HarvestInstrumentModel right) {
    final pairs = [
      left.commodity == right.commodity,
      left.inspectionClassification == right.inspectionClassification,
      left.millworkHardwareMetallurgy == right.millworkHardwareMetallurgy,
      left.preservationSoundness == right.preservationSoundness,
      left.volumetricCapacityBounds == right.volumetricCapacityBounds,
      left.era == right.era,
      left.harvestGroundZero == right.harvestGroundZero,
    ];
    return pairs.where((same) => same).length;
  }

  String _scoreMessage(int score) {
    if (score >= 70) return 'Close provenance cousins';
    if (score >= 40) return 'Shared bench language';
    return 'Distinct archive specimens';
  }
}

class _CompareRow {
  final String label;
  final String left;
  final String right;
  const _CompareRow(this.label, this.left, this.right);
}

class _CompareGaugePainter extends CustomPainter {
  final double fraction;
  const _CompareGaugePainter(this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      6.2832 * fraction,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CompareGaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
