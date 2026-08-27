import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../core/responsive/responsive.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Keyboard overlays the content — prevents the empty state from
      // getting squashed and overflowing.
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 24.r),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      // Dismiss keyboard BEFORE popping so the keyboard slide-out
                      // doesn't stutter the route transition on the same frame.
                      FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50.r,
                      height: 50.r,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/arrow-left.svg',
                          width: 26.r,
                          height: 26.r,
                          colorFilter: const ColorFilter.mode(AppColors.secondaryText, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.r),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.r),
                      height: 50.r,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/Search.svg',
                            width: 20.r,
                            height: 20.r,
                            colorFilter: const ColorFilter.mode(AppColors.secondaryText, BlendMode.srcIn),
                          ),
                          SizedBox(width: 12.r),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                              cursorColor: AppColors.accentPink,
                              decoration: InputDecoration(
                                hintText: 'Search anything...',
                                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                                filled: false,
                                fillColor: Colors.transparent,
                                // Kill every border state so the theme's pink
                                // focused-outline never leaks into the custom pill.
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SEARCH',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 48.sp,
                        color: AppColors.border,
                        letterSpacing: -0.5.sp,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 12.r),
                    Text(
                      'Type something to start searching.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
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
}
