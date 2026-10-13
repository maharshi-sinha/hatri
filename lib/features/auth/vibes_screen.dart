import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/models.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';

/// Onboarding step 04 — birthday + gender. Gen Z framed as a "vibe check".
class VibesScreen extends StatefulWidget {
  const VibesScreen({super.key});

  @override
  State<VibesScreen> createState() => _VibesScreenState();
}

class _VibesScreenState extends State<VibesScreen> {
  DateTime? _birthday;
  String? _gender;  // 'Male' | 'Female' | 'Other'
  String? _energy;  // 'Introvert' | 'Extrovert' | 'Ambivert'

  @override
  void initState() {
    super.initState();
    if (currentUser.birthday.isNotEmpty) {
      _birthday = DateTime.tryParse(currentUser.birthday);
    }
    if (currentUser.gender.isNotEmpty) {
      _gender = currentUser.gender;
    }
    if (currentUser.energy.isNotEmpty) {
      _energy = currentUser.energy;
    }
  }

  bool get _canContinue =>
      _birthday != null && _gender != null && _energy != null;

  Future<void> _onNext() async {
    if (!_canContinue) return;
    HapticFeedback.mediumImpact();
    currentUser.birthday = _birthday!.toIso8601String().split('T').first;
    currentUser.gender = _gender!;
    currentUser.energy = _energy!;
    if (!mounted) return;
    // Permissions are asked before OTP now, so vibes is the last profile step.
    context.go('/celebration');
  }

