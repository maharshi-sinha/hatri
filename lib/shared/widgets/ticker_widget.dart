import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/responsive/responsive.dart';

class TickerWidget extends StatefulWidget {
  final List<String> texts;

  const TickerWidget({super.key, required this.texts});

  @override
  State<TickerWidget> createState() => _TickerWidgetState();
}

class _TickerWidgetState extends State<TickerWidget> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28), // Matches HTML marquee 28s
    )..repeat();

    _animationController.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = maxScroll * _animationController.value;
        _scrollController.jumpTo(currentScroll);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Duplicate the texts to create a seamless scrolling loop
    final tickerItems = [...widget.texts, ...widget.texts];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 7.r),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.card),
          bottom: BorderSide(color: AppColors.card),
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: tickerItems.map((text) {
            Color textColor;
            if (text.startsWith('🔥')) {
              textColor = AppColors.accentPink;
            } else if (text == '·') {
              textColor = AppColors.border;
            } else {
              textColor = AppColors.secondaryText;
            }

            return Padding(
              padding: EdgeInsets.only(right: 14.r),
              child: Text(
                text,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 13.sp,
                      color: textColor,
                      letterSpacing: 1.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
