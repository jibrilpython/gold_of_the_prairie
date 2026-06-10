import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:gold_of_the_prairie/enum/my_enums.dart';
import 'package:gold_of_the_prairie/models/project_model.dart';
import 'package:gold_of_the_prairie/providers/project_provider.dart';
import 'package:gold_of_the_prairie/utils/const.dart';

// Physics and Aesthetic Constants
const int kGridW = 120;
const int kGridH = 220;

const Color kGranaryDark = Color(0xFF0D0B08);
const Color kWheatGold = Color(0xFFE8C040);
const Color kHarvestAmber = Color(0xFFD4820A);
const Color kCornPale = Color(0xFFF0D870);
const Color kCrackedKernel = Color(0xFF8A6820);
const Color kChaffWhite = Color(0xFFF0E8C8);
const Color kTrierBrass = Color(0xFFC8922A);
const Color kScaleIvory = Color(0xFFF2ECD0);
const Color kGradeStampRed = Color(0xFFC84A2A);

class _GrainCell {
  int type = 0; // 0: empty, 1: obstacle, 2-6: grain types, 10: bucket
  double angle = 0.0;
  bool isMoving = false;
  
  _GrainCell();
}

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

enum _ShowcaseMode { sandbox, bushelTest, viewingDetails }

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen> with TickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_GrainCell> _grid = List.generate(kGridW * kGridH, (_) => _GrainCell());
  
  double _gx = 0.0;
  double _gy = 1.0;
  int _ticks = 0;
  
  List<HarvestInstrumentModel> _nodes = [];
  final Map<int, Offset> _nodePositions = {};
  int? _draggedNodeIndex;
  
  _ShowcaseMode _mode = _ShowcaseMode.sandbox;
  int? _focusedNodeIndex;
  int _bucketGrainCount = 0;
  int _targetBucketCount = 100;
  
  // Sieve bands: 8 bands tracking grain counts
  final List<int> _sieveCounts = List.filled(8, 0);

  @override
  void initState() {
    super.initState();
    accelerometerEventStream().listen((AccelerometerEvent event) {
      if (!mounted) return;
      // Map device tilt to gravity vector
      // iOS/Android axes can vary, but generally x is lateral tilt, y is longitudinal
      setState(() {
        _gx = -event.x / 9.8;
        _gy = event.y / 9.8; // Use positive event.y so gravity points DOWN when phone is held upright
        // Ensure some downward gravity if flat
        if (_gy < 0.1 && _gy > -0.1) _gy = 0.1;
      });
    });

    _ticker = createTicker(_tick)..start();
  }
  
  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _buildObstacles() {
    // Clear old obstacles
    for (int i = 0; i < _grid.length; i++) {
      if (_grid[i].type == 1 || _grid[i].type == 10) {
        _grid[i].type = 0;
      }
    }
    
    // Sandbox mode: draw instrument nodes
    if (_mode == _ShowcaseMode.sandbox) {
      for (int i = 0; i < _nodes.length; i++) {
        if (_nodePositions[i] == null) continue;
        final pos = _nodePositions[i]!;
        final gx = (pos.dx / MediaQuery.of(context).size.width * kGridW).toInt();
        final gy = (pos.dy / MediaQuery.of(context).size.height * kGridH).toInt();
        
        // Simple 8x8 obstacle
        for (int dy = -4; dy <= 4; dy++) {
          for (int dx = -4; dx <= 4; dx++) {
            int cx = gx + dx;
            int cy = gy + dy;
            if (cx >= 0 && cx < kGridW && cy >= 0 && cy < kGridH) {
              _grid[cy * kGridW + cx].type = 1; // Obstacle
            }
          }
        }
      }
    } else if (_mode == _ShowcaseMode.bushelTest) {
      // Draw bucket obstacle
      int bx = kGridW ~/ 2;
      int by = kGridH ~/ 2;
      // Bucket walls
      for (int dy = 0; dy < 15; dy++) {
        int left = bx - 10;
        int right = bx + 10;
        if (left >= 0 && left < kGridW) _grid[(by + dy) * kGridW + left].type = 10;
        if (right >= 0 && right < kGridW) _grid[(by + dy) * kGridW + right].type = 10;
      }
      for (int dx = -10; dx <= 10; dx++) {
        int cx = bx + dx;
        if (cx >= 0 && cx < kGridW) _grid[(by + 15) * kGridW + cx].type = 10;
      }
    }
  }

  void _pourGrain(int x, int y, int radius, int count) {
    final rand = math.Random();
    int poured = 0;
    for (int dy = -radius; dy <= radius; dy++) {
      for (int dx = -radius; dx <= radius; dx++) {
        if (dx*dx + dy*dy <= radius*radius) {
          int cx = x + dx;
          int cy = y + dy;
          if (cx >= 0 && cx < kGridW && cy >= 0 && cy < kGridH) {
            int idx = cy * kGridW + cx;
            if (_grid[idx].type == 0) {
              double r = rand.nextDouble();
              int type = 2; // Wheat default
              if (r > 0.9) {
                type = 5; // Chaff
              } else if (r > 0.8) {
                type = 4; // Cracked
              } else if (r > 0.6) {
                type = 3; // Barley
              } else if (r > 0.4) {
                type = 4; // Corn
              }
              _grid[idx].type = type;
              _grid[idx].isMoving = true;
              poured++;
              if (poured >= count) return;
            }
          }
        }
      }
    }
  }

  void _tick(Duration elapsed) {
    _ticks++;
    final currentEntries = ref.read(projectProvider).entries;
    if (_nodes.length != currentEntries.length) {
      _nodes = currentEntries.toList();
      final size = MediaQuery.of(context).size;
      final rand = math.Random(42);
      _nodePositions.clear();
      for (int i = 0; i < _nodes.length; i++) {
        _nodePositions[i] = Offset(
          40 + rand.nextDouble() * (size.width - 80),
          80 + rand.nextDouble() * (size.height - 200),
        );
      }
    }

    _buildObstacles();
    
    // Constant slow rain
    if (_mode == _ShowcaseMode.sandbox && _ticks % 5 == 0) {
      final rand = math.Random();
      int rx = rand.nextInt(kGridW);
      if (_grid[rx].type == 0) {
        _grid[rx].type = rand.nextDouble() > 0.8 ? 5 : 2; // Mostly wheat and chaff
      }
    }

    // Pour grain during bushel test automatically
    if (_mode == _ShowcaseMode.bushelTest) {
      if (_ticks % 2 == 0) {
        int px = kGridW ~/ 2;
        _pourGrain(px, 5, 4, 15);
      }
    }

    // Process Cellular Automaton
    bool passLeftToRight = _ticks % 2 == 0;
    final rand = math.Random();

    for (int i = 0; i < 8; i++) {
      _sieveCounts[i] = 0;
    }

    int bucketGrainThisTick = 0;
    int bx = kGridW ~/ 2;
    int by = kGridH ~/ 2;

    for (int y = kGridH - 2; y >= 0; y--) {
      for (int i = 0; i < kGridW; i++) {
        int x = passLeftToRight ? i : kGridW - 1 - i;
        int idx = y * kGridW + x;
        _GrainCell cell = _grid[idx];
        
        if (cell.type >= 2 && cell.type <= 6) {
          // Count for Sieve
          int band = (x / kGridW * 8).floor().clamp(0, 7);
          _sieveCounts[band]++;

          // Mini-game bucket detection
          if (_mode == _ShowcaseMode.bushelTest) {
            if (y > by && y < by + 15 && x > bx - 10 && x < bx + 10) {
              // Convert to bucket mass, make it disappear
              cell.type = 0;
              bucketGrainThisTick++;
              continue;
            }
          }
          
          cell.isMoving = false;

          // Determine preferred fall direction based on gravity
          int dxGravity = _gx > 0.15 ? 1 : (_gx < -0.15 ? -1 : 0);
          int dyGravity = 1; // Always fall down the screen visually
          
          if (dyGravity == 1) { // Standard downward fall
            int down = (y + 1) * kGridW + x;
            if (y + 1 < kGridH && _grid[down].type == 0) {
              _grid[down] = cell;
              _grid[idx] = _GrainCell();
              _grid[down].isMoving = true;
              _grid[down].angle = math.pi / 2;
            } else {
              // Slide
              int slideDir = rand.nextBool() ? 1 : -1;
              if (dxGravity != 0 && rand.nextDouble() > 0.1) slideDir = dxGravity; // Bias toward tilt
              
              int sideX = x + slideDir;
              if (sideX >= 0 && sideX < kGridW) {
                int downSide = (y + 1) * kGridW + sideX;
                if (y + 1 < kGridH && _grid[downSide].type == 0) {
                  _grid[downSide] = cell;
                  _grid[idx] = _GrainCell();
                  _grid[downSide].isMoving = true;
                  _grid[downSide].angle = slideDir > 0 ? math.pi / 4 : 3 * math.pi / 4;
                } else if (dxGravity == slideDir) {
                   // If we are tilting, allow purely horizontal slide
                   int side = y * kGridW + sideX;
                   if (_grid[side].type == 0) {
                     _grid[side] = cell;
                     _grid[idx] = _GrainCell();
                     _grid[side].isMoving = true;
                     _grid[side].angle = slideDir > 0 ? 0 : math.pi;
                   }
                } else {
                  int otherSideX = x - slideDir;
                  if (otherSideX >= 0 && otherSideX < kGridW) {
                    int downOtherSide = (y + 1) * kGridW + otherSideX;
                    if (y + 1 < kGridH && _grid[downOtherSide].type == 0) {
                      _grid[downOtherSide] = cell;
                      _grid[idx] = _GrainCell();
                      _grid[downOtherSide].isMoving = true;
                      _grid[downOtherSide].angle = slideDir > 0 ? 3 * math.pi / 4 : math.pi / 4;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    if (bucketGrainThisTick > 0) {
      _bucketGrainCount += bucketGrainThisTick;
      if (_bucketGrainCount >= _targetBucketCount && _mode == _ShowcaseMode.bushelTest) {
        // Balanced!
        HapticFeedback.heavyImpact();
        setState(() {
          _mode = _ShowcaseMode.viewingDetails;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            '/info_screen',
            arguments: {'index': _focusedNodeIndex},
          ).then((_) {
            if (mounted) {
              setState(() {
                _mode = _ShowcaseMode.sandbox;
                _focusedNodeIndex = null;
                _bucketGrainCount = 0;
              });
            }
          });
        });
      }
    }

    setState(() {}); // Trigger repaint
  }

  void _handleTap(TapUpDetails details) {
    if (_mode != _ShowcaseMode.sandbox) return;
    HapticFeedback.mediumImpact();
    final size = MediaQuery.of(context).size;
    int gx = (details.localPosition.dx / size.width * kGridW).toInt();
    int gy = (details.localPosition.dy / size.height * kGridH).toInt();
    _pourGrain(gx, gy, 8, 80);
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (_mode != _ShowcaseMode.sandbox) return;
    
    // Find nearest node
    double minD = double.infinity;
    int? nearest;
    
    for (int i = 0; i < _nodes.length; i++) {
      if (_nodePositions[i] == null) continue;
      final dist = (details.localPosition - _nodePositions[i]!).distance;
      if (dist < 40.w && dist < minD) {
        minD = dist;
        nearest = i;
      }
    }

    if (nearest != null) {
      HapticFeedback.heavyImpact();
      setState(() {
        _focusedNodeIndex = nearest;
        _mode = _ShowcaseMode.bushelTest;
        _bucketGrainCount = 0;
        
        // Target depends on commodity
        final com = _nodes[nearest!].commodity;
        if (com == HarvestCommodity.wheat) {
          _targetBucketCount = 600; // 60 lbs
        } else if (com == HarvestCommodity.corn) {
          _targetBucketCount = 560; // 56 lbs
        } else if (com == HarvestCommodity.barley) {
          _targetBucketCount = 480; // 48 lbs
        } else {
          _targetBucketCount = 500;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: kGranaryDark,
      body: GestureDetector(
        onTapUp: _handleTap,
        onLongPressStart: _handleLongPressStart,
        onPanStart: (details) {
          if (_mode != _ShowcaseMode.sandbox) return;
          double minD = double.infinity;
          for (int i = 0; i < _nodes.length; i++) {
            if (_nodePositions[i] == null) continue;
            final dist = (details.localPosition - _nodePositions[i]!).distance;
            if (dist < 40.w && dist < minD) {
              minD = dist;
              _draggedNodeIndex = i;
            }
          }
        },
        onPanUpdate: (details) {
          if (_draggedNodeIndex != null) {
            setState(() {
              _nodePositions[_draggedNodeIndex!] = details.localPosition;
            });
          }
        },
        onPanEnd: (_) => _draggedNodeIndex = null,
        child: Stack(
          children: [
            // Grain Layer
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _GranaryFloorPainter(_grid),
                ),
              ),
            ),
            
            // Nodes Layer
            if (_mode == _ShowcaseMode.sandbox)
              for (int i = 0; i < _nodes.length; i++)
                if (_nodePositions[i] != null)
                  Positioned(
                    left: _nodePositions[i]!.dx - 24.w,
                    top: _nodePositions[i]!.dy - 24.w,
                    child: _InstrumentNode(model: _nodes[i]),
                  ),
                  
            // Sieve Analysis Layer
            if (_mode == _ShowcaseMode.sandbox)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: size.height * 0.15,
                child: CustomPaint(
                  painter: _SieveDistributionPainter(_sieveCounts),
                ),
              ),
              
            // Bushel Test Mini-Game Layer
            if (_mode == _ShowcaseMode.bushelTest)
              Positioned.fill(
                child: CustomPaint(
                  painter: _WinchesterBushelPainter(
                    progress: math.min(1.0, _bucketGrainCount / _targetBucketCount),
                  ),
                ),
              ),
              
            // Title Header
            if (_mode == _ShowcaseMode.sandbox)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16.h,
                left: 20.w,
                child: Text(
                  'THE GRANARY FLOOR\nPHYSICS SANDBOX',
                  style: GoogleFonts.jetBrainsMono(
                    color: kScaleIvory.withValues(alpha: 0.5),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    height: 1.5,
                  ),
                ),
              ),
              
            // Bushel Test Exit Button
            if (_mode == _ShowcaseMode.bushelTest)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16.h,
                right: 20.w,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _mode = _ShowcaseMode.sandbox;
                      _focusedNodeIndex = null;
                      _bucketGrainCount = 0;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: kGranaryDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: kTrierBrass),
                    ),
                    child: Icon(Icons.close_rounded, color: kScaleIvory, size: 24.sp),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InstrumentNode extends StatelessWidget {
  final HarvestInstrumentModel model;
  const _InstrumentNode({required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: kGranaryDark,
        border: Border.all(color: kTrierBrass, width: 2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: kGranaryDark.withValues(alpha: 0.8),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Center(
        child: Icon(
          getClassificationIcon(model.inspectionClassification),
          color: kScaleIvory,
          size: 20.sp,
        ),
      ),
    );
  }
}

class _GranaryFloorPainter extends CustomPainter {
  final List<_GrainCell> grid;
  _GranaryFloorPainter(this.grid);

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / kGridW;
    final cellH = size.height / kGridH;
    
    final paints = {
      2: Paint()..color = kWheatGold,
      3: Paint()..color = kHarvestAmber,
      4: Paint()..color = kCornPale,
      5: Paint()..color = kCrackedKernel,
      6: Paint()..color = kChaffWhite,
      10: Paint()..color = kTrierBrass, // Bucket walls
    };

    for (int y = 0; y < kGridH; y++) {
      for (int x = 0; x < kGridW; x++) {
        final cell = grid[y * kGridW + x];
        if (cell.type >= 2 && cell.type <= 6) {
          canvas.save();
          canvas.translate(x * cellW + cellW / 2, y * cellH + cellH / 2);
          canvas.rotate(cell.angle);
          canvas.drawOval(
            Rect.fromCenter(center: Offset.zero, width: cellW * 0.9, height: cellH * 1.5),
            paints[cell.type]!,
          );
          canvas.restore();
        } else if (cell.type == 10) {
          canvas.drawRect(
            Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH),
            paints[10]!,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GranaryFloorPainter oldDelegate) => true;
}

class _SieveDistributionPainter extends CustomPainter {
  final List<int> counts;
  _SieveDistributionPainter(this.counts);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = kHarvestAmber.withValues(alpha: 0.15);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final linePaint = Paint()
      ..color = kTrierBrass
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    int maxCount = counts.reduce(math.max);
    if (maxCount == 0) maxCount = 1;

    final path = Path();
    final stepX = size.width / (counts.length - 1);
    
    for (int i = 0; i < counts.length; i++) {
      double x = i * stepX;
      double y = size.height - (counts[i] / maxCount * size.height * 0.8);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        double px = (i - 1) * stepX;
        double py = size.height - (counts[i - 1] / maxCount * size.height * 0.8);
        path.quadraticBezierTo(px + stepX / 2, py, x, y);
      }
    }
    
    canvas.drawPath(path, linePaint);
    
    // Mean marker
    double totalWeighted = 0;
    int totalCount = 0;
    for (int i = 0; i < counts.length; i++) {
      totalWeighted += counts[i] * i;
      totalCount += counts[i];
    }
    if (totalCount > 0) {
      double meanIndex = totalWeighted / totalCount;
      double meanX = meanIndex * stepX;
      final meanPaint = Paint()
        ..color = kScaleIvory.withValues(alpha: 0.7)
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(meanX, 0), Offset(meanX, size.height), meanPaint);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'MEAN TEST WEIGHT',
          style: GoogleFonts.ibmPlexMono(
            color: kScaleIvory,
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(meanX + 4, 10));
    }
  }

  @override
  bool shouldRepaint(covariant _SieveDistributionPainter oldDelegate) => true;
}

class _WinchesterBushelPainter extends CustomPainter {
  final double progress;
  _WinchesterBushelPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final pivotY = center.dy - 120;
    
    // Balance Beam
    final beamPaint = Paint()
      ..color = kTrierBrass
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
      
    canvas.save();
    canvas.translate(center.dx, pivotY);
    // Tip beam based on progress (0 -> -20 deg, 1 -> 0 deg, >1 -> +deg)
    double angle = -0.3 + (progress * 0.3);
    canvas.rotate(angle);
    canvas.drawLine(const Offset(-80, 0), const Offset(80, 0), beamPaint);
    canvas.restore();
    
    // Pivot Base
    final pivotPaint = Paint()..color = kScaleIvory;
    final path = Path()
      ..moveTo(center.dx, pivotY)
      ..lineTo(center.dx - 12, pivotY + 20)
      ..lineTo(center.dx + 12, pivotY + 20)
      ..close();
    canvas.drawPath(path, pivotPaint);
    
    // Target notch
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'WINCHESTER BUSHEL\nTEST WEIGHT',
        style: GoogleFonts.playfairDisplay(
          color: kScaleIvory,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, pivotY - 60),
    );
  }

  @override
  bool shouldRepaint(covariant _WinchesterBushelPainter oldDelegate) => true;
}
