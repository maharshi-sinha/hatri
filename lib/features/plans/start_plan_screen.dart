import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/models.dart';
import '../../core/repositories/mock_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/design/components.dart';
import '../../shared/design/motifs.dart';
import '../../core/responsive/responsive.dart';

/// Start-a-plan flow: pick friends, add a note, send invites.
/// Persists to AppPlans.mine in-memory for the session.
class StartPlanScreen extends StatefulWidget {
  final Event event;
  const StartPlanScreen({super.key, required this.event});

  @override
  State<StartPlanScreen> createState() => _StartPlanScreenState();
}

class _StartPlanScreenState extends State<StartPlanScreen> {
  final _noteController = TextEditingController();
  final Set<String> _selected = {};

  // Mock friends pool — same 8 attendees used across the app.
  static const List<Attendee> _friendsPool = [
    Attendee(id: 'u1', name: 'Priya', avatarUrl: 'https://i.pravatar.cc/100?img=47'),
    Attendee(id: 'u2', name: 'Rohan', avatarUrl: 'https://i.pravatar.cc/100?img=12'),
    Attendee(id: 'u3', name: 'Ananya', avatarUrl: 'https://i.pravatar.cc/100?img=32'),
    Attendee(id: 'u4', name: 'Kabir', avatarUrl: 'https://i.pravatar.cc/100?img=15'),
    Attendee(id: 'u5', name: 'Ishita', avatarUrl: 'https://i.pravatar.cc/100?img=45'),
    Attendee(id: 'u6', name: 'Arjun', avatarUrl: 'https://i.pravatar.cc/100?img=8'),
    Attendee(id: 'u7', name: 'Meera', avatarUrl: 'https://i.pravatar.cc/100?img=41'),
    Attendee(id: 'u8', name: 'Dev', avatarUrl: 'https://i.pravatar.cc/100?img=13'),
  ];

