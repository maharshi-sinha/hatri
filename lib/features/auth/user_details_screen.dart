import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../core/responsive/responsive.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final TextEditingController _bioController = TextEditingController();
  bool _isPhotoAdded = false;

  @override
  void initState() {
    super.initState();
    _bioController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    HapticFeedback.mediumImpact();
    // Skip permission screens if they're already granted (subsequent runs).
    // New installs still see the screens because status starts as .notDetermined.
    final notif = await Permission.notification.status;
    final loc = await Permission.locationWhenInUse.status;
    if (!mounted) return;
    if (notif.isGranted && loc.isGranted) {
      context.go('/celebration');
    } else if (notif.isGranted) {
      context.go('/location-permission');
    } else {
      context.go('/notification-permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _bioController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      // resizeToAvoidBottomInset defaults to true — keeps the CTA above the keyboard.
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- Scrollable content ----------
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.r, 32.r, 24.r, 16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress bar
                    Row(
                      children: [
                        Expanded(child: Container(height: 3, color: AppColors.accentPink)),
                        SizedBox(width: 4.r),
                        Expanded(child: Container(height: 3, color: AppColors.accentGreen)),
                        SizedBox(width: 4.r),
                        Expanded(child: Container(height: 3, color: AppColors.accentBlue)),
                      ],
                    ),
                    SizedBox(height: 24.r),

                    // Step label
                    Text(
                      '03 / DETAILS',
                      style: TextStyle(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        letterSpacing: 2.0.sp,
                      ),
                    ),
                    SizedBox(height: 12.r),

                    // Hero title
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 56.sp,
                                color: AppColors.primaryText,
                                height: 0.9,
                                letterSpacing: -1.0.sp,
                                fontFamily: 'ClashDisplay',
                                fontWeight: FontWeight.w800,
                              ),
                          children: const [
                            TextSpan(text: 'TELL US\nABOUT\n'),
                            TextSpan(
                              text: 'YOURSELF.',
                              style: TextStyle(color: AppColors.accentBlue),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40.r),

                    // Avatar picker
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _isPhotoAdded = !_isPhotoAdded);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 120.r,
                          height: 120.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accentBlue, width: 2),
                            color: AppColors.card,
                            image: _isPhotoAdded
                                ? const DecorationImage(
                                    image: NetworkImage(
                                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            boxShadow: [
                              if (_isPhotoAdded)
                                BoxShadow(
                                  color: AppColors.accentBlue.withValues(alpha: 0.3),
                                  blurRadius: 20.r,
                                  spreadRadius: 2.r,
                                ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (!_isPhotoAdded)
                                Icon(Icons.camera_alt, color: AppColors.secondaryText, size: 32.r),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isPhotoAdded ? Icons.check : Icons.add,
                                    color: Colors.white,
                                    size: 16.r,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.r),

                    // Bio input — clean underline (opts out of the theme's filled-box).
                    TextField(
                      controller: _bioController,
                      cursorColor: AppColors.accentBlue,
                      maxLines: 3,
                      minLines: 1,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                      ),
                      decoration: InputDecoration(
                        hintText: 'A short bio…',
                        hintStyle: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 22.sp,
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
                          borderSide: BorderSide(color: AppColors.accentBlue, width: 2),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.r),
                  ],
                ),
              ),
            ),

            // ---------- Pinned CTA (always visible, lifts with keyboard) ----------
            Padding(
              padding: EdgeInsets.fromLTRB(24.r, 8.r, 24.r, 16.r),
              child: ElevatedButton(
                onPressed: canContinue ? _onNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canContinue ? AppColors.accentBlue : AppColors.card,
                  disabledBackgroundColor: AppColors.card,
                  padding: EdgeInsets.symmetric(vertical: 20.r),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  "LET'S GO",
                  style: TextStyle(
                    color: canContinue ? AppColors.paper : AppColors.secondaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0.sp,
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
