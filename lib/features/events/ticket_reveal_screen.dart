import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import '../../core/responsive/responsive.dart';

class TicketRevealScreen extends StatefulWidget {
  final Event event;

  const TicketRevealScreen({super.key, required this.event});

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
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _idleController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FREE',
                          style: TextStyle(color: eventColor, fontSize: 18.sp, fontWeight: FontWeight.bold, letterSpacing: 1.0.sp),
                        ),
                        Text(
                          '#HTR-89241',
                          style: TextStyle(color: AppColors.secondaryText, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 1.0.sp),
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
                        child: Icon(Icons.qr_code_2, color: Colors.black, size: 100.r),
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
    // The printer housing frames the ticket, so it tracks the same width.
    final width = math.min(360.r, MediaQuery.sizeOf(context).width - Insets.md * 2);
    return Container(
      width: width,
      height: width * (560 / 360),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Off-white realistic plastic
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 40.r, offset: Offset(0, 20.r)),
          BoxShadow(color: Colors.white, blurRadius: 2.r), // inner specular highlight
        ]
      ),
      child: Stack(
        children: [
          // Status LED
          Positioned(
            top: 6.r, left: 6.r,
            child: AnimatedBuilder(
              animation: _idleController,
              builder: (context, child) {
                // If finished: Solid green. If printing: Fast orange blink. If idle: Slow green breathe.
                double opacity = 1.0;
                Color ledColor = Colors.greenAccent;
                
                if (_isFinished) {
                  opacity = 1.0;
                  ledColor = Colors.greenAccent;
                } else if (_isPrinting) {
                  opacity = (math.sin(_idleController.value * math.pi * 8) + 1.0) / 2.0; // Fast blink
                  ledColor = Colors.orangeAccent;
                } else {
                  opacity = (math.sin(_idleController.value * math.pi * 2) + 1.0) / 2.0;
                  opacity = 0.3 + (opacity * 0.7); // 0.3 to 1.0 slow breathe
                  ledColor = Colors.greenAccent;
                }

                return Container(
                  width: 12.r, height: 12.r,
                  decoration: BoxDecoration(
                    color: ledColor.withOpacity(opacity),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: ledColor.withOpacity(opacity), blurRadius: 8.r)
                    ]
                  ),
                );
              }
            ),
          ),
          // Branding
          Positioned(
            top: 0, right: 6.r,
            child: Text(
              "hatri\nprinter", 
              textAlign: TextAlign.right, 
              style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w900, fontSize: 16.sp, height: 1.0)
            ),
          ),
          // The Dispenser Slit
          Positioned(
            top: 80.r, left: 10.r, right: 10.r,
            child: Container(
              height: 8.r,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(4.r),
                boxShadow: [
                  BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 1.r, offset: Offset(0, 1.r)),
                  BoxShadow(color: Colors.black87, blurRadius: 4.r, offset: Offset(0, 2.r)),
                ],
              ),
            ),
          ),
          // Massive Tactile Button
          Positioned(
            bottom: 40.r, left: 0, right: 0,
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
                          // The Ripple Effect
                          if (!_isPrinting && !_isFinished)
                            AnimatedBuilder(
                              animation: _idleController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (_idleController.value * 0.4), // Expands outwards
                                  child: Opacity(
                                    opacity: 1.0 - _idleController.value, // Fades out
                                    child: Container(
                                      width: 130.r, height: 130.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFFE94B8C), width: 4.r),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            ),
                          // The Solid Button
                          Container(
                            width: 130.r, height: 130.r,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE94B8C), // Vibrant Pink
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE94B8C).withOpacity(0.4), 
                                  blurRadius: _isButtonDown ? 10 : 20, 
                                  offset: Offset(0, _isButtonDown ? 5 : 10)
                                )
                              ]
                            ),
                            child: Center(
                              child: Icon(Icons.touch_app, color: Colors.white, size: 50.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.r),
                AnimatedOpacity(
                  opacity: _isFinished || _isPrinting ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text("TAP TO CLAIM", style: TextStyle(color: Color(0xFFE94B8C), fontWeight: FontWeight.bold, letterSpacing: 2.0.sp)),
                )
              ]
            )
          )
        ]
      )
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
                            SizedBox(width: 16.r),
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _shareTicket();
                              },
                              borderRadius: BorderRadius.circular(100.r),
                              child: Container(
                                padding: EdgeInsets.all(20.r),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/Upload.svg',
                                  width: 24.r,
                                  height: 24.r,
                                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                ),
                              ),
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
