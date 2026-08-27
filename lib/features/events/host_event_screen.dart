import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../core/di/injection_container.dart';
import '../../core/models/models.dart';
import '../../core/repositories/creator_repository.dart';
import '../../core/repositories/mock_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/components.dart';
import '../../shared/design/motifs.dart';
import '../../shared/widgets/event_card.dart';
import 'bloc/events_bloc.dart';
import 'bloc/events_event.dart';
import '../../core/responsive/responsive.dart';

/// Single-page fast form for posting an event.
/// Design goal: fillable in under a minute, live preview built-in.
class HostEventScreen extends StatefulWidget {
  const HostEventScreen({super.key});

  @override
  State<HostEventScreen> createState() => _HostEventScreenState();
}

class _HostEventScreenState extends State<HostEventScreen> {
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _mapsUrlController = TextEditingController();

  EventCategory _category = EventCategory.openMic;
  DateTime? _date;
  TimeOfDay? _time;
  bool _isFree = true;
  bool _isSafeVenue = false;
  final List<CreatorProfile> _lineup = [];
  String _coverUrl = _mockCovers.first;
  bool _showPreview = false;

  // Picsum seeded URLs — deterministic (same seed → same image), always 200.
  static const _mockCovers = [
    'https://picsum.photos/seed/hatri-neon/800/500',
    'https://picsum.photos/seed/hatri-fest/800/500',
    'https://picsum.photos/seed/hatri-market/800/500',
    'https://picsum.photos/seed/hatri-club/800/500',
    'https://picsum.photos/seed/hatri-cafe/800/500',
    'https://picsum.photos/seed/hatri-walk/800/500',
  ];

