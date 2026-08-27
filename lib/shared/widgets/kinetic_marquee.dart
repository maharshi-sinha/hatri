import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';

/// Auto-drifting horizontal band of oversized italic text, separated by a
/// glyph. Purely decorative — used as an editorial rule between sections.
class KineticMarquee extends StatefulWidget {
  final String word;
  final String separator;
  final Widget? separatorWidget;
  final Color? wordColor;
  final Color? separatorColor;
  final double? height;
  final double? fontSize;

  const KineticMarquee({
    super.key,
    this.word = 'SCENES',
    this.separator = '★',
    this.separatorWidget,
    this.wordColor,
    this.separatorColor,
    this.height,
    this.fontSize,
  });

  @override
  State<KineticMarquee> createState() => _KineticMarqueeState();
}

class _KineticMarqueeState extends State<KineticMarquee> with SingleTickerProviderStateMixin {
  final _controller = ScrollController();
  Timer? _timer;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startDrift());
  }

  void _startDrift() {
    _timer = Timer.periodic(const Duration(milliseconds: 32), (_) {
      if (!mounted || !_controller.hasClients) return;
      _offset += 2.4;
      if (_offset > _controller.position.maxScrollExtent - 40) {
        _offset = 0;
      }
      _controller.jumpTo(_offset);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordColor = widget.wordColor ?? AppColors.paper.withValues(alpha: 0.10);
    final sepColor = widget.separatorColor ?? AppColors.lime.withValues(alpha: 0.55);
    final fontSize = widget.fontSize ?? 44.sp;
    return Padding(
      padding: EdgeInsets.only(top: 10.r, bottom: 6.r),
      child: SizedBox(
        height: widget.height ?? 52.r,
        child: IgnorePointer(
          child: ListView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 40,
            itemBuilder: (context, i) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.r),
                child: Row(
                  children: [
                    Text(
                      widget.word,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        fontSize: fontSize,
                        letterSpacing: -1.5.sp,
                        color: wordColor,
                      ),
                    ),
                    SizedBox(width: 12.r),
                    if (widget.separatorWidget != null)
                      widget.separatorWidget!
                    else
                      Text(
                        widget.separator,
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontWeight: FontWeight.w800,
                          fontSize: fontSize * 0.64,
                          color: sepColor,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
