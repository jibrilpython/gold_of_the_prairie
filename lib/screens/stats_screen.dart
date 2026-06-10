import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gold_of_the_prairie/enum/my_enums.dart';
import 'package:gold_of_the_prairie/models/project_model.dart';
import 'package:gold_of_the_prairie/providers/project_provider.dart';
import 'package:gold_of_the_prairie/utils/const.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  int? _pressedMetric;
  int? _pressedMethod;
  String? _pressedMetallurgy;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMetricDetail(String title, List<Widget> children) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(kRadiusLarge)),
          border: Border.all(color: kOutline),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: kOutline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: GoogleFonts.jetBrainsMono(
                color: kPrimaryText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 8.h),
            Divider(color: kOutline),
            SizedBox(height: 8.h),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showCommodityDetail(
    HarvestCommodity commodity,
    List<HarvestInstrumentModel> tools,
  ) {
    _showMetricDetail(
      '${commodity.label.toUpperCase()} TOOLS',
      [
        Text(
          '${tools.length} instrument${tools.length == 1 ? '' : 's'} classified',
          style: GoogleFonts.inter(
            color: kSecondaryText,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 12.h),
        ...tools.take(8).map(
          (t) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: getCommodityColor(commodity),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    t.artisanHallmark,
                    style: GoogleFonts.inter(
                      color: kPrimaryText,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  t.granaryRegistryLedger,
                  style: GoogleFonts.jetBrainsMono(
                    color: kSecondaryText,
                    fontSize: 8.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (tools.length > 8)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              '+${tools.length - 8} more entries',
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 11.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ModernGridPainter())),
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildModernHeader(),
              if (entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.query_stats_rounded,
                          color: kOutline,
                          size: 64.sp,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'NO LOGBOOK DATA.',
                          style: GoogleFonts.jetBrainsMono(
                            color: kSecondaryText,
                            fontSize: 12.sp,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 140.h),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildKeyMetrics(entries),
                      SizedBox(height: 22.h),
                      _sectionTitle('COMMODITY INDEX'),
                      SizedBox(height: 12.h),
                      _buildCommodityComposition(entries),
                      SizedBox(height: 22.h),
                      _sectionTitle('INSPECTION METHODOLOGY'),
                      SizedBox(height: 12.h),
                      _buildMethodGrid(entries),
                      SizedBox(height: 22.h),
                      _sectionTitle('PRESERVATION INTEGRITY'),
                      SizedBox(height: 12.h),
                      _buildConditionStackedBar(entries),
                      SizedBox(height: 22.h),
                      _sectionTitle('FOUNDRY & METALLURGY'),
                      SizedBox(height: 12.h),
                      _buildMetallurgyCards(entries),
                    ]),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20.h,
        bottom: 12.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: kAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(kRadiusPill),
                  border: Border.all(color: kAccent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'SYSTEM ANALYTICS',
                  style: GoogleFonts.jetBrainsMono(
                    color: kAccent,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Collection\nTelemetry',
                style: GoogleFonts.playfairDisplay(
                  color: kPrimaryText,
                  fontSize: 42.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(List<HarvestInstrumentModel> entries) {
    final total = entries.length;
    final sound = entries
        .where(
          (e) =>
              e.preservationSoundness == PreservationSoundness.museumGrade ||
              e.preservationSoundness == PreservationSoundness.displayCondition,
        )
        .length;
    final soundPct = total == 0 ? 0 : (sound / total * 100).round();

    final routes = entries
        .map((e) => e.harvestGroundZero)
        .where((e) => e.isNotEmpty)
        .toSet()
        .length;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Row(
          children: [
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTapDown: (_) => setState(() => _pressedMetric = 0),
                onTapUp: (_) {
                  setState(() => _pressedMetric = null);
                  _showMetricDetail(
                    'TOTAL INSTRUMENTS',
                    [
                      _detailRow('Active entries', total.toString()),
                      _detailRow('Museum grade', sound.toString()),
                      _detailRow('Unique routes', routes.toString()),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: kBackground,
                          borderRadius:
                              BorderRadius.circular(kRadiusSubtle),
                          border: Border.all(color: kOutline),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statPill(
                                'Total', total.toString(), kAccent),
                            _statPill('Sound', '$soundPct%',
                                kSecondaryAccent),
                            _statPill(
                                'Routes', routes.toString(), kPrimaryText),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                onTapCancel: () =>
                    setState(() => _pressedMetric = null),
                child: AnimatedScale(
                  scale: _pressedMetric == 0 ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    height: 120.h,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: kAccent,
                      borderRadius:
                          BorderRadius.circular(kRadiusStandard),
                      boxShadow: [
                        BoxShadow(
                          color: kAccent.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.storage_rounded,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 24.sp,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (total * _animation.value)
                                  .round()
                                  .toString()
                                  .padLeft(2, '0'),
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'TOTAL INSTRUMENTS',
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 120.h,
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) =>
                            setState(() => _pressedMetric = 1),
                        onTapUp: (_) {
                          setState(() => _pressedMetric = null);
                          _showMetricDetail(
                            'MUSEUM GRADE',
                            [
                              _detailRow('Museum grade entries',
                                  sound.toString()),
                              _detailRow(
                                  'Total entries', total.toString()),
                              _detailRow('Ratio', '$soundPct%'),
                              SizedBox(height: 8.h),
                              Text(
                                soundPct >= 70
                                    ? 'Strong preservation quality across the collection.'
                                    : 'Consider reviewing preservation protocols.',
                                style: GoogleFonts.inter(
                                  color: soundPct >= 70
                                      ? kSecondaryAccent
                                      : kAccent,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                        onTapCancel: () =>
                            setState(() => _pressedMetric = null),
                        child: AnimatedScale(
                          scale: _pressedMetric == 1 ? 0.95 : 1.0,
                          duration:
                              const Duration(milliseconds: 100),
                          child: _metricMiniCard(
                            'MUSEUM GRADE',
                            '${(soundPct * _animation.value).round()}%',
                            soundPct >= 70
                                ? kSecondaryAccent
                                : kAccent,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) =>
                            setState(() => _pressedMetric = 2),
                        onTapUp: (_) {
                          setState(() => _pressedMetric = null);
                          final routeList = entries
                              .map((e) => e.harvestGroundZero)
                              .where((e) => e.isNotEmpty)
                              .toSet()
                              .toList();
                          _showMetricDetail(
                            'ROUTES',
                            [
                              _detailRow('Unique market circuits',
                                  routeList.length.toString()),
                              if (routeList.isNotEmpty) ...[
                                SizedBox(height: 8.h),
                                ...routeList.map(
                                  (r) => Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 6.h),
                                    child: Row(
                                      children: [
                                        Icon(
                                            Icons
                                                .arrow_forward_rounded,
                                            size: 14.sp,
                                            color: kAccent),
                                        SizedBox(width: 6.w),
                                        Text(
                                          r,
                                          style: GoogleFonts.inter(
                                            color: kPrimaryText,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                        onTapCancel: () =>
                            setState(() => _pressedMetric = null),
                        child: AnimatedScale(
                          scale: _pressedMetric == 2 ? 0.95 : 1.0,
                          duration:
                              const Duration(milliseconds: 100),
                          child: _metricMiniCard(
                            'ROUTES',
                            (routes * _animation.value)
                                .round()
                                .toString(),
                            kPrimaryText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: kSecondaryText,
              fontSize: 13.sp,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: kPrimaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            color: color,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: kSecondaryText,
            fontSize: 7.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _metricMiniCard(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                color: color,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 8.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Icon(Icons.arrow_right_rounded, color: kAccent, size: 20.sp),
        SizedBox(width: 4.w),
        Text(
          title,
          style: GoogleFonts.jetBrainsMono(
            color: kPrimaryText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildCommodityComposition(List<HarvestInstrumentModel> entries) {
    final counts = <HarvestCommodity, int>{};
    for (final e in entries) {
      counts[e.commodity] = (counts[e.commodity] ?? 0) + 1;
    }
    final total = entries.length;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusStandard),
            border: Border.all(color: kOutline),
            boxShadow: const [kShadowSubtle],
          ),
          child: Column(
            children: () {
              final items = HarvestCommodity.values.map((commodity) {
                final count = counts[commodity] ?? 0;
                if (count == 0) return const SizedBox.shrink();
                final fraction = count / total;
                final color = getCommodityColor(commodity);
                final toolsOfType = entries
                    .where((e) => e.commodity == commodity)
                    .toList();
                return GestureDetector(
                  onTap: () => _showCommodityDetail(commodity, toolsOfType),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 80.w,
                        height: 24.h,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          commodity.label,
                          style: GoogleFonts.inter(
                            color: kPrimaryText,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: SizedBox(
                          height: 24.h,
                          child: Stack(
                            children: [
                              Container(
                                height: 24.h,
                                decoration: BoxDecoration(
                                  color: kOutline.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: fraction * _animation.value,
                                child: Container(
                                  height: 24.h,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(kRadiusSubtle),
                                    border: Border.all(color: color.withValues(alpha: 0.5)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        width: 36.w,
                        height: 24.h,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${(fraction * 100).round()}%',
                          style: GoogleFonts.jetBrainsMono(
                            color: color,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()..removeWhere((w) => w is SizedBox);

              final spacedItems = <Widget>[];
              for (var i = 0; i < items.length; i++) {
                spacedItems.add(items[i]);
                if (i < items.length - 1) spacedItems.add(SizedBox(height: 14.h));
              }
              return spacedItems;
            }(),
          ),
        );
      },
    );
  }

  Widget _buildMethodGrid(List<HarvestInstrumentModel> entries) {
    final counts = <InspectionClassification, int>{};
    for (final e in entries) {
      counts[e.inspectionClassification] =
          (counts[e.inspectionClassification] ?? 0) + 1;
    }

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.5,
      ),
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final item = sortedEntries[index];
        final method = item.key;
        final methodEntries = entries
            .where((e) => e.inspectionClassification == method)
            .toList();
        return GestureDetector(
          onTapDown: (_) =>
              setState(() => _pressedMethod = index),
          onTapUp: (_) {
            setState(() => _pressedMethod = null);
            _showMetricDetail(
              method.label.toUpperCase(),
              [
                _detailRow('Total count', item.value.toString()),
                _detailRow(
                  'Percentage',
                  '${(item.value / entries.length * 100).round()}%',
                ),
                SizedBox(height: 8.h),
                ...methodEntries.take(6).map(
                  (t) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Row(
                      children: [
                        Icon(getClassificationIcon(method),
                            size: 14.sp, color: kAccent),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            t.artisanHallmark,
                            style: GoogleFonts.inter(
                              color: kPrimaryText,
                              fontSize: 13.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (methodEntries.length > 6)
                  Text(
                    '+${methodEntries.length - 6} more',
                    style: GoogleFonts.inter(
                      color: kSecondaryText,
                      fontSize: 11.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            );
          },
          onTapCancel: () =>
              setState(() => _pressedMethod = null),
          child: AnimatedScale(
            scale: _pressedMethod == index ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: kPanelBg,
                borderRadius:
                    BorderRadius.circular(kRadiusSubtle),
                border: Border.all(color: kOutline),
                boxShadow: const [kShadowSubtle],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        getClassificationIcon(method),
                        color: kAccent.withValues(alpha: 0.7),
                        size: 20.sp,
                      ),
                      AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _pressedMethod == index
                              ? kAccent.withValues(alpha: 0.25)
                              : kAccent.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(kRadiusPill),
                        ),
                        child: Text(
                          item.value.toString(),
                          style: GoogleFonts.jetBrainsMono(
                            color: kAccent,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    method.label,
                    style: GoogleFonts.inter(
                      color: kPrimaryText,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConditionStackedBar(List<HarvestInstrumentModel> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final counts = <PreservationSoundness, int>{};
    for (final e in entries) {
      counts[e.preservationSoundness] =
          (counts[e.preservationSoundness] ?? 0) + 1;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusStandard),
            border: Border.all(color: kOutline),
            boxShadow: const [kShadowSubtle],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(kRadiusPill),
                child: SizedBox(
                  height: 14.h,
                  child: Row(
                    children: counts.entries.map((item) {
                      final condition = item.key;
                      final fraction = item.value / entries.length;
                      final conditionColor =
                          getConditionColor(condition);
                      final condEntries = entries
                          .where((e) =>
                              e.preservationSoundness == condition)
                          .toList();
                      return Expanded(
                        flex: (fraction * 1000).toInt(),
                        child: GestureDetector(
                          onTap: () => _showMetricDetail(
                            condition.label.toUpperCase(),
                            [
                              _detailRow(
                                  'Count', item.value.toString()),
                              _detailRow(
                                'Percentage',
                                '${(fraction * 100).round()}%',
                              ),
                              SizedBox(height: 8.h),
                              ...condEntries.take(6).map(
                                (t) => Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 6.h),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6.w,
                                        height: 6.w,
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              conditionColor,
                                          shape:
                                              BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          t.artisanHallmark,
                                          style:
                                              GoogleFonts.inter(
                                            color: kPrimaryText,
                                            fontSize: 13.sp,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow
                                              .ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (condEntries.length > 6)
                                Text(
                                  '+${condEntries.length - 6} more',
                                  style: GoogleFonts.inter(
                                    color: kSecondaryText,
                                    fontSize: 11.sp,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                          child:
                              Container(color: conditionColor),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Wrap(
                spacing: 16.w,
                runSpacing: 12.h,
                children: counts.entries.map((item) {
                  final condition = item.key;
                  final color = getConditionColor(condition);
                  final pct =
                      (item.value / entries.length * 100).round();
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '$pct% ${condition.label}',
                        style: GoogleFonts.inter(
                          color: kSecondaryText,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetallurgyCards(List<HarvestInstrumentModel> entries) {
    final counts = <Metallurgy, int>{};
    for (final e in entries) {
      counts[e.millworkHardwareMetallurgy] =
          (counts[e.millworkHardwareMetallurgy] ?? 0) + 1;
    }

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: sortedEntries.map((item) {
        final metalKey = item.key.label;
        return GestureDetector(
          onTapDown: (_) =>
              setState(() => _pressedMetallurgy = metalKey),
          onTapUp: (_) {
            setState(() => _pressedMetallurgy = null);
            final metalEntries = entries
                .where(
                    (e) => e.millworkHardwareMetallurgy == item.key)
                .toList();
            _showMetricDetail(
              '${item.key.label.toUpperCase()} TOOLS',
              [
                _detailRow('Total', item.value.toString()),
                _detailRow(
                  'Percentage',
                  '${(item.value / entries.length * 100).round()}%',
                ),
                SizedBox(height: 8.h),
                ...metalEntries.take(6).map(
                  (t) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Row(
                      children: [
                        Icon(Icons.circle_rounded,
                            size: 6.sp, color: kAccent),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            t.artisanHallmark,
                            style: GoogleFonts.inter(
                              color: kPrimaryText,
                              fontSize: 13.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (metalEntries.length > 6)
                  Text(
                    '+${metalEntries.length - 6} more',
                    style: GoogleFonts.inter(
                      color: kSecondaryText,
                      fontSize: 11.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            );
          },
          onTapCancel: () =>
              setState(() => _pressedMetallurgy = null),
          child: AnimatedScale(
            scale: _pressedMetallurgy == metalKey ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _pressedMetallurgy == metalKey
                    ? kAccent.withValues(alpha: 0.08)
                    : kBackground,
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(
                  color: _pressedMetallurgy == metalKey
                      ? kAccent.withValues(alpha: 0.4)
                      : kOutline,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.value}',
                    style: GoogleFonts.jetBrainsMono(
                      color: kPrimaryText,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    item.key.label.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: _pressedMetallurgy == metalKey
                          ? kAccent
                          : kSecondaryText,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ModernGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kOutline.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    const double spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ModernGridPainter oldDelegate) => false;
}