  @override
  void initState() {
    super.initState();
    _noteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Event get event => widget.event;

  void _toggle(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _send() async {
    HapticFeedback.mediumImpact();
    final plan = Plan(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      eventId: event.id,
      hostId: currentUser.name.isEmpty ? 'You' : currentUser.name,
      invitedIds: _selected.toList(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );
    AppPlans.mine.insert(0, plan);
    await showDialog(
      context: context,
      barrierColor: AppColors.ground.withValues(alpha: 0.9),
      builder: (_) => _PlanCreatedDialog(event: event, plan: plan, friends: _selectedFriends()),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  List<Attendee> _selectedFriends() =>
      _friendsPool.where((a) => _selected.contains(a.id)).toList();

  @override
  Widget build(BuildContext context) {
    final canSend = _selected.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, 128.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  SizedBox(height: Insets.lg),
                  _buildEventCard(),
                  SizedBox(height: Insets.xl),
                  Row(
                    children: [
                      const StickerLabel(
                        text: 'CREW',
                        background: AppColors.lime,
                        foreground: AppColors.onNeon,
                      ),
                      SizedBox(width: 8.r),
                      Expanded(
                        child: Text(
                          _selected.isEmpty
                              ? 'Who are you bringing?'
                              : '${_selected.length} friend${_selected.length == 1 ? '' : 's'} invited',
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
                  SizedBox(height: 12.r),
                  _buildFriendGrid(),
                  SizedBox(height: Insets.xl),
                  Text(
                    'ADD A MESSAGE (OPTIONAL)',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                      letterSpacing: 1.6.sp,
                      color: AppColors.muted,
                    ),
                  ),
                  SizedBox(height: 6.r),
                  TextField(
                    controller: _noteController,
                    cursorColor: AppColors.lime,
                    maxLines: 3,
                    minLines: 1,
                    style: TextStyle(
                      color: AppColors.paper,
                      fontSize: 15.sp,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Say something to your crew…",
                      hintStyle: TextStyle(
                        color: AppColors.muted,
                        fontSize: 15.sp,
                        fontFamily: 'GeneralSans',
                      ),
                      filled: false,
                      fillColor: Colors.transparent,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.r),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.lime, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Fade + pinned CTA
            Positioned(
              left: 0,
              right: 0,
              bottom: 104.r,
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: AppColors.ground,
                padding: EdgeInsets.fromLTRB(Insets.lg, Insets.sm, Insets.lg, Insets.lg),
                child: PrimaryButton(
                  label: canSend
                      ? 'Send invites (${_selected.length})'
                      : 'Pick at least one friend',
                  icon: canSend ? Icons.send_rounded : null,
                  expand: true,
                  onPressed: canSend ? _send : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(Corners.md),
            ),
            child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/arrow-left.svg',
                          width: 20.r,
                          height: 20.r,
                          colorFilter: ColorFilter.mode(AppColors.paper, BlendMode.srcIn),
                        ),
                      ),
          ),
        ),
        SizedBox(width: 12.r),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'START A PLAN',
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
                'BRING YOUR CREW',
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontWeight: FontWeight.w700,
                  fontSize: 28.sp,
                  height: 0.95,
                  letterSpacing: -0.8.sp,
                  color: AppColors.paper,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard() {
    final accent = AppColors.fromHex(event.colorHex);
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Corners.sm),
            child: Image.network(
              event.coverUrl,
              width: 72.r,
              height: 72.r,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 72.r, height: 72.r, color: accent),
            ),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryTag(label: event.category.label, color: accent),
                SizedBox(height: 6.r),
                Text(
                  event.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    letterSpacing: -0.2.sp,
                    color: AppColors.paper,
                  ),
                ),
                Text(
                  '${DateFormat('EEE, MMM d').format(event.date).toUpperCase()} · ${event.time}',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 10.sp,
                    letterSpacing: 0.6.sp,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendGrid() {
    return Wrap(
      spacing: 12.r,
      runSpacing: 14.r,
      children: _friendsPool.map((f) {
        final selected = _selected.contains(f.id);
        return GestureDetector(
          onTap: () => _toggle(f.id),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 72.r,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: Motion.fast,
                  padding: EdgeInsets.all(selected ? 3 : 2),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.lime : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28.r,
                        backgroundColor: AppColors.surfaceRaised,
                        backgroundImage: NetworkImage(f.avatarUrl),
                      ),
                      if (selected)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 20.r,
                            height: 20.r,
                            decoration: const BoxDecoration(
                              color: AppColors.lime,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.check, size: 12.r, color: AppColors.onNeon),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 6.r),
                Text(
                  f.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    color: selected ? AppColors.paper : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// After sending: shareable plan card.
class _PlanCreatedDialog extends StatelessWidget {
  final Event event;
  final Plan plan;
  final List<Attendee> friends;

  const _PlanCreatedDialog({
    required this.event,
    required this.plan,
    required this.friends,
  });

  Future<void> _share(BuildContext context) async {
    final dateLabel = DateFormat('EEE, MMM d').format(event.date);
    final names = friends.take(3).map((f) => f.name).join(', ');
    final extra = friends.length > 3 ? ' + ${friends.length - 3} more' : '';
    final crew = friends.isEmpty ? '' : ' Bringing $names$extra.';
    final note = plan.note != null ? '\n\n"${plan.note}"' : '';
    await Share.share(
      "I'm going to ${event.title} 🎟️\n$dateLabel · ${event.time} · ${event.venue}$crew\n\nWho's in?$note\n\nvia Hatri",
      subject: event.title,
    );
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.fromHex(event.colorHex);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.all(20.r),
      child: Container(
        padding: EdgeInsets.fromLTRB(22.r, 22.r, 22.r, 20.r),
        decoration: BoxDecoration(
          color: AppColors.graphite,
          borderRadius: BorderRadius.circular(Corners.xl),
          border: Border.all(color: AppColors.border, width: 1.4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Starburst(size: 44.r, color: AppColors.lime, points: 8),
            ),
            SizedBox(height: 12.r),
            Text(
              'PLAN LOCKED IN 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w700,
                fontSize: 24.sp,
                letterSpacing: -0.3.sp,
                color: AppColors.paper,
              ),
            ),
            SizedBox(height: 4.r),
            Text(
              "Share it with your crew so they know it's real.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 12.sp),
            ),
            SizedBox(height: 18.r),
            // Plan card
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                border: Border.all(color: accent.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(Corners.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryTag(label: event.category.label, color: accent),
                  SizedBox(height: 8.r),
                  Text(
                    event.title.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w700,
                      fontSize: 20.sp,
                      height: 0.98,
                      letterSpacing: -0.3.sp,
                      color: AppColors.paper,
                    ),
                  ),
                  SizedBox(height: 6.r),
                  Text(
                    '${DateFormat('EEE, MMM d').format(event.date).toUpperCase()} · ${event.time}',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                      letterSpacing: 0.6.sp,
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    event.venue,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      color: AppColors.muted,
                    ),
                  ),
                  if (friends.isNotEmpty) ...[
                    SizedBox(height: 12.r),
                    Text(
                      'CREW',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 9.sp,
                        letterSpacing: 1.4.sp,
                        color: AppColors.muted,
                      ),
                    ),
                    SizedBox(height: 6.r),
                    SizedBox(
                      height: 32.r,
                      child: Stack(
                        children: [
                          for (int i = 0; i < friends.take(6).length; i++)
                            Positioned(
                              left: (i * 22).toDouble(),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.surfaceRaised, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 13.r,
                                  backgroundColor: AppColors.graphite,
                                  backgroundImage: NetworkImage(friends[i].avatarUrl),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (plan.note != null) ...[
                    SizedBox(height: 12.r),
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppColors.graphite,
                        borderRadius: BorderRadius.circular(Corners.sm),
                      ),
                      child: Text(
                        '"${plan.note}"',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontStyle: FontStyle.italic,
                          fontSize: 13.sp,
                          color: AppColors.paper,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 16.r),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('DONE'),
                  ),
                ),
                SizedBox(width: 10.r),
                Expanded(
                  child: PrimaryButton(
                    label: 'Share',
                    svgIcon: 'assets/icons/Upload.svg',
                    expand: true,
                    onPressed: () => _share(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
