import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/responsive/responsive.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final TextEditingController _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _pickedPhoto;

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

  Future<void> _pickPhoto() async {
    HapticFeedback.lightImpact();
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (xfile == null) return;
    setState(() {
      _pickedPhoto = File(xfile.path);
      // Held locally until Supabase Storage upload wires up. Then Sprint F1c/3c
      // swaps this to the returned public URL.
      currentUser.profileImage = xfile.path;
    });
  }

  Future<void> _onNext() async {
    HapticFeedback.mediumImpact();
    currentUser.bio = _bioController.text.trim();
    if (!mounted) return;
    // Bio → step 04 (vibes: birthday + gender). Vibes screen handles the rest
    // of the flow through to permission screens / celebration.
    context.go('/vibes');
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
                    // Progress bar — 4 steps now (name / interests / details / vibes).
                    // Step 04 (vibes) is dimmed until it becomes active.
                    Row(
                      children: [
                        Expanded(child: Container(height: 3, color: AppColors.accentPink)),
                        SizedBox(width: 4.r),
                        Expanded(child: Container(height: 3, color: AppColors.accentGreen)),
                        SizedBox(width: 4.r),
                        Expanded(child: Container(height: 3, color: AppColors.accentBlue)),
                        SizedBox(width: 4.r),
                        Expanded(
                          child: Container(
                            height: 3,
                            color: AppColors.accentYellow.withValues(alpha: 0.25),
                          ),
                        ),
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

                    // Avatar picker — real image_picker from gallery.
                    Center(
                      child: GestureDetector(
                        onTap: _pickPhoto,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 120.r,
                          height: 120.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accentBlue, width: 2),
                            color: AppColors.card,
                            image: _pickedPhoto != null
                                ? DecorationImage(
                                    image: FileImage(_pickedPhoto!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            boxShadow: [
                              if (_pickedPhoto != null)
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
                              if (_pickedPhoto == null)
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
                                    _pickedPhoto != null ? Icons.check : Icons.add,
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

                    // Bio input — matches the name-entry TextField styling.
                    TextField(
                      controller: _bioController,
                      cursorColor: AppColors.fuchsia,
                      maxLines: 3,
                      minLines: 1,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w600,
                        fontSize: 28.sp,
                        color: AppColors.paper,
                      ),
                      decoration: InputDecoration(
                        hintText: 'A short bio…',
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
                          borderSide: BorderSide(color: AppColors.fuchsia, width: 2),
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