  Future<void> _pickBirthday() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BirthdayPickerSheet(
        initial: _birthday ?? DateTime(now.year - 20, 6, 15),
        earliest: DateTime(now.year - 90),
        latest: DateTime(now.year - 13, 12, 31),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _birthday = picked);
    }
  }

  void _pickGender(String g) {
    HapticFeedback.selectionClick();
    setState(() => _gender = g);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.r, 32.r, 24.r, 16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProgress(),
                    SizedBox(height: 24.r),
                    Text(
                      '04 / VIBES',
                      style: TextStyle(
                        color: AppColors.accentYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        letterSpacing: 2.0.sp,
                      ),
                    ),
                    SizedBox(height: 12.r),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 56.sp,
                            color: AppColors.primaryText,
                            height: 0.9,
                            letterSpacing: -1.0.sp,
                            fontFamily: 'ClashDisplay',
                            fontWeight: FontWeight.w800,
                          ),
                          children: [
                            const TextSpan(text: 'VIBE\n'),
                            TextSpan(
                              text: 'CHECK.',
                              style: TextStyle(color: AppColors.accentYellow),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.r),
                    Text(
                      "three quick deets. so we can match you to the right rooms.",
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        height: 1.4,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 32.r),
                    _buildBirthdaySection(),
                    SizedBox(height: 28.r),
                    _buildGenderSection(),
                    SizedBox(height: 28.r),
                    _buildEnergySection(),
                    SizedBox(height: 20.r),
                  ],
                ),
              ),
            ),
            _buildCta(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    Widget bar(Color c) => Expanded(child: Container(height: 3, color: c));
    return Row(
      children: [
        bar(AppColors.fuchsia),
        SizedBox(width: 4.r),
        bar(AppColors.lime),
        SizedBox(width: 4.r),
        bar(AppColors.accentBlue),
        SizedBox(width: 4.r),
        bar(AppColors.accentYellow),
      ],
    );
  }

  Widget _buildBirthdaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "WHEN'S THE BIG DAY?",
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w800,
            fontSize: 11.sp,
            letterSpacing: 1.6.sp,
            color: AppColors.muted,
          ),
        ),
        SizedBox(height: 10.r),
        GestureDetector(
          onTap: _pickBirthday,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 14.r),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(
                color: _birthday != null
                    ? AppColors.accentYellow.withValues(alpha: 0.6)
                    : AppColors.border,
                width: _birthday != null ? 1.6 : 1,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.cake_rounded, size: 22.r, color: AppColors.accentYellow),
                ),
                SizedBox(width: 14.r),
                Expanded(
                  child: _birthday != null
                      ? Text(
                          DateFormat('MMMM d, y').format(_birthday!),
                          style: TextStyle(
                            fontFamily: 'ClashDisplay',
                            fontWeight: FontWeight.w800,
                            fontSize: 20.sp,
                            height: 1.0,
                            letterSpacing: -0.4.sp,
                            color: AppColors.paper,
                          ),
                        )
                      : Text(
                          'pick a date',
                          style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: AppColors.muted,
                          ),
                        ),
                ),
                Icon(Icons.chevron_right_rounded, size: 22.r, color: AppColors.muted),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: _birthday == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.only(top: 10.r),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    child: _buildAstroChip(
                      _birthday!,
                      key: ValueKey('${_birthday!.year}-${_birthday!.month}-${_birthday!.day}'),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAstroChip(DateTime d, {Key? key}) {
    final sign = _zodiac(d.month, d.day);
    return Container(
      key: key,
      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: AppColors.accentYellow.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.accentYellow.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sign.symbol,
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
              color: AppColors.accentYellow,
            ),
          ),
          SizedBox(width: 6.r),
          Text(
            sign.name.toUpperCase(),
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 11.sp,
              letterSpacing: 1.4.sp,
              color: AppColors.accentYellow,
            ),
          ),
          SizedBox(width: 8.r),
          Container(
            width: 3.r,
            height: 3.r,
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.r),
          Flexible(
            child: Text(
              sign.tagline,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                color: AppColors.paper.withValues(alpha: 0.72),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOW DO YOU IDENTIFY?',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w800,
            fontSize: 11.sp,
            letterSpacing: 1.6.sp,
            color: AppColors.muted,
          ),
        ),
        SizedBox(height: 10.r),
        Row(
          children: [
            Expanded(child: _genderTile('Male', 'assets/icons/male.png', isSvg: false)),
            SizedBox(width: 10.r),
            Expanded(child: _genderTile('Female', 'assets/icons/female.png', isSvg: false)),
            SizedBox(width: 10.r),
            Expanded(child: _genderTile('Other', 'assets/icons/other.svg', isSvg: true)),
          ],
        ),
      ],
    );
  }

  Widget _genderTile(String value, String asset, {required bool isSvg}) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => _pickGender(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: 12.r),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentYellow.withValues(alpha: 0.14)
              : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.accentYellow : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 22.r,
              height: 22.r,
              child: isSvg
                  ? SvgPicture.asset(
                      asset,
                      colorFilter: ColorFilter.mode(
                        selected ? AppColors.accentYellow : AppColors.paper,
                        BlendMode.srcIn,
                      ),
                    )
                  : ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        selected ? AppColors.accentYellow : AppColors.paper,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(asset, fit: BoxFit.contain),
                    ),
            ),
            SizedBox(height: 6.r),
            Text(
              value.toUpperCase(),
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w800,
                fontSize: 10.sp,
                letterSpacing: 1.2.sp,
                color: selected ? AppColors.accentYellow : AppColors.paper,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergySection() {
    const options = [
      ('Introvert', '🌙', 'small rooms hit different'),
      ('Extrovert', '⚡', 'made for the main stage'),
      ('Ambivert',  '🌗', 'both sides know you'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR ENERGY',
          style: TextStyle(
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w800,
            fontSize: 11.sp,
            letterSpacing: 1.6.sp,
            color: AppColors.muted,
          ),
        ),
        SizedBox(height: 10.r),
        for (final o in options) ...[
          _energyTile(label: o.$1, emoji: o.$2, tagline: o.$3),
          SizedBox(height: 8.r),
        ],
      ],
    );
  }

  Widget _energyTile({
    required String label,
    required String emoji,
    required String tagline,
  }) {
    final selected = _energy == label;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _energy = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 12.r),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentYellow.withValues(alpha: 0.14)
              : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.accentYellow : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withValues(alpha: selected ? 0.22 : 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(emoji, style: TextStyle(fontSize: 20.sp)),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 16.sp,
                      height: 1.0,
                      letterSpacing: -0.2.sp,
                      color: selected ? AppColors.accentYellow : AppColors.paper,
                    ),
                  ),
                  SizedBox(height: 3.r),
                  Text(
                    tagline,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, size: 20.r, color: AppColors.accentYellow),
          ],
        ),
      ),
    );
  }

  _Sign _zodiac(int month, int day) {
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return const _Sign('Aries', '♈', 'reckless energy but make it main character');
    }
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return const _Sign('Taurus', '♉', 'won\'t be moving. thank you.');
    }
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return const _Sign('Gemini', '♊', 'plot twist personality. iconic.');
    }
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return const _Sign('Cancer', '♋', 'certified soft launch specialist');
    }
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return const _Sign('Leo', '♌', 'main character energy. don\'t fight it.');
    }
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return const _Sign('Virgo', '♍', 'runs the plan AND the group chat');
    }
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return const _Sign('Libra', '♎', 'professional yapper. spirit level.');
    }
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return const _Sign('Scorpio', '♏', 'mysterious for no reason');
    }
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return const _Sign('Sagittarius', '♐', 'chronically online, chronically outside');
    }
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return const _Sign('Capricorn', '♑', 'built different. locked in.');
    }
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return const _Sign('Aquarius', '♒', 'built the group chat, then left it');
    }
    return const _Sign('Pisces', '♓', 'delulu is the solulu, always');
  }

  Widget _buildCta() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.r, 8.r, 24.r, 16.r),
      child: GestureDetector(
        onTap: _canContinue ? _onNext : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: 56.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _canContinue ? AppColors.accentYellow : AppColors.card,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            "LET'S GO",
            style: TextStyle(
              fontFamily: 'GeneralSans',
              color: _canContinue ? AppColors.onNeon : AppColors.secondaryText,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0.sp,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom themed birthday picker — dark bottom sheet with 3 wheel columns
/// (Day / Month / Year), yellow-accented header, fuchsia SET button.
/// A zodiac sign — name + unicode symbol + one-line Gen Z tagline.
class _Sign {
  final String name;
  final String symbol;
  final String tagline;
  const _Sign(this.name, this.symbol, this.tagline);
}

class _BirthdayPickerSheet extends StatefulWidget {
  final DateTime initial;
  final DateTime earliest;
  final DateTime latest;
  const _BirthdayPickerSheet({
    required this.initial,
    required this.earliest,
    required this.latest,
  });

  @override
  State<_BirthdayPickerSheet> createState() => _BirthdayPickerSheetState();
}

class _BirthdayPickerSheetState extends State<_BirthdayPickerSheet> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.r).copyWith(bottom: 12.r),
        decoration: BoxDecoration(
          color: AppColors.ground,
          border: Border.all(color: AppColors.paper.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.r),
            Center(
              child: Container(
                width: 40.r,
                height: 4.r,
                decoration: BoxDecoration(
                  color: AppColors.paper.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 10.r),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.r),
              child: Row(
                children: [
                  Text(
                    '★ YOUR BIRTHDAY',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 11.sp,
                      letterSpacing: 1.6.sp,
                      color: AppColors.accentYellow,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close_rounded, size: 22.r, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.r),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.r),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('MMMM d, y').format(_selected),
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w800,
                    fontSize: 28.sp,
                    height: 1.0,
                    letterSpacing: -0.8.sp,
                    color: AppColors.paper,
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.r),
            SizedBox(height: 200.r, child: _buildWheels()),
            Padding(
              padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 16.r),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context, _selected);
                },
                child: Container(
                  height: 54.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.fuchsia,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Text(
                    'SET',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 14.sp,
                      letterSpacing: 1.6.sp,
                      color: AppColors.paper,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheels() {
    final years = List<int>.generate(
      widget.latest.year - widget.earliest.year + 1,
      (i) => widget.earliest.year + i,
    );
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    final daysInMonth = DateTime(_selected.year, _selected.month + 1, 0).day;
    final days = List<int>.generate(daysInMonth, (i) => i + 1);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _wheel(
            items: days.map((d) => d.toString().padLeft(2, '0')).toList(),
            selectedIndex: _selected.day - 1,
            onChanged: (i) => setState(() {
              _selected = DateTime(_selected.year, _selected.month, i + 1);
            }),
          ),
        ),
        Expanded(
          flex: 4,
          child: _wheel(
            items: months,
            selectedIndex: _selected.month - 1,
            onChanged: (i) {
              final maxDay = DateTime(_selected.year, i + 2, 0).day;
              final day = _selected.day > maxDay ? maxDay : _selected.day;
              setState(() {
                _selected = DateTime(_selected.year, i + 1, day);
              });
            },
          ),
        ),
        Expanded(
          flex: 4,
          child: _wheel(
            items: years.map((y) => y.toString()).toList(),
            selectedIndex: years.indexOf(_selected.year),
            onChanged: (i) {
              final year = years[i];
              final maxDay = DateTime(year, _selected.month + 1, 0).day;
              final day = _selected.day > maxDay ? maxDay : _selected.day;
              setState(() {
                _selected = DateTime(year, _selected.month, day);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _wheel({
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        brightness: Brightness.dark,
        textTheme: CupertinoTextThemeData(
          pickerTextStyle: TextStyle(
            fontFamily: 'ClashDisplay',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.paper,
          ),
        ),
      ),
      child: CupertinoPicker(
        itemExtent: 40,
        selectionOverlay: Container(
          decoration: BoxDecoration(
            color: AppColors.accentYellow.withValues(alpha: 0.12),
            border: Border(
              top: BorderSide(color: AppColors.accentYellow.withValues(alpha: 0.7)),
              bottom: BorderSide(color: AppColors.accentYellow.withValues(alpha: 0.7)),
            ),
          ),
        ),
        scrollController: FixedExtentScrollController(initialItem: selectedIndex),
        onSelectedItemChanged: (i) {
          HapticFeedback.selectionClick();
          onChanged(i);
        },
        children: items
            .map((s) => Center(
                  child: Text(
                    s,
                    style: const TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: AppColors.paper,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