  static const _bottomPadForCta = 120.0;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    _venueController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _mapsUrlController.dispose();
    super.dispose();
  }

  bool get _canPost =>
      _titleController.text.trim().isNotEmpty &&
      _venueController.text.trim().isNotEmpty &&
      _date != null &&
      _time != null;

  Event _draftEvent() {
    final now = DateTime.now();
    final dt = _date ?? now.add(const Duration(days: 1));
    final timeLabel = _time == null
        ? '7:00 PM'
        : MaterialLocalizations.of(context).formatTimeOfDay(_time!, alwaysUse24HourFormat: false);
    return Event(
      id: 'new_${now.millisecondsSinceEpoch}',
      title: _titleController.text.trim().isEmpty ? 'Your event title' : _titleController.text.trim(),
      description: 'Just posted on Hatri.',
      coverUrl: _coverUrl,
      organizer: 'You',
      date: DateTime(dt.year, dt.month, dt.day),
      time: timeLabel,
      venue: _venueController.text.trim().isEmpty ? 'Somewhere in Raipur' : _venueController.text.trim(),
      category: _category,
      rsvpCount: 0,
      interestedCount: 0,
      colorHex: _category.colorHex,
      isFree: _isFree,
      isNewlyAdded: true,
      isSafeVenue: _isSafeVenue,
      mapsUrl: _mapsUrlController.text.trim().isEmpty
          ? null
          : _mapsUrlController.text.trim(),
      lineup: _lineup.map((c) => c.id).toList(),
    );
  }

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.fuchsia,
            onPrimary: AppColors.onNeon,
            surface: AppColors.graphite,
            onSurface: AppColors.paper,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    HapticFeedback.selectionClick();
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 19, minute: 0),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.fuchsia,
            onPrimary: AppColors.onNeon,
            surface: AppColors.graphite,
            onSurface: AppColors.paper,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _pickLineup() async {
    HapticFeedback.selectionClick();
    final repo = sl<CreatorRepository>();
    final creators = await repo.getCreators();
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.graphite,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Corners.xl)),
      ),
      builder: (ctx) => _LineupSheet(
        creators: creators,
        alreadySelected: _lineup.map((c) => c.id).toSet(),
        onToggle: (c) {
          setState(() {
            if (_lineup.any((x) => x.id == c.id)) {
              _lineup.removeWhere((x) => x.id == c.id);
            } else {
              _lineup.add(c);
            }
          });
        },
      ),
    );
  }

  void _post() async {
    HapticFeedback.mediumImpact();
    final event = _draftEvent();
    MockRepository.mockEvents.insert(0, event);
    context.read<EventsBloc>().add(LoadEvents());

    await showDialog(
      context: context,
      barrierColor: AppColors.ground.withValues(alpha: 0.9),
      builder: (_) => _PostedCelebration(event: event),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, _bottomPadForCta),
              child: _showPreview ? _buildPreview() : _buildForm(),
            ),
            // Fade edge above CTA so content dissolves in.
            Positioned(
              left: 0,
              right: 0,
              bottom: _bottomPadForCta - 24,
              child: IgnorePointer(
                child: Container(
                  height: 32.r,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), AppColors.ground],
                    ),
                  ),
                ),
              ),
            ),
            // Pinned CTA.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: AppColors.ground,
                padding: EdgeInsets.fromLTRB(Insets.lg, Insets.sm, Insets.lg, Insets.lg),
                child: PrimaryButton(
                  label: _canPost ? 'Post event' : 'Fill in the essentials',
                  icon: _canPost ? Icons.rocket_launch_rounded : null,
                  expand: true,
                  onPressed: _canPost ? _post : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(),
        SizedBox(height: Insets.lg),
        _sectionEyebrow('COVER'),
        SizedBox(height: 8.r),
        _coverPicker(),
        SizedBox(height: Insets.xl),

        _sectionEyebrow('TITLE'),
        SizedBox(height: 6.r),
        _underlineField(
          controller: _titleController,
          hint: 'e.g. Neon Nights: Open Mic',
          fontSize: 26.sp,
          fontFamily: 'ClashDisplay',
          weight: FontWeight.w700,
        ),
        SizedBox(height: Insets.xl),

        _sectionEyebrow('CATEGORY'),
        SizedBox(height: 8.r),
        _categoryChips(),
        SizedBox(height: Insets.xl),

        _sectionEyebrow('WHEN'),
        SizedBox(height: 8.r),
        Row(
          children: [
            Expanded(child: _pillPicker(
              icon: Icons.calendar_today_rounded,
              label: _date == null ? 'Pick date' : DateFormat('EEE, MMM d').format(_date!),
              onTap: _pickDate,
              active: _date != null,
            )),
            SizedBox(width: 10.r),
            Expanded(child: _pillPicker(
              icon: Icons.access_time_rounded,
              label: _time == null
                  ? 'Pick time'
                  : MaterialLocalizations.of(context).formatTimeOfDay(_time!, alwaysUse24HourFormat: false),
              onTap: _pickTime,
              active: _time != null,
            )),
          ],
        ),
        SizedBox(height: Insets.xl),

        _sectionEyebrow('WHERE'),
        SizedBox(height: 6.r),
        _underlineField(
          controller: _venueController,
          hint: 'e.g. Mocha Cafe, Civil Lines',
        ),
        SizedBox(height: 14.r),
        _sectionEyebrow('📍 GOOGLE MAPS LINK (OPTIONAL)'),
        SizedBox(height: 6.r),
        _underlineField(
          controller: _mapsUrlController,
          hint: 'Paste a maps.app.goo.gl link…',
          fontSize: 14.sp,
        ),
        SizedBox(height: Insets.xl),

        _sectionEyebrow("LINEUP · WHO'S PERFORMING"),
        SizedBox(height: 8.r),
        _lineupPicker(),
        SizedBox(height: Insets.xl),

        _sectionEyebrow('PRICE & VENUE'),
        SizedBox(height: 8.r),
        Row(
          children: [
            FilterChipX(
              label: 'Free',
              selected: _isFree,
              onTap: () => setState(() => _isFree = true),
              activeColor: AppColors.lime,
            ),
            SizedBox(width: 8.r),
            FilterChipX(
              label: 'Paid',
              selected: !_isFree,
              onTap: () => setState(() => _isFree = false),
              activeColor: AppColors.fuchsia,
            ),
            SizedBox(width: 12.r),
            FilterChipX(
              label: 'Safe venue',
              selected: _isSafeVenue,
              onTap: () => setState(() => _isSafeVenue = !_isSafeVenue),
              activeColor: AppColors.indigo,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(),
        SizedBox(height: Insets.lg),
        _sectionEyebrow('LIVE PREVIEW · HOW IT SHOWS UP'),
        SizedBox(height: 12.r),
        Center(
          child: SizedBox(
            width: 260.r,
            child: EventCard(
              event: _draftEvent(),
              onTap: () {},
              isHorizontal: false,
            ),
          ),
        ),
        SizedBox(height: Insets.lg),
        Text(
          'Tap the eye icon to keep editing.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12.sp),
        ),
      ],
    );
  }

  // ---------------- Sub-widgets ----------------

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _iconButton(Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
        SizedBox(width: 12.r),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NEW EVENT',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                  letterSpacing: 1.6.sp,
                  color: AppColors.lime,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'POST TO HATRI',
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontWeight: FontWeight.w700,
                  fontSize: 30.sp,
                  height: 0.95,
                  letterSpacing: -1.0.sp,
                  color: AppColors.paper,
                ),
              ),
            ],
          ),
        ),
        _iconButton(
          _showPreview ? Icons.edit_rounded : Icons.remove_red_eye_rounded,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _showPreview = !_showPreview);
          },
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.r,
        height: 42.r,
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: icon == Icons.arrow_back_rounded
            ? Center(
                child: SvgPicture.asset(
                  'assets/icons/arrow-left.svg',
                  width: 20.r,
                  height: 20.r,
                  colorFilter: const ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                ),
              )
            : Icon(icon, color: AppColors.paper, size: 20.r),
      ),
    );
  }

  Widget _sectionEyebrow(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'GeneralSans',
        fontWeight: FontWeight.w700,
        fontSize: 10.sp,
        letterSpacing: 1.6.sp,
        color: AppColors.muted,
      ),
    );
  }

  Widget _coverPicker() {
    return SizedBox(
      height: 100.r,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mockCovers.length,
        itemBuilder: (context, i) {
          final url = _mockCovers[i];
          final selected = url == _coverUrl;
          return Padding(
            padding: EdgeInsets.only(right: 10.r),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _coverUrl = url);
              },
              child: AnimatedContainer(
                duration: Motion.fast,
                width: 100.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Corners.md),
                  border: Border.all(
                    color: selected ? AppColors.lime : AppColors.border,
                    width: selected ? 3 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Corners.md),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    // Graceful fallback: colored block + subtle icon,
                    // properly clipped by the parent's rounded corners.
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceRaised,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.muted,
                        size: 22.r,
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(color: AppColors.surfaceRaised);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _underlineField({
    required TextEditingController controller,
    required String hint,
    double fontSize = 18,
    String fontFamily = 'GeneralSans',
    FontWeight weight = FontWeight.w500,
  }) {
    return TextField(
      controller: controller,
      cursorColor: AppColors.lime,
      style: TextStyle(
        color: AppColors.paper,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: weight,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.muted,
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: weight,
        ),
        filled: false,
        fillColor: Colors.transparent,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 10.r),
        border: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.lime, width: 2)),
      ),
    );
  }

  Widget _categoryChips() {
    return Wrap(
      spacing: 8.r,
      runSpacing: 8.r,
      children: EventCategory.values.where((c) => c != EventCategory.other).map((c) {
        return FilterChipX(
          label: c.label,
          selected: _category == c,
          onTap: () => setState(() => _category = c),
          activeColor: AppColors.fromHex(c.colorHex),
        );
      }).toList(),
    );
  }

  Widget _pillPicker({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 14.r),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(Corners.md),
          border: Border.all(color: active ? AppColors.lime : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.r, color: active ? AppColors.lime : AppColors.muted),
            SizedBox(width: 8.r),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? AppColors.paper : AppColors.muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lineupPicker() {
    return Wrap(
      spacing: 8.r,
      runSpacing: 8.r,
      children: [
        ..._lineup.map((c) => _LineupChip(
              creator: c,
              onRemove: () => setState(() => _lineup.removeWhere((x) => x.id == c.id)),
            )),
        GestureDetector(
          onTap: _pickLineup,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(Corners.pill),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 14.r, color: AppColors.lime),
                SizedBox(width: 6.r),
                Text(
                  'ADD PERFORMER',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    letterSpacing: 1.0.sp,
                    color: AppColors.lime,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------- Selected performer chip ----------------

class _LineupChip extends StatelessWidget {
  final CreatorProfile creator;
  final VoidCallback onRemove;

  const _LineupChip({required this.creator, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.r, 4.r, 10.r, 4.r),
      decoration: BoxDecoration(
        color: AppColors.fuchsia,
        borderRadius: BorderRadius.circular(Corners.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 11.r,
            backgroundColor: AppColors.onNeon,
            backgroundImage: NetworkImage(creator.avatarUrl),
          ),
          SizedBox(width: 6.r),
          Text(
            creator.name,
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
              color: AppColors.paper,
            ),
          ),
          SizedBox(width: 6.r),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14.r, color: AppColors.paper),
          ),
        ],
      ),
    );
  }
}

