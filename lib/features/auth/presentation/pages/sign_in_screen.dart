import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/models.dart';
import '../../../../core/responsive/responsive.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNext() {
    HapticFeedback.mediumImpact();
    if (_nameController.text.trim().isNotEmpty) {
      currentUser.name = _nameController.text.trim();
    }
    context.go('/interests');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0.r, vertical: 32.0.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Progress Bar
                    Row(
                      children: [
                        Expanded(child: Container(height: 3, color: AppColors.accentPink)),
                        SizedBox(width: 4.r),
                        Expanded(child: Container(height: 3, color: AppColors.card)),
                        SizedBox(width: 4.r),
                        Expanded(child: Container(height: 3, color: AppColors.card)),
                      ],
                    ),
                    SizedBox(height: 24.r),
                    
                    // Step Indicator
                    Text(
                      '01 / NAME',
                      style: TextStyle(
                        color: AppColors.accentPink,
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
                    SizedBox(height: 48.r),

                    // Name Input
                    TextField(
                      controller: _nameController,
                      cursorColor: AppColors.accentPink,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Your name...',
                        hintStyle: TextStyle(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'GeneralSans',
                        ),
                        filled: false,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.r),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.accentPink, width: 2),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),

                    const Spacer(),
                    SizedBox(height: 32.r),

                    // Next Button
                    ElevatedButton(
                      onPressed: _nameController.text.trim().isNotEmpty ? _onNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _nameController.text.trim().isNotEmpty ? AppColors.accentPink : AppColors.card,
                        disabledBackgroundColor: AppColors.card,
                        padding: EdgeInsets.symmetric(vertical: 20.r),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        "CONTINUE",
                        style: TextStyle(
                          color: _nameController.text.trim().isNotEmpty ? AppColors.primaryText : AppColors.secondaryText,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0.sp,
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
    );
  }
}
