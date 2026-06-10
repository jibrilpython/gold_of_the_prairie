import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gold_of_the_prairie/enum/my_enums.dart';
import 'package:gold_of_the_prairie/models/project_model.dart';
import 'package:gold_of_the_prairie/providers/image_provider.dart';
import 'package:gold_of_the_prairie/providers/input_provider.dart';
import 'package:gold_of_the_prairie/providers/project_provider.dart';
import 'package:gold_of_the_prairie/providers/search_provider.dart';
import 'package:gold_of_the_prairie/utils/const.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  HarvestCommodity? _selectedCommodity;
  bool _isBtnPressed = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider);
    final search = ref.watch(searchProvider);
    final allEntries = project.entries;
    final entries = search
        .filteredList(allEntries)
        .where(
          (e) =>
              _selectedCommodity == null || e.commodity == _selectedCommodity,
        )
        .toList();
    final addButtonBottom = homeAddButtonBottom(context);
    final listBottomPad = addButtonBottom + 56.h;

    return Scaffold(
      backgroundColor: kBackground,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _LedgerGridPainter())),
          CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _header(allEntries.length),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      _searchBar(),
                      SizedBox(height: 14.h),
                      _commodityChips(),
                      SizedBox(height: 22.h),
                    ],
                  ),
                ),
              ),
              if (project.isLoading)
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    color: kAccent,
                    backgroundColor: kOutline,
                    minHeight: 2,
                  ),
                )
              else if (entries.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: _emptyState())
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  sliver: SliverList.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _HarvestCard(
                        entry: entry,
                        index: allEntries.indexOf(entry),
                      );
                    },
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: listBottomPad)),
            ],
          ),
          Positioned(
            right: 20.w,
            bottom: addButtonBottom,
            child: _addButton(),
          ),
        ],
      ),
    );
  }

  Widget _header(int count) {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 18.h,
        bottom: 20.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            decoration: BoxDecoration(
              color: kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusStandard),
              boxShadow: const [kShadowSubtle],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kRadiusStandard),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: kOutline),
                      borderRadius: BorderRadius.circular(kRadiusStandard),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 4.h),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: const BoxDecoration(
                                    color: kSecondaryAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'GOP / HARVEST REGISTRY',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: kSecondaryText,
                                    fontSize: 8.5.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'Gold of the Prairie',
                              style: GoogleFonts.playfairDisplay(
                                color: kPrimaryText,
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Manual grain inspection archive',
                              style: GoogleFonts.inter(
                                color: kSecondaryText,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      SizedBox(
                        width: 62.w,
                        height: 62.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: Size(62.w, 62.w),
                              painter: _BucketArcPainter(
                                fraction: count == 0 ? 0.15 : 1.0,
                                color: kAccent,
                                condition: count > 0,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  count.toString().padLeft(2, '0'),
                                  style: GoogleFonts.jetBrainsMono(
                                    color: kPrimaryText,
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  'TOOLS',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: kSecondaryText,
                                    fontSize: 6.5.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: kOutline.withValues(alpha: 0.9),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    children: [
                      _ledgerStat('LOT', count == 0 ? '--' : count.toString()),
                      _ledgerDivider(),
                      _ledgerStat(
                        'COMMODITIES',
                        '${HarvestCommodity.values.length}',
                      ),
                      _ledgerDivider(),
                      _ledgerStat('STATUS', count == 0 ? 'EMPTY' : 'ACTIVE'),
                    ],
                  ),
                ),
              ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4.h,
                      color: kAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ledgerStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: kSecondaryText,
              fontSize: 7.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: kPrimaryText,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ledgerDivider() {
    return Container(
      width: 1,
      height: 28.h,
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      color: kOutline,
    );
  }

  Widget _searchBar() {
    final hasQuery = _searchController.text.isNotEmpty;
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: ref.read(searchProvider).setSearchQuery,
      style: GoogleFonts.inter(
        color: kPrimaryText,
        fontSize: 14.sp,
      ),
      decoration: InputDecoration(
        hintText: 'Search ledger, maker, market circuit...',
        hintStyle: GoogleFonts.inter(
          color: kSecondaryText.withValues(alpha: 0.5),
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: kPanelBg,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: kSecondaryText,
          size: 20.sp,
        ),
        suffixIcon: hasQuery
            ? IconButton(
                icon: Icon(Icons.close_rounded, color: kSecondaryText, size: 20.sp),
                onPressed: () {
                  _searchController.clear();
                  ref.read(searchProvider).clearSearchQuery();
                  setState(() {});
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusStandard),
          borderSide: const BorderSide(color: kOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusStandard),
          borderSide: const BorderSide(color: kOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusStandard),
          borderSide: const BorderSide(color: kAccent, width: 2),
        ),
      ),
    );
  }

  Widget _commodityChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _chip(null, 'All'),
          ...HarvestCommodity.values.map((c) => _chip(c, c.label)),
        ],
      ),
    );
  }

  Widget _chip(HarvestCommodity? commodity, String label) {
    final selected = _selectedCommodity == commodity;
    final color = commodity == null
        ? kPrimaryText
        : getCommodityColor(commodity);
    return GestureDetector(
      onTap: () => setState(() => _selectedCommodity = commodity),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(
            color: selected ? color : kOutline,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            color: selected ? color : kSecondaryText,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isBtnPressed = true),
      onTapUp: (_) {
        setState(() => _isBtnPressed = false);
        ref.read(inputProvider).clearAll();
        ref.read(imageProvider).clearImage();
        Navigator.pushNamed(context, '/add_screen');
      },
      onTapCancel: () => setState(() => _isBtnPressed = false),
      child: AnimatedScale(
        scale: _isBtnPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusPill),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kAccent, Color(0xFF9A6F08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: kAccent.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: kAccent.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'LOG INSTRUMENT',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            size: Size(100.w, 100.w),
            painter: _HarvestEmptyPainter(),
          ),
          SizedBox(height: 24.h),
          Text(
            'NO TOOLS IN THIS HARVEST YET.',
            style: GoogleFonts.jetBrainsMono(
              color: kSecondaryText,
              fontSize: 11.sp,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _HarvestCard extends ConsumerWidget {
  final HarvestInstrumentModel entry;
  final int index;
  const _HarvestCard({required this.entry, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(imageProvider).getImagePath(entry.photoPath);
    final commodityColor = getCommodityColor(entry.commodity);
    final conditionColor = getConditionColor(entry.preservationSoundness);
    final fraction = getCapacityFraction(entry.inspectionClassification);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/info_screen',
        arguments: {'index': index},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          boxShadow: const [kShadowSubtle],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: kOutline),
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                child: SizedBox(
                  width: 82.w,
                  height: 92.h,
                  child: imagePath != null && File(imagePath).existsSync()
                      ? Image.file(File(imagePath), fit: BoxFit.cover)
                      : Container(
                          color: kLedgerTint,
                          child: Icon(
                            getClassificationIcon(
                              entry.inspectionClassification,
                            ),
                            color: kAccent.withValues(alpha: 0.36),
                            size: 30.sp,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.artisanHallmark,
                            style: GoogleFonts.playfairDisplay(
                              color: kPrimaryText,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 42.w,
                          height: 42.w,
                          child: CustomPaint(
                            painter: _BucketArcPainter(
                              fraction: fraction,
                              color: conditionColor == kSecondaryAccent
                                  ? kSecondaryAccent
                                  : kAccent,
                              condition: conditionColor == kSecondaryAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      entry.granaryRegistryLedger,
                      style: GoogleFonts.jetBrainsMono(
                        color: kSecondaryText,
                        fontSize: 8.5.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 5.h,
                      children: [
                        _pill(entry.commodity.label, commodityColor),
                        _pill(entry.inspectionClassification.label, kAccent),
                        if (entry.volumetricCapacityBounds.isNotEmpty)
                          _pill(entry.volumetricCapacityBounds, kPrimaryText),
                      ],
                    ),
                    if (entry.harvestGroundZero.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 9.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: kGreenSurface,
                          borderRadius: BorderRadius.circular(kRadiusPill),
                        ),
                        child: Text(
                          entry.harvestGroundZero,
                          style: GoogleFonts.inter(
                            color: kSecondaryAccent,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        child: Container(
          width: 3,
          color: commodityColor,
        ),
      ),
    ],
  ),
),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.jetBrainsMono(
          color: color,
          fontSize: 7.5.sp,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _BucketArcPainter extends CustomPainter {
  final double fraction;
  final Color color;
  final bool condition;
  _BucketArcPainter({
    required this.fraction,
    required this.color,
    required this.condition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 3;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = kOutline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      center,
      radius * 0.64,
      Paint()
        ..color = kOutline.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );
    if (condition) {
      canvas.drawCircle(
        center,
        radius * 0.18,
        Paint()..color = color.withValues(alpha: 0.22),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BucketArcPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.color != color;
}

class _HarvestEmptyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;

    final bw = size.width * 0.44;
    final bh = size.height * 0.38;
    final topY = cy - bh * 0.4;
    final botY = cy + bh * 0.35;
    final topR = bw / 2;
    final botR = bw * 0.32;

    // Shadow
    final shadowPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cx, botY + 6),
        width: bw * 0.85,
        height: bw * 0.16,
      ));
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Body (trapezoid with curved bottom)
    final bodyPath = Path()
      ..moveTo(cx - topR, topY)
      ..lineTo(cx + topR, topY)
      ..lineTo(cx + botR, botY)
      ..quadraticBezierTo(cx, botY + bh * 0.2, cx - botR, botY)
      ..close();

    final bodyGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFFE8C86A).withValues(alpha: 0.22),
        const Color(0xFFC49A2A).withValues(alpha: 0.35),
        const Color(0xFF8B6F1A).withValues(alpha: 0.40),
      ],
    );
    canvas.drawPath(
      bodyPath,
      paint
        ..shader = bodyGradient.createShader(
          Rect.fromLTRB(cx - topR, topY, cx + topR, botY),
        ),
    );

    // Body outline
    final outlinePaint = Paint()
      ..color = const Color(0xFFA67B1E).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(bodyPath, outlinePaint);

    // Slats (vertical lines)
    final slatPaint = Paint()
      ..color = const Color(0xFFA67B1E).withValues(alpha: 0.16)
      ..strokeWidth = 0.8;
    for (int i = 1; i < 7; i++) {
      final t = i / 7;
      final sx = cx - topR + bw * t;
      final ex = cx - botR + botR * 2 * t;
      canvas.drawLine(Offset(sx, topY), Offset(ex, botY), slatPaint);
    }

    // Rim
    final rimRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, topY), width: bw + 10, height: 6),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      rimRect,
      Paint()..color = const Color(0xFFB8860B).withValues(alpha: 0.50),
    );

    // Handle
    final handlePaint = Paint()
      ..color = const Color(0xFFA67B1E).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final handlePath = Path()
      ..moveTo(cx - topR * 0.55, topY)
      ..quadraticBezierTo(
        cx, topY - bh * 0.55, cx + topR * 0.55, topY,
      );
    canvas.drawPath(handlePath, handlePaint);

    // Grain stalks
    final stalkPaint = Paint()
      ..color = const Color(0xFFC49A2A).withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 0; i < 7; i++) {
      final bx = cx - bw * 0.3 + bw * 0.6 * (i / 6);
      final tx = bx + (i.isEven ? -5 : 5);
      final stalkTop = topY - 6 - i * 2.2;
      canvas.drawPath(
        Path()
          ..moveTo(bx, topY)
          ..quadraticBezierTo(bx + (i.isEven ? -2 : 2), topY - 5, tx, stalkTop),
        stalkPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(tx, stalkTop), width: 2.5, height: 4.5),
        Paint()..color = const Color(0xFFD4A843).withValues(alpha: 0.45),
      );
    }

    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant _HarvestEmptyPainter oldDelegate) => false;
}

class _LedgerGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kOutline.withValues(alpha: 0.5)
      ..strokeWidth = 0.55;
    for (double y = 102; y < size.height; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 24; x < size.width; x += 78) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint..color = kOutline.withValues(alpha: 0.28),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LedgerGridPainter oldDelegate) => false;
}
