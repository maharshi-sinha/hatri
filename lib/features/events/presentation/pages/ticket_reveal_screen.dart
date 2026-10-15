import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../backend/models/ticket_models.dart';
import '../../../../core/notifications/notifications_store.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../../../../core/tickets/tickets_store.dart';
import '../../../../shared/design/motifs.dart';
import 'ticket_invoice.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import '../../../../core/responsive/responsive.dart';

/// Renders the printing ticket. Optional [tier] shows tier name + price on the
/// ticket when the event is paid.
class TicketRevealScreen extends StatefulWidget {
  final Event event;
  final TicketTier? tier;
  final int quantity;

  /// Real backend-issued ticket. When present, [ApiTicket.qrCode] powers
  /// the QR — that's the value the door scanner will read. When null the
  /// screen falls back to legacy per-event id (dev only).
  final ApiTicket? ticket;

  /// When true, jumps straight to the finished-ticket state (no printer
  /// animation, no sound, no confetti). Used when re-viewing a saved ticket
  /// from My Tickets so the printer chug doesn't replay every time.
  final bool skipAnimation;

  const TicketRevealScreen({
    super.key,
    required this.event,
    this.tier,
    this.quantity = 1,
    this.ticket,
    this.skipAnimation = false,
  });

  @override
  State<TicketRevealScreen> createState() => _TicketRevealScreenState();
}

class _TicketRevealScreenState extends State<TicketRevealScreen> with TickerProviderStateMixin {
  // Ticket geometry is derived from one width so the box, the clip path and the
  // confetti origin can never drift apart. The design is 320x500 with the
  // perforation at y=310; everything below preserves those ratios.
  static const double _ticketAspect = 500 / 320;
  static const double _separatorRatio = 310 / 500;

  /// Scaled, but never wider than the viewport allows.
  double get _ticketWidth =>
      math.min(320.r, MediaQuery.sizeOf(context).width - Insets.xl * 2);
  double get _ticketHeight => _ticketWidth * _ticketAspect;
  double get _ticketSeparatorY => _ticketHeight * _separatorRatio;