// ---------------- Bottom-sheet: pick performers ----------------

class _LineupSheet extends StatefulWidget {
  final List<CreatorProfile> creators;
  final Set<String> alreadySelected;
  final void Function(CreatorProfile) onToggle;

  const _LineupSheet({
    required this.creators,
    required this.alreadySelected,
    required this.onToggle,
  });

  @override
  State<_LineupSheet> createState() => _LineupSheetState();
}

class _LineupSheetState extends State<_LineupSheet> {
  late Set<String> _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = {...widget.alreadySelected};
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.r),
          Container(
            width: 42.r,
            height: 4.r,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 14.r),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Insets.lg),
            child: Row(
              children: [
                StickerLabel(
                  text: 'LINEUP',
                  background: AppColors.lime,
                  foreground: AppColors.onNeon,
                ),
                SizedBox(width: 8.r),
                Expanded(
                  child: Text(
                    "Who's performing?",
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w700,
                      fontSize: 20.sp,
                      color: AppColors.paper,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.r),
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: Insets.lg, vertical: 8.r),
              shrinkWrap: true,
              itemCount: widget.creators.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.r),
              itemBuilder: (context, i) {
                final c = widget.creators[i];
                final selected = _localSelected.contains(c.id);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (selected) {
                        _localSelected.remove(c.id);
                      } else {
                        _localSelected.add(c.id);
                      }
                    });
                    widget.onToggle(c);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(Corners.md),
                      border: Border.all(
                        color: selected ? AppColors.lime : AppColors.border,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22.r,
                          backgroundColor: AppColors.graphite,
                          backgroundImage: NetworkImage(c.avatarUrl),
                        ),
                        SizedBox(width: 12.r),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    c.name,
                                    style: TextStyle(
                                      fontFamily: 'GeneralSans',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                      color: AppColors.paper,
                                    ),
                                  ),
                                  if (c.isVerified) ...[
                                    SizedBox(width: 4.r),
                                    VerifiedBadge(size: 12.r),
                                  ],
                                ],
                              ),
                              Text(
                                '${c.category} · ${c.handle}',
                                style: TextStyle(
                                  fontFamily: 'GeneralSans',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          selected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                          color: selected ? AppColors.lime : AppColors.muted,
                          size: 22.r,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(Insets.lg, 8.r, Insets.lg, 16.r),
            child: PrimaryButton(
              label: 'Done',
              expand: true,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Post celebration ----------------

class _PostedCelebration extends StatelessWidget {
  final Event event;
  const _PostedCelebration({required this.event});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.all(24.r),
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.lime,
          borderRadius: BorderRadius.circular(Corners.xl),
          border: Border.all(color: AppColors.onNeon, width: 1.6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Starburst(size: 64.r, color: AppColors.fuchsia, points: 8),
            SizedBox(height: 16.r),
            Text(
              'YOU JUST\nPOSTED TO\nHATRI 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w700,
                fontSize: 32.sp,
                height: 0.95,
                letterSpacing: -0.6.sp,
                color: AppColors.onNeon,
              ),
            ),
            SizedBox(height: 12.r),
            Text(
              event.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                letterSpacing: 1.0.sp,
                color: AppColors.onNeon,
              ),
            ),
            SizedBox(height: 20.r),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onNeon,
                  foregroundColor: AppColors.lime,
                  padding: EdgeInsets.symmetric(vertical: 14.r),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Corners.md),
                  ),
                ),
                child: Text(
                  'SEE IT IN THE FEED',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
