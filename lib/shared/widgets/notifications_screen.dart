import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/notifications/notifications_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/responsive/responsive.dart';
import 'burst_star.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _store = NotificationsStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStore);
    // Mark all read once the screen is open — inbox behaviour.
    WidgetsBinding.instance.addPostFrameCallback((_) => _store.markAllRead());
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_onStore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _store.items;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: items.isEmpty ? _buildEmpty() : _buildList(items),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 24.r),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/arrow-left.svg',
                  width: 20.r,
                  height: 20.r,
                  colorFilter: ColorFilter.mode(AppColors.secondaryText, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.r),
          Text(
            'NOTIFICATIONS',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 32.sp,
                  color: AppColors.primaryText,
                  letterSpacing: -0.5.sp,
                  height: 1.0,
                ),
          ),
          const Spacer(),
          if (_store.items.isNotEmpty)
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _store.clear();
              },
              child: Text(
                'CLEAR',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 11.sp,
                  letterSpacing: 1.2.sp,
                  color: AppColors.muted,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.muted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: EdgeInsets.only(bottom: 60.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 240.r,
            height: 240.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 240.r,
                  height: 240.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.lime.withValues(alpha: 0.2),
                        AppColors.lime.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/utility/empty.png',
                  width: 240.r,
                  height: 240.r,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          Text(
            'ALL CAUGHT UP.',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w800,
              fontSize: 32.sp,
              height: 1.0,
              letterSpacing: -0.6.sp,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 8.r),
          Text(
            'no new notifications. quiet week, quiet mind.',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<HatriNotification> items) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.r, 4.r, 16.r, 40.r),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.r),
      itemBuilder: (context, i) {
        final item = items[i];
        return _SwipeToDeleteRow(
          key: ValueKey(item.id),
          onDelete: () => _store.remove(item.id),
          child: _NotificationCard(item: item),
        );
      },
    );
  }
}

/// iOS-style slide-to-reveal delete button. Drag the row left to expose the
/// action, tap DELETE to remove, tap the card again to close.
class _SwipeToDeleteRow extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  const _SwipeToDeleteRow({super.key, required this.child, required this.onDelete});

  @override
  State<_SwipeToDeleteRow> createState() => _SwipeToDeleteRowState();
}

class _SwipeToDeleteRowState extends State<_SwipeToDeleteRow> with SingleTickerProviderStateMixin {
  static const _revealWidth = 88.0;
  double _offset = 0;

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _offset = (_offset + d.delta.dx).clamp(-_revealWidth * 1.2, 0.0);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    // Snap open if past the halfway threshold OR flung left; else snap shut.
    final velocity = d.velocity.pixelsPerSecond.dx;
    final shouldOpen = _offset < -_revealWidth / 2 || velocity < -500;
    setState(() => _offset = shouldOpen ? -_revealWidth : 0);
    if (shouldOpen) HapticFeedback.selectionClick();
  }

  void _close() {
    if (_offset == 0) return;
    setState(() => _offset = 0);
  }

  void _delete() {
    HapticFeedback.mediumImpact();
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Stack(
        children: [
          // Delete action revealed behind the card
          Positioned.fill(
            child: Container(
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: AppColors.fuchsia,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: GestureDetector(
                onTap: _delete,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: _revealWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline_rounded, color: AppColors.paper, size: 22.r),
                      SizedBox(height: 4.r),
                      Text(
                        'DELETE',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 10.sp,
                          letterSpacing: 1.4.sp,
                          color: AppColors.paper,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Card slides on top of the action
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(_offset, 0, 0),
            child: GestureDetector(
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              onTap: _offset == 0 ? null : _close,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final HatriNotification item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(item.kind);
    final glyph = _glyphFor(item.kind);
    return Container(
      padding: EdgeInsets.fromLTRB(12.r, 12.r, 12.r, 12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: item.unread ? accent.withValues(alpha: 0.55) : AppColors.border,
          width: item.unread ? 1.4 : 1.0,
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              border: Border.all(color: accent.withValues(alpha: 0.5), width: 1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: glyph,
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.unread) ...[
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.r),
                    ],
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          height: 1.15,
                          letterSpacing: -0.2.sp,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.r),
                    Text(
                      _relative(item.timestamp),
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 9.sp,
                        letterSpacing: 0.8.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.r),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    height: 1.35,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _accentFor(HatriNotificationKind kind) {
    switch (kind) {
      case HatriNotificationKind.ticketSuccess:
        return AppColors.lime;
      case HatriNotificationKind.ticketFailed:
        return AppColors.fuchsia;
      case HatriNotificationKind.eventReminder:
        return AppColors.fuchsia;
      case HatriNotificationKind.sceneUpdate:
        return AppColors.lime;
      case HatriNotificationKind.systemInfo:
        return AppColors.muted;
    }
  }

  Widget _glyphFor(HatriNotificationKind kind) {
    switch (kind) {
      case HatriNotificationKind.ticketSuccess:
        return const BurstStar(size: 20, color: AppColors.lime);
      case HatriNotificationKind.ticketFailed:
        return Icon(Icons.error_outline_rounded, size: 20.r, color: AppColors.fuchsia);
      case HatriNotificationKind.eventReminder:
        return Icon(Icons.event_rounded, size: 20.r, color: AppColors.fuchsia);
      case HatriNotificationKind.sceneUpdate:
        return Icon(Icons.groups_2_rounded, size: 20.r, color: AppColors.lime);
      case HatriNotificationKind.systemInfo:
        return Icon(Icons.info_outline_rounded, size: 20.r, color: AppColors.muted);
    }
  }

  String _relative(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays > 0) return '${d.inDays}D';
    if (d.inHours > 0) return '${d.inHours}H';
    if (d.inMinutes > 0) return '${d.inMinutes}M';
    return 'NOW';
  }
}