  late AnimationController _controller;
  late AnimationController _idleController;
  late AnimationController _confettiController;
  late AudioPlayer _audioPlayer;
  bool _isButtonDown = false;
  bool _isPrinting = false;
  bool _isFinished = false;
  final GlobalKey _ticketKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3300), // Total sequence duration
    );
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _confettiController = AnimationController(vsync: this);
    _audioPlayer = AudioPlayer();
    // Re-viewing a saved ticket: jump straight to the finished state.
    if (widget.skipAnimation) {
      _controller.value = 1.0;
      _isFinished = true;
    }
  }

  void _startPrinting() async {
    if (_isPrinting || _isFinished) return;
    setState(() => _isPrinting = true);
    
    // Haptic mechanical chugging
    bool chugging = true;
    void chug() async {
      while (chugging && mounted) {
        HapticFeedback.selectionClick();
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
    chug();
    
    _audioPlayer.play(AssetSource('audio/printer_sound.mp3'));

    // Phase 1: Printing (Slides out of the machine)
    await _controller.animateTo(0.6, duration: const Duration(milliseconds: 2500), curve: Curves.easeOutSine);
    chugging = false;
    
    _audioPlayer.stop();
    if (!mounted) return;
    // Detach / Snip sound
    HapticFeedback.heavyImpact();
    
    // Phase 2: Detach (Machine falls away, ticket centers)
    await _controller.animateTo(1.0, duration: const Duration(milliseconds: 800), curve: Curves.easeOutExpo);
    
    if (mounted) {
      setState(() {
        _isPrinting = false;
        _isFinished = true;
      });
      _confettiController.forward(from: 0);
      _pushSuccessNotification();
    }
  }

  void _pushSuccessNotification() {
    final e = widget.event;
    final t = widget.tier;
    final tierLine = t != null
        ? ' · ${t.name} × ${widget.quantity} · ₹${t.priceRupees * widget.quantity}'
        : (widget.quantity > 1 ? ' · × ${widget.quantity}' : '');
    final now = DateTime.now();
    NotificationsStore.instance.push(
      HatriNotification(
        id: 'ticket_${e.id}_${now.microsecondsSinceEpoch}',
        kind: HatriNotificationKind.ticketSuccess,
        title: 'Ticket ready. see you at ${e.title}.',
        subtitle:
            '${DateFormat('EEE, MMM d').format(e.date)} · ${e.time} · ${e.venue}$tierLine',
        timestamp: now,
        deepLinkEventId: e.id,
      ),
    );
    // Persist the ticket to the user's wallet.
    TicketsStore.instance.push(
      SavedTicket(
        id: 'st_${e.id}_${now.microsecondsSinceEpoch}',
        ref: 'HTR-${e.id.toUpperCase()}-${now.millisecondsSinceEpoch % 100000}',
        event: e,
        tier: t,
        quantity: widget.quantity,
        purchasedAt: now,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _idleController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// A round icon button that matches the share button's visual weight. Used
  /// for the DOWNLOAD INVOICE + SHARE actions in the finished-ticket row.
  Widget _circleAction({
    IconData? icon,
    String? iconAsset,
    required VoidCallback onTap,
    Color? accent,
    String? tooltip,
  }) {
    Widget child;
    if (iconAsset != null) {
      child = SvgPicture.asset(
        iconAsset,
        width: 22.r,
        height: 22.r,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    } else {
      child = Icon(icon, size: 22.r, color: Colors.white);
    }
    final button = InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(100.r),
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: (accent ?? Colors.white).withValues(alpha: 0.15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }

  Future<void> _downloadInvoice() async {
    final tier = widget.tier;
    if (tier == null) return;
    HapticFeedback.selectionClick();
    final invoice = HatriInvoice(
      event: widget.event,
      tier: tier,
      quantity: widget.quantity,
      ticketRef: 'HTR-${widget.event.id.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch % 100000}',
    );
    try {
      await invoice.share();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open invoice: $e')),
      );
    }
  }

  Future<void> _shareTicket() async {
    try {
      RenderRepaintBoundary boundary = _ticketKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/hatri_ticket_${widget.event.id}.png');
        await file.writeAsBytes(pngBytes);
        
        await Share.shareXFiles(
          [XFile(file.path)], 
          text: 'I just claimed my ticket for ${widget.event.title}! 🎉\n\nGet yours on the Hatri app: https://hatri.app/download',
        );
      }
    } catch (e) {
      debugPrint('Error sharing ticket: $e');
    }
  }

  Widget _buildStaticTicket(Color eventColor) {
    return SizedBox(
      width: _ticketWidth,
      height: _ticketHeight,
      child: ClipPath(
        clipper: TicketClipper(
          holeRadius: 12.r,
          cornerRadius: 16.r,
          separatorY: _ticketSeparatorY,
        ),
        child: Container(
          color: AppColors.surface,
          child: Column(
            children: [
              Container(
                height: _ticketSeparatorY,
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                          decoration: BoxDecoration(
                            color: eventColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Text(
                            widget.event.category.label.toUpperCase(),
                            style: TextStyle(color: eventColor, fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.0.sp),
                          ),
                        ),
                        const Icon(Icons.confirmation_num, color: AppColors.secondaryText),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      widget.event.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 24.r),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.secondaryText, size: 18.r),
                        SizedBox(width: 12.r),
                        Text(DateFormat('MMM d, yyyy').format(widget.event.date), style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    SizedBox(height: 12.r),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: AppColors.secondaryText, size: 18.r),
                        SizedBox(width: 12.r),
                        Text(widget.event.time, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    SizedBox(height: 12.r),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.secondaryText, size: 18.r),
                        SizedBox(width: 12.r),
                        Expanded(child: Text(widget.event.venue, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600))),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.tier != null
                                    ? '${widget.tier!.name} · ₹${widget.tier!.priceRupees * widget.quantity}'
                                    : widget.event.priceLabel.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: eventColor, fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 1.0.sp),
                              ),
                            ),
                            SizedBox(width: 8.r),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 2.r),
                              decoration: BoxDecoration(
                                color: eventColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(Corners.pill),
                              ),
                              child: Text(
                                widget.quantity == 1 ? '× 1' : '× ${widget.quantity}',
                                style: TextStyle(
                                  color: eventColor,
                                  fontFamily: 'ClashDisplay',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.sp,
                                  letterSpacing: 0.4.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.r),
                        Text(
                          '#HTR-89241',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                            letterSpacing: 1.0.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 2,
                width: double.infinity,
                child: CustomPaint(painter: DashedLinePainter()),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 12.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            QrImageView(
                              // Non-Hatri scanners land on the event's
                              // hatri.online page (download-the-app CTA
                              // included). Hatri users auto-open via
                              // Universal Links.
                              data: widget.ticket?.qrShareUrl ??
                                  'https://hatri.online/e/${widget.event.id}',
                              version: QrVersions.auto,
                              size: 120.r,
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.white,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Colors.black,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Colors.black,
                              ),
                              errorCorrectionLevel: QrErrorCorrectLevel.H,
                            ),
                            // Hatri app logo in the center. Sits on a small
                            // paper patch so the QR modules under it are
                            // hidden. Level H error correction keeps the code
                            // scannable.
                            Container(
                              width: 34.r,
                              height: 34.r,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Image.asset(
                                'assets/icons/app_icon.png',
                                width: 28.r,
                                height: 28.r,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrinterMachine() {
    // Light-theme printer housing — an off-white "device" sitting on the dark
    // app ground. When the dark ticket prints out of the slit it contrasts
    // hard against the paper body so there's no colour clash.
    const printerBody = Color(0xFFF5F3ED);       // warm off-white plastic
    const printerBorder = Color(0xFFDCDACD);     // subtle bezel line
    const printerInk = Color(0xFF1C1C1C);        // dark headings on paper
    const printerMuted = Color(0xFF87847A);      // muted labels
    const printerDivider = Color(0xFFE0DED2);
    const printerRaised = Color(0xFFECE9DE);     // preview card fill
    final width = math.min(360.r, MediaQuery.sizeOf(context).width - Insets.md * 2);
    return Container(
      width: width,
      height: width * (560 / 360),
      padding: EdgeInsets.fromLTRB(20.r, 18.r, 20.r, 24.r),
      decoration: BoxDecoration(
        color: printerBody,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: printerBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 44.r,
            offset: Offset(0, 22.r),
          ),
          // Inner specular highlight sim (a hair of white on top)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.6),
            blurRadius: 1.r,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top strip — LED + READY on the left, HATRI PRINTER wordmark right.
          Positioned(
            top: 0, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _idleController,
                      builder: (context, child) {
                        double opacity;
                        Color ledColor;
                        if (_isFinished) {
                          opacity = 1.0;
                          ledColor = const Color(0xFF34C759);
                        } else if (_isPrinting) {
                          opacity = (math.sin(_idleController.value * math.pi * 8) + 1.0) / 2.0;
                          ledColor = const Color(0xFFFF9500);
                        } else {
                          final t = (math.sin(_idleController.value * math.pi * 2) + 1.0) / 2.0;
                          opacity = 0.35 + (t * 0.65);
                          ledColor = const Color(0xFF34C759);
                        }
                        return Container(
                          width: 10.r, height: 10.r,
                          decoration: BoxDecoration(
                            color: ledColor.withValues(alpha: opacity),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: ledColor.withValues(alpha: opacity * 0.7),
                                blurRadius: 10.r,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 8.r),
                    Text(
                      _isFinished ? 'DONE' : _isPrinting ? 'PRINTING' : 'READY',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 10.sp,
                        letterSpacing: 1.6.sp,
                        color: printerMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  'HATRI PRINTER',
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontWeight: FontWeight.w800,
                    fontSize: 13.sp,
                    letterSpacing: 0.6.sp,
                    color: printerInk,
                  ),
                ),
              ],
            ),
          ),
          // Serial line
          Positioned(
            top: 22.r, right: 0,
            child: Text(
              'HAT-2026 · v1.0',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                fontSize: 9.sp,
                letterSpacing: 0.6.sp,
                color: printerMuted,
              ),
            ),
          ),
          // Divider under the header strip
          Positioned(
            top: 46.r, left: 0, right: 0,
            child: Container(height: 1, color: printerDivider),
          ),
          // The Dispenser Slit — dark inset, reads as a real thermal exit.
          Positioned(
            top: 72.r, left: 8.r, right: 8.r,
            child: Container(
              height: 10.r,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(5.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.7),
                    blurRadius: 1.r,
                    offset: Offset(0, 1.r),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.85),
                    blurRadius: 3.r,
                    offset: Offset(0, 2.r),
                  ),
                ],
              ),
            ),
          ),
          // Ticket preview strip — small mono card showing what's about to print.
          Positioned(
            top: 108.r, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 12.r),
              decoration: BoxDecoration(
                color: printerRaised,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: printerBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEXT UP',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 9.sp,
                      letterSpacing: 1.6.sp,
                      color: printerMuted,
                    ),
                  ),
                  SizedBox(height: 6.r),
                  Text(
                    widget.event.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w800,
                      fontSize: 15.sp,
                      letterSpacing: -0.2.sp,
                      color: printerInk,
                    ),
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    '${DateFormat('EEE, MMM d').format(widget.event.date).toUpperCase()} · ${widget.event.time}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                      letterSpacing: 0.8.sp,
                      color: printerMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Massive Tactile Button
          Positioned(
            bottom: 24.r, left: 0, right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTapDown: (_) => setState(() => _isButtonDown = true),
                  onTapUp: (_) {
                    setState(() => _isButtonDown = false);
                    _startPrinting();
                  },
                  onTapCancel: () => setState(() => _isButtonDown = false),
                  child: AnimatedScale(
                    scale: _isButtonDown || (_isPrinting && !_isFinished) ? 0.9 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: AnimatedOpacity(
                      opacity: _isFinished ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Idle pulsing ring (expands + fades)
                          if (!_isPrinting && !_isFinished)
                            AnimatedBuilder(
                              animation: _idleController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (_idleController.value * 0.45),
                                  child: Opacity(
                                    opacity: 1.0 - _idleController.value,
                                    child: Container(
                                      width: 130.r, height: 130.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.fuchsia, width: 3.r),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          // Soft halo behind button
                          Container(
                            width: 150.r, height: 150.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.fuchsia.withValues(alpha: 0.35),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // The Solid Button
                          Container(
                            width: 128.r, height: 128.r,
                            decoration: BoxDecoration(
                              color: AppColors.fuchsia,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.paper, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.fuchsia.withValues(alpha: 0.45),
                                  blurRadius: _isButtonDown ? 12 : 24,
                                  offset: Offset(0, _isButtonDown ? 4 : 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(Icons.touch_app_rounded, color: AppColors.paper, size: 52.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.r),
                AnimatedOpacity(
                  opacity: _isFinished || _isPrinting ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      Text(
                        'TAP TO CLAIM',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                          letterSpacing: 2.0.sp,
                          color: AppColors.paper,
                        ),
                      ),
                      SizedBox(height: 4.r),
                      Text(
                        widget.quantity == 1
                            ? '1 TICKET WAITING'
                            : '${widget.quantity} TICKETS WAITING',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp,
                          letterSpacing: 1.6.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color eventColor = AppColors.fromHex(widget.event.colorHex);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            
            // Map the 0.0 -> 1.0 master controller to the two distinct phases
            // Phase 1 (0.0 to 0.6): Printing
            double printProgress = (_controller.value / 0.6).clamp(0.0, 1.0);
            // Phase 2 (0.6 to 1.0): Detaching
            double detachProgress = ((_controller.value - 0.6) / 0.4).clamp(0.0, 1.0);

            // Printer Kinematics
            double printerGlobalY = Curves.easeInExpo.transform(detachProgress) * 300.0;
            double printerOpacity = 1.0 - detachProgress;

            // Ticket Kinematics
            // Starts hidden above the ClipRect (-500), slides down to 0 during printing
            double ticketLocalY = -500.0 * (1.0 - printProgress);
            // Ticket rests at +82 global Y (perfectly aligned with the printer slit)
            // Moves to 0 (absolute center) during detach
            double ticketGlobalY = 82.0 * (1.0 - Curves.easeOutExpo.transform(detachProgress));
            double ticketScale = 0.95 + (0.05 * Curves.easeOutExpo.transform(detachProgress));

            return Stack(
              alignment: Alignment.center,
              children: [
                // Halftone industrial wash — faded further as event glow rises.
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.08 * (1.0 - detachProgress),
                    child: HalftoneBackground(
                      dotColor: AppColors.paper,
                      spacing: 16.r,
                      dotSize: 2.4,
                    ),
                  ),
                ),
                // Corner starbursts for brand consistency
                if (!_isFinished) ...[
                  Positioned(
                    top: 90.r, right: 28.r,
                    child: Starburst(size: 30.r, color: AppColors.fuchsia.withValues(alpha: 0.4), points: 8),
                  ),
                  Positioned(
                    bottom: 140.r, left: 30.r,
                    child: Starburst(size: 22.r, color: AppColors.lime.withValues(alpha: 0.35), points: 6),
                  ),
                ],
                // Ambient Background Glow (Grows when detached)
                Positioned.fill(
                  child: Opacity(
                    opacity: detachProgress * 0.85,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [eventColor.withValues(alpha: 0.5), AppColors.background],
                          radius: 1.2.r,
                        ),
                      ),
                    ),
                  ),
                ),

                // 1. The Printer Machine
                Transform.translate(
                  offset: Offset(0, printerGlobalY),
                  child: Opacity(
                    opacity: printerOpacity,
                    child: _buildPrinterMachine(),
                  ),
                ),

                // 2. The Ticket Dispenser
                Transform.translate(
                  offset: Offset(0, ticketGlobalY),
                  child: Transform.scale(
                    scale: ticketScale,
                    child: ClipRect(
                      // Matches the ticket box exactly, so its top edge rests
                      // on the printer slit at every screen size.
                      child: SizedBox(
                        width: _ticketWidth,
                        height: _ticketHeight,
                        child: Stack(
                          children: [
                            // The moving ticket
                            Positioned(
                              top: ticketLocalY,
                              left: 0, right: 0,
                              child: RepaintBoundary(
                                key: _ticketKey,
                                child: _buildStaticTicket(eventColor),
                              ),
                            ),
                            // Slit overhang shadow (simulates the plastic lip casting a shadow on the paper)
                            if (printProgress > 0 && detachProgress == 0)
                              Positioned(
                                top: 0, left: 0, right: 0,
                                child: Container(
                                  height: 12.r,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Confetti Burst (Placed behind the CTA)
                Positioned(
                  // Exactly at the ticket's dotted line, which sits below the
                  // vertical centre by however far the perforation is off-centre.
                  top: (MediaQuery.sizeOf(context).height / 2) +
                      (_ticketHeight * (_separatorRatio - 0.5)),
                  bottom: 90.r, // Originates exactly at the center of the action buttons
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Lottie.asset(
                      'assets/lottie/Confetti.json',
                      controller: _confettiController,
                      onLoaded: (composition) {
                        _confettiController.duration = composition.duration;
                      },
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Action Buttons (Download & Share)
                if (detachProgress > 0)
                  Positioned(
                    bottom: 60.r,
                    left: 24.r, right: 24.r,
                    child: Transform.translate(
                      offset: Offset(0, 40 * (1.0 - Curves.easeOutCubic.transform(detachProgress))),
                      child: Opacity(
                        opacity: Curves.easeIn.transform(detachProgress),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket saved to gallery!')));
                                },
                                icon: SvgPicture.asset('assets/icons/download.svg', width: 20.r, height: 20.r, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                                label: Text("Save to Gallery", style: TextStyle(fontFamily: 'CabinetGrotesk', color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16.sp)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.grey.shade300,
                                  padding: EdgeInsets.symmetric(vertical: 22.r),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.r)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.r),
                            if (widget.tier != null) ...[
                              _circleAction(
                                icon: Icons.receipt_long_rounded,
                                onTap: _downloadInvoice,
                                accent: eventColor,
                                tooltip: 'Invoice',
                              ),
                              SizedBox(width: 12.r),
                            ],
                            _circleAction(
                              iconAsset: 'assets/icons/Upload.svg',
                              onTap: _shareTicket,
                              tooltip: 'Share',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Close Button
                Positioned(
                  top: 60.r,
                  left: 20.r,
                  child: Opacity(
                    opacity: Curves.easeIn.transform(detachProgress),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
                
              ],
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CLIPPERS
// -----------------------------------------------------------------------------

class TicketClipper extends CustomClipper<Path> {
  final double holeRadius;
  final double cornerRadius;
  final double separatorY;

  TicketClipper({required this.holeRadius, required this.cornerRadius, required this.separatorY});

  @override
  Path getClip(Size size) {
    final path = Path();
    final double cr = cornerRadius;
    final double hr = holeRadius;

    path.moveTo(0, cr);
    path.lineTo(0, separatorY - hr);
    path.arcToPoint(
      Offset(0, separatorY + hr),
      radius: Radius.circular(hr),
      clockwise: true,
    );
    path.lineTo(0, size.height - cr);
    path.arcToPoint(
      Offset(cr, size.height),
      radius: Radius.circular(cr),
      clockwise: false,
    );
    path.lineTo(size.width - cr, size.height);
    path.arcToPoint(
      Offset(size.width, size.height - cr),
      radius: Radius.circular(cr),
      clockwise: false,
    );
    path.lineTo(size.width, separatorY + hr);
    path.arcToPoint(
      Offset(size.width, separatorY - hr),
      radius: Radius.circular(hr),
      clockwise: false,
    );
    path.lineTo(size.width, cr);
    path.arcToPoint(
      Offset(size.width - cr, 0),
      radius: Radius.circular(cr),
      clockwise: false,
    );
    path.lineTo(cr, 0);
    path.arcToPoint(
      Offset(0, cr),
      radius: Radius.circular(cr),
      clockwise: false,
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TicketClipper oldClipper) => 
      oldClipper.holeRadius != holeRadius || 
      oldClipper.cornerRadius != cornerRadius ||
      oldClipper.separatorY != separatorY;
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    var max = size.width;
    var dashWidth = 6.0;
    var dashSpace = 6.0;
    double startX = 0;
    while (startX < max) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
