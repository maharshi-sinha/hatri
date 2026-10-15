import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../backend/services/user_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/models/models.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/design/hatri_snack.dart';

class Interest {
  final String id;
  final String label;
  final String emoji;
  Interest(this.id, this.label, this.emoji);
}

class InterestSelectionScreen extends StatefulWidget {
  final bool isEditMode;
  const InterestSelectionScreen({super.key, this.isEditMode = false});

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  final List<Interest> _interests = [
    Interest("music", "Music", "🎵"),
    Interest("art", "Art & Design", "🎨"),
    Interest("tech", "Tech & Code", "💻"),
    Interest("food", "Food & Drink", "🍔"),
    Interest("nightlife", "Nightlife", "🥂"),
    Interest("sports", "Sports", "⚽"),
    Interest("photography", "Photography", "📷"),
    Interest("fashion", "Fashion", "👗"),
    Interest("networking", "Networking", "🤝"),
    Interest("gaming", "Gaming", "🎮"),
    Interest("literature", "Literature", "📚"),
    Interest("outdoors", "Outdoors", "🌲"),
    Interest("wellness", "Wellness", "🧘"),
    Interest("film", "Film & TV", "🍿"),
    Interest("travel", "Travel", "✈️"),
    Interest("business", "Business", "💼"),
    Interest("comedy", "Comedy", "😂"),
    Interest("dance", "Dance", "💃"),
  ];

  final List<Color> _iColors = [
    AppColors.fromHex('#FF2D8D'),
    AppColors.fromHex('#A3FF12'),
    AppColors.fromHex('#2D7DFF'),
    AppColors.fromHex('#FFD400'),
    AppColors.fromHex('#7B2DFF'),
    AppColors.fromHex('#FF7A00'),
  ];

  late final Set<String> _selectedInterests = widget.isEditMode
      ? currentUser.interests.toSet()
      : <String>{};
  bool _saving = false;

  Future<void> _onContinue() async {
    if (_saving) return;
    currentUser.interests = _selectedInterests.toList();
    if (!widget.isEditMode) {
      context.go('/user-details');
      return;
    }
    // Edit mode persists through the backend so the change survives a
    // relaunch. installUserSync will re-mirror currentUser from the
    // refreshed ApiUser once updateCachedUser fires.
    setState(() => _saving = true);
    try {
      await sl<UserService>().updateProfile(interests: _selectedInterests.toList());
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      HatriSnack.show(
        context,
        "couldn't save. check your connection and try again.",
        vibe: SnackVibe.info,
        emoji: '⚠️',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enough = _selectedInterests.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- Header (progress bar + step + title + subtitle) ----------
            Padding(
              padding: EdgeInsets.fromLTRB(28.r, 56.r, 28.r, 20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                            color: AppColors.accentGreen,
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
                    '02 / INTERESTS',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.accentGreen,
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
                          TextSpan(text: "WHAT'S\n"),
                          TextSpan(
                            text: 'YOUR VIBE?',
                            style: TextStyle(color: AppColors.accentGreen),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 6.r),
                  Text(
                    "Pick your interests - we'll personalize everything.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                          fontSize: 13.sp,
                        ),
                  ),
                ],
              ),
            ),

            // ---------- Chips fill remaining space; scroll if overflow ----------
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(28.r, 12.r, 28.r, 20.r),
                    child: Wrap(
                      spacing: 9.r,
                      runSpacing: 14.r,
                      children: _interests.asMap().entries.map((entry) {
                        final i = entry.key;
                        final interest = entry.value;
                        final isSelected = _selectedInterests.contains(interest.id);
                        final Color col = _iColors[i % _iColors.length];
                        // Adapt text color to the chip color's brightness so bright
                        // colors (lime, yellow) get near-black text and dark colors
                        // (fuchsia, blue, indigo) get white text.
                        final bool isDarkCol = col.computeLuminance() > 0.55;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedInterests.remove(interest.id);
                              } else {
                                _selectedInterests.add(interest.id);
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 9.r),
                            decoration: BoxDecoration(
                              color: isSelected ? col : Colors.transparent,
                              borderRadius: BorderRadius.circular(100.r),
                              border: Border.all(
                                color: isSelected ? col : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(interest.emoji, style: TextStyle(fontSize: 13.sp)),
                                SizedBox(width: 7.r),
                                Text(
                                  interest.label,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp,
                                        color: isSelected
                                            ? (isDarkCol
                                                ? AppColors.background
                                                : AppColors.primaryText)
                                            : AppColors.secondaryText,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Bottom fade so chips scrolling past dissolve into the CTA area
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: 24.r,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00000000), AppColors.background],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------- CTA — glued to the bottom of the safe area ----------
            Padding(
              padding: EdgeInsets.fromLTRB(28.r, 8.r, 28.r, 20.r),
              child: ElevatedButton(
                onPressed: (enough && !_saving) ? _onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: enough ? AppColors.accentGreen : AppColors.card,
                  disabledBackgroundColor: AppColors.card,
                  foregroundColor:
                      enough ? AppColors.background : AppColors.secondaryText,
                  padding: EdgeInsets.symmetric(vertical: 18.r),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _saving ? "SAVING…" : "CONTINUE",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2.sp,
                        color: enough
                            ? AppColors.background
                            : AppColors.secondaryText,
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
