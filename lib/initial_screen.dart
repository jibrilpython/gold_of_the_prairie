import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gold_of_the_prairie/providers/user_provider.dart';
import 'package:gold_of_the_prairie/utils/const.dart';

class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

  Future<void> _enterArchive(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    await ref.read(userProvider).setFirstTimeUser(false);
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _LedgerPainter())),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: kPanelBg,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      border: Border.all(color: kOutline),
                    ),
                    child: Text(
                      'GRAIN LEDGER',
                      style: GoogleFonts.jetBrainsMono(
                        color: kAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    'GOLD OF\nTHE PRAIRIE.',
                    style: GoogleFonts.playfairDisplay(
                      color: kPrimaryText,
                      fontSize: 46.sp,
                      fontWeight: FontWeight.w700,
                      height: 0.94,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Container(width: 54.w, height: 2, color: kAccent),
                  SizedBox(height: 18.h),
                  Text(
                    'A weights-and-measures archive for grain triers, seed docks, nested sifts, and balance-beam test weight scales.',
                    style: GoogleFonts.inter(
                      color: kSecondaryText,
                      fontSize: 13.sp,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 180.h),
                  Center(
                    child: SizedBox(
                      width: 108.w,
                      height: 108.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size(108.w, 108.w),
                            painter: _BucketSealPainter(),
                          ),
                          Icon(
                            Icons.balance_rounded,
                            color: kAccent,
                            size: 30.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _enterArchive(context, ref),
                          child: Ink(
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: kAccent,
                              boxShadow: [
                                BoxShadow(
                                  color: kAccent.withValues(alpha: 0.28),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  'OPEN GRAIN LEDGER',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Center(
                    child: Text(
                      'Tap to begin cataloging your collection.',
                      style: GoogleFonts.inter(
                        color: kSecondaryText,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      'No harvest is official until it is measured.',
                      style: GoogleFonts.inter(
                        color: kSecondaryText.withValues(alpha: 0.72),
                        fontSize: 11.sp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kOutline.withValues(alpha: 0.7)
      ..strokeWidth = 0.6;
    for (double y = 88; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 28; x < size.width; x += 72) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint..color = kOutline.withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LedgerPainter oldDelegate) => false;
}

class _BucketSealPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = kOutline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    for (int i = 0; i < 54; i++) {
      final angle = i * math.pi * 2 / 54 - math.pi / 2;
      final tickPaint = Paint()
        ..color = i % 6 == 0 ? kAccent : kOutline
        ..strokeWidth = i % 6 == 0 ? 1.8 : 1.0;
      final inner = radius - (i % 6 == 0 ? 13 : 8);
      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * radius, math.sin(angle) * radius),
        tickPaint,
      );
    }
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 3),
      -math.pi / 2,
      math.pi * 2,
      false,
      Paint()
        ..color = kAccent.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      center,
      radius * 0.22,
      Paint()..color = kGoldSurface,
    );
  }

  @override
  bool shouldRepaint(covariant _BucketSealPainter oldDelegate) => false;
}
