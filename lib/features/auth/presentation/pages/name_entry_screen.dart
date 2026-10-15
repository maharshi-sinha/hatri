import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/models.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';

/// Name entry — sits between OTP and Interests.
class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({super.key});

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canContinue => _nameController.text.trim().isNotEmpty;

  void _continue() {
    HapticFeedback.mediumImpact();
    currentUser.name = _nameController.text.trim();
    context.go('/interests');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(28.r, 56.r, 28.r, 20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 4-segment progress: [fuchsia] [muted] [muted] [muted]
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.accentPink,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.r),
                          Expanded(
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.r),
                          Expanded(
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.r),
                          Expanded(
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.r),
                      Text(
                        '01 / NAME',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.accentPink,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.2.sp,
                            ),
                      ),
                      SizedBox(height: 14.r),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 64.sp,
                                  color: AppColors.primaryText,
                                  height: 0.9,
                                  letterSpacing: -1.0.sp,
                                  fontFamily: 'ClashDisplay',
                                  fontWeight: FontWeight.w800,
                                ),
                            children: const [
                              TextSpan(text: "WHAT'S\nYOUR\n"),
                              TextSpan(
                                text: 'NAME?',
                                style: TextStyle(color: AppColors.accentGreen),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 6.r),
                      Text(
                        "Tell us who's showing up.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText,
                              fontSize: 13.sp,
                            ),
                      ),
                      SizedBox(height: 32.r),
                      TextField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        autofocus: true,
                        cursorColor: AppColors.fuchsia,
                        inputFormatters: [
                          // Names only: letters (incl. accented), spaces,
                          // hyphens (Anne-Marie), apostrophes (O'Brien).
                          // Numbers and symbols are silently rejected.
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[a-zA-ZÀ-ſ\s\-']"),
                          ),
                          LengthLimitingTextInputFormatter(30),
                        ],
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 28.sp,
                          color: AppColors.paper,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Your name…',
                          hintStyle: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 28.sp,
                            color: AppColors.muted,
                          ),
                          filled: false,
                          fillColor: Colors.transparent,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14.r),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.fuchsia, width: 2),
                          ),
                        ),
                        onSubmitted: (_) {
                          if (_canContinue) _continue();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.r, 8.r, 24.r, 20.r),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canContinue ? _continue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fuchsia,
                      foregroundColor: AppColors.paper,
                      disabledBackgroundColor: AppColors.surfaceRaised,
                      disabledForegroundColor: AppColors.muted,
                      padding: EdgeInsets.symmetric(vertical: 18.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Corners.md),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'CONTINUE',
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        letterSpacing: 1.0.sp,
                      ),
                    ),
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
