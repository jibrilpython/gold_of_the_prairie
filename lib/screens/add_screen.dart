import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gold_of_the_prairie/common/photo_bottom_sheet.dart';
import 'package:gold_of_the_prairie/enum/my_enums.dart';
import 'package:gold_of_the_prairie/providers/image_provider.dart';
import 'package:gold_of_the_prairie/providers/input_provider.dart';
import 'package:gold_of_the_prairie/providers/project_provider.dart';
import 'package:gold_of_the_prairie/utils/const.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  late final TextEditingController _artisanHallmarkCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _proportionsCtrl;
  late final TextEditingController _groundZeroCtrl;
  late final TextEditingController _temperatureCtrl;
  late final TextEditingController _eraCtrl;
  late final TextEditingController _calibratedSiteCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final p = ref.read(inputProvider);
    _artisanHallmarkCtrl = TextEditingController(text: p.artisanHallmark);
    _capacityCtrl = TextEditingController(text: p.volumetricCapacityBounds);
    _proportionsCtrl = TextEditingController(text: p.physicalProportions);
    _groundZeroCtrl = TextEditingController(text: p.harvestGroundZero);
    _temperatureCtrl = TextEditingController(text: p.temperatureRange);
    _eraCtrl = TextEditingController(text: p.era);
    _calibratedSiteCtrl = TextEditingController(text: p.calibratedSite);
    _notesCtrl = TextEditingController(text: p.notes);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in [
      _artisanHallmarkCtrl,
      _capacityCtrl,
      _proportionsCtrl,
      _groundZeroCtrl,
      _temperatureCtrl,
      _eraCtrl,
      _calibratedSiteCtrl,
      _notesCtrl,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _goTo(int page) => _pageController.animateToPage(
    page,
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeInOut,
  );

  void _save() async {
    final p = ref.read(inputProvider);
    p.artisanHallmark = _artisanHallmarkCtrl.text.trim();
    p.volumetricCapacityBounds = _capacityCtrl.text.trim();
    p.physicalProportions = _proportionsCtrl.text.trim();
    p.harvestGroundZero = _groundZeroCtrl.text.trim();
    p.temperatureRange = _temperatureCtrl.text.trim();
    p.era = _eraCtrl.text.trim();
    p.calibratedSite = _calibratedSiteCtrl.text.trim();
    p.notes = _notesCtrl.text.trim();

    if (_artisanHallmarkCtrl.text.trim().isEmpty ||
        _capacityCtrl.text.trim().isEmpty ||
        _groundZeroCtrl.text.trim().isEmpty) {
      _error('ARTISAN HALLMARK, CAPACITY, AND HARVEST GROUND ZERO REQUIRED');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SavingDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 650));
    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pop(context);
    ref.read(inputProvider).clearAll();
    ref.read(imageProvider).clearImage();
  }

  void _error(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: kError,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusSubtle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'EDIT HARVEST TOOL' : 'LOG HARVEST TOOL',
          style: GoogleFonts.jetBrainsMono(
            color: kAccent,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(26.h),
          child: _steps(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [_pageIdentity(), _pageSpecs(), _pageArchive()],
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _steps() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 12.h),
      child: Row(
        children: List.generate(
          3,
          (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? 6.w : 0),
              height: 3.h,
              decoration: BoxDecoration(
                color: i <= _currentPage ? kAccent : kOutline,
                borderRadius: BorderRadius.circular(kRadiusPill),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageIdentity() {
    final p = ref.watch(inputProvider);
    return _page('01', 'Instrument Identity', [
      _photoSection(),
      SizedBox(height: 24.h),
      _systemLedgerPreview(),
      _enumGroup<HarvestCommodity>(
        'GRAIN COMMODITY',
        HarvestCommodity.values,
        p.commodity,
        (v) => ref.read(inputProvider).commodity = v,
        (v) => v.label,
      ),
      _enumGroup<InspectionClassification>(
        'INSPECTION CLASSIFICATION',
        InspectionClassification.values,
        p.inspectionClassification,
        (v) => ref.read(inputProvider).inspectionClassification = v,
        (v) => v.label,
      ),
      _field(
        'ARTISAN HALLMARK',
        _artisanHallmarkCtrl,
        'PrairieCraft IronWorks, Great Plains Balance Co.',
        (v) => ref.read(inputProvider).artisanHallmark = v,
      ),
    ]);
  }

  Widget _pageSpecs() {
    final p = ref.watch(inputProvider);
    return _page('02', 'Measurement & Make', [
      _field(
        'VOLUMETRIC CAPACITY BOUNDS',
        _capacityCtrl,
        '1 Pint Bushel, 30-inch Insertion Depth, 500-Kernel Matrix',
        (v) => ref.read(inputProvider).volumetricCapacityBounds = v,
      ),
      _enumGroup<SieveMeshGeometry>(
        'SIEVE MESH GEOMETRY',
        SieveMeshGeometry.values,
        p.sieveMeshGeometry,
        (v) => ref.read(inputProvider).sieveMeshGeometry = v,
        (v) => v.label,
      ),
      _enumGroup<BalanceBeamGraduation>(
        'BALANCE BEAM GRADUATION',
        BalanceBeamGraduation.values,
        p.balanceBeamGraduation,
        (v) => ref.read(inputProvider).balanceBeamGraduation = v,
        (v) => v.label,
      ),
      _enumGroup<Metallurgy>(
        'MILLWORK & HARDWARE METALLURGY',
        Metallurgy.values,
        p.millworkHardwareMetallurgy,
        (v) => ref.read(inputProvider).millworkHardwareMetallurgy = v,
        (v) => v.label,
      ),
      _field(
        'PHYSICAL PROPORTIONS',
        _proportionsCtrl,
        '30 in probe, 18 x 18 x 6 in nest, 7.2 lb dry mass',
        (v) => ref.read(inputProvider).physicalProportions = v,
      ),
      _field(
        'TEMPERATURE RANGE',
        _temperatureCtrl,
        '15-35 C inspection room calibration',
        (v) => ref.read(inputProvider).temperatureRange = v,
      ),
    ]);
  }

  Widget _pageArchive() {
    final p = ref.watch(inputProvider);
    return _page('03', 'Provenance Ledger', [
      _enumGroup<PreservationSoundness>(
        'PRESERVATION SOUNDNESS',
        PreservationSoundness.values,
        p.preservationSoundness,
        (v) => ref.read(inputProvider).preservationSoundness = v,
        (v) => v.label,
      ),
      _field(
        'ERA',
        _eraCtrl,
        '1930s',
        (v) => ref.read(inputProvider).era = v,
        inputFormatters: const [_EraInputFormatter()],
      ),
      _field(
        'CALIBRATED SITE',
        _calibratedSiteCtrl,
        'Fictional mill, foundry, or ceramic kiln',
        (v) => ref.read(inputProvider).calibratedSite = v,
      ),
      _field(
        'HARVEST GROUND ZERO',
        _groundZeroCtrl,
        'Red River Valley elevator route',
        (v) => ref.read(inputProvider).harvestGroundZero = v,
      ),
      _field(
        'ARCHIVAL NOTES',
        _notesCtrl,
        'Mesh tension, brass tarnish, market history, inspection story...',
        (v) => ref.read(inputProvider).notes = v,
        maxLines: 5,
      ),
    ]);
  }

  Widget _page(String num, String title, List<Widget> children) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                num,
                style: GoogleFonts.jetBrainsMono(
                  color: kAccent,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 12.w),
              Container(width: 24.w, height: 1, color: kOutline),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    color: kPrimaryText,
                    fontSize: 27.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          ...children,
        ],
      ),
    );
  }

  Widget _photoSection() {
    final imagePath = ref
        .watch(imageProvider)
        .getImagePath(ref.watch(imageProvider).resultImage);
    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        width: double.infinity,
        height: 166.h,
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
        ),
        clipBehavior: Clip.antiAlias,
        child: imagePath != null && File(imagePath).existsSync()
            ? Image.file(File(imagePath), fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    color: kAccent.withValues(alpha: 0.45),
                    size: 32.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'TAP TO PHOTOGRAPH INSTRUMENT',
                    style: GoogleFonts.jetBrainsMono(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _systemLedgerPreview() {
    final p = ref.watch(inputProvider);
    final ledger = widget.isEdit && p.granaryRegistryLedger.isNotEmpty
        ? p.granaryRegistryLedger
        : 'GOP-GRAIN-####-${p.commodity.label.toUpperCase()}-${p.inspectionClassification.label.split(' ').last.substring(0, 1).toUpperCase()}';
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: kLedgerTint,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
      ),
      child: Row(
        children: [
          Icon(Icons.qr_code_2_rounded, color: kAccent, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM GENERATED LEDGER',
                  style: GoogleFonts.jetBrainsMono(
                    color: kSecondaryText,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  ledger,
                  style: GoogleFonts.jetBrainsMono(
                    color: kPrimaryText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    String hint,
    ValueChanged<String> onChanged, {
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 22.h),
      child: TextField(
        controller: ctrl,
        onChanged: onChanged,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        style: GoogleFonts.inter(color: kPrimaryText, fontSize: 14.sp),
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }

  Widget _enumGroup<T>(
    String label,
    List<T> values,
    T current,
    ValueChanged<T> onSelected,
    String Function(T) labelBuilder,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 7.w,
            runSpacing: 7.h,
            children: values.map((value) {
              final selected = value == current;
              return GestureDetector(
                onTap: () => onSelected(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 190),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? kAccent : kPanelBg,
                    borderRadius: BorderRadius.circular(kRadiusSubtle),
                    border: Border.all(color: selected ? kAccent : kOutline),
                  ),
                  child: Text(
                    labelBuilder(value),
                    style: GoogleFonts.inter(
                      color: selected ? Colors.white : kPrimaryText,
                      fontSize: 12.sp,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        MediaQuery.of(context).padding.bottom + 12.h,
      ),
      decoration: const BoxDecoration(
        color: kBackground,
        border: Border(top: BorderSide(color: kOutline)),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: _barButton('BACK', false, () => _goTo(_currentPage - 1)),
            ),
          if (_currentPage > 0) SizedBox(width: 10.w),
          Expanded(
            flex: 2,
            child: _barButton(
              _currentPage < 2
                  ? 'NEXT'
                  : (widget.isEdit ? 'UPDATE RECORD' : 'COMMIT TO LEDGER'),
              true,
              () {
                if (_currentPage < 2) {
                  _goTo(_currentPage + 1);
                } else {
                  _save();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _barButton(String text, bool primary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: primary ? kAccent : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: primary ? kAccent : kOutline),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.jetBrainsMono(
              color: primary ? Colors.white : kPrimaryText,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _EraInputFormatter extends TextInputFormatter {
  const _EraInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    var digitCount = 0;
    var sCount = 0;

    for (final char in newValue.text.toLowerCase().split('')) {
      if (char == 's' && sCount < 1) {
        buffer.write('s');
        sCount++;
      } else if (RegExp(r'[0-9]').hasMatch(char) && digitCount < 4) {
        buffer.write(char);
        digitCount++;
      }
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _SavingDialog extends StatelessWidget {
  const _SavingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kPanelBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.all(34.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 42.w,
              height: 42.w,
              child: const CircularProgressIndicator(
                color: kAccent,
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'CERTIFYING LEDGER',
              style: GoogleFonts.jetBrainsMono(
                color: kPrimaryText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Recording the harvest instrument to the grain exchange archive.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: kSecondaryText,
                fontSize: 13.sp,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
