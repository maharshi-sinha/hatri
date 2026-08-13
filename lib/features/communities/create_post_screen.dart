import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/responsive/responsive.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final List<TextEditingController> _pollControllers = [
    TextEditingController(text: "Yes, definitely going! 🎉"),
    TextEditingController(text: "Maybe / Interested 🧐"),
  ];

  String _selectedTopic = "#Discussion";
  final List<String> _topics = ["#Discussion", "#Meetup", "#Question", "#Review", "#Announcement"];
  
  bool _hasImageAttachment = false;
  bool _hasPoll = false;
  String? _taggedLocation;

  @override
  void dispose() {
    _contentController.dispose();
    for (var controller in _pollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPollOption() {
    if (_pollControllers.length < 4) {
      HapticFeedback.lightImpact();
      setState(() {
        _pollControllers.add(TextEditingController(text: "Option ${_pollControllers.length + 1}"));
      });
    }
  }

  void _removePollOption(int index) {
    if (_pollControllers.length > 2) {
      HapticFeedback.lightImpact();
      setState(() {
        _pollControllers[index].dispose();
        _pollControllers.removeAt(index);
      });
    }
  }

  void _showNeonSnackBar(String message, Color accentColor, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 20.r),
            ),
            SizedBox(width: 14.r),
            Expanded(
              child: Text(
                message, 
                style: TextStyle(
                  color: AppColors.primaryText, 
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  letterSpacing: 0.3.sp,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16.r, 0, 16.r, 24.r),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: accentColor, width: 1.5),
        ),
        elevation: 10.r,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePost() {
    HapticFeedback.heavyImpact();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    
    // Allow the modal close animation to complete cleanly before displaying the notification
    Future.delayed(const Duration(milliseconds: 250), () {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, color: AppColors.accentGreen, size: 20.r),
              ),
              SizedBox(width: 14.r),
              Expanded(
                child: Text(
                  'Your post has been published to the community! 🚀', 
                  style: TextStyle(
                    color: AppColors.primaryText, 
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    letterSpacing: 0.3.sp,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(16.r, 0, 16.r, 24.r),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: const BorderSide(color: AppColors.accentGreen, width: 1.5),
          ),
          elevation: 10.r,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final String authorName = currentUser.name.isEmpty || currentUser.name == 'Guest' 
        ? 'Hatri Explorer' 
        : currentUser.name;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primaryText),
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'CREATE POST',
          style: TextStyle(
            fontFamily: 'ClashDisplay',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0.sp,
            fontSize: 18.sp,
            color: AppColors.primaryText,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0.r, vertical: 8.0.r),
            child: ElevatedButton(
              onPressed: _handlePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPink,
                foregroundColor: AppColors.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.r),
              ),
              child: Text(
                'Post',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15.sp,
                  letterSpacing: 0.5.sp,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.0.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author Identity Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundImage: NetworkImage(currentUser.profileImage),
                          backgroundColor: AppColors.surface,
                        ),
                        SizedBox(width: 14.r),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorName,
                                style: TextStyle(
                                  color: AppColors.primaryText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              SizedBox(height: 4.r),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 2.r),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGreen.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6.r),
                                      border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      "COMMUNITY MEMBER",
                                      style: TextStyle(
                                        color: AppColors.accentGreen,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8.sp,
                                      ),
                                    ),
                                  ),
                                  if (_taggedLocation != null) ...[
                                    SizedBox(width: 8.r),
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 2.r),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentBlue.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6.r),
                                          border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.location_on, size: 12.r, color: AppColors.accentBlue),
                                            SizedBox(width: 4.r),
                                            Flexible(
                                              child: Text(
                                                _taggedLocation!,
                                                style: TextStyle(color: AppColors.accentBlue, fontSize: 10.sp, fontWeight: FontWeight.w700),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.r),

                    // Topic / Vibe Selector Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _topics.map((topic) {
                          final bool isSelected = _selectedTopic == topic;
                          return Padding(
                            padding: EdgeInsets.only(right: 8.0.r),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              child: FilterChip(
                                label: Text(topic),
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.background : AppColors.secondaryText,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                                selected: isSelected,
                                showCheckmark: false,
                                selectedColor: AppColors.accentYellow,
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.r),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.accentYellow : AppColors.border,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                onSelected: (selected) {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _selectedTopic = topic;
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 16.r),

                    // Main Text Content Input
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      autofocus: true,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primaryText,
                        fontSize: 18.sp,
                        height: 1.5,
                      ),
                      cursorColor: AppColors.accentPink,
                      decoration: InputDecoration(
                        hintText: "What's happening in Raipur today? Share an experience, review, or question...",
                        hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 18.sp, height: 1.5),
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    SizedBox(height: 24.r),

                    // Fluid Animated Transitions for all interactive attachments
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mock Photo Attachment Preview
                          if (_hasImageAttachment)
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: _hasImageAttachment ? 1.0 : 0.0,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 24.r),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: AppColors.accentPink.withValues(alpha: 0.5), width: 1.5),
                                  color: AppColors.surface,
                                  image: const DecorationImage(
                                    image: NetworkImage('https://images.unsplash.com/photo-1540555700478-4be289fbecef?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(color: AppColors.accentPink.withValues(alpha: 0.15), blurRadius: 16.r, offset: Offset(0, 4.r)),
                                  ],
                                ),
                                height: 220.r,
                                width: double.infinity,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 12.r,
                                      right: 12.r,
                                      child: GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          setState(() => _hasImageAttachment = false);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8.r),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.7),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white24),
                                          ),
                                          child: Icon(Icons.close, color: Colors.white, size: 18.r),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 12.r,
                                      left: 12.r,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.8),
                                          borderRadius: BorderRadius.circular(8.r),
                                          border: Border.all(color: AppColors.accentPink.withValues(alpha: 0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.photo_library, color: AppColors.accentPink, size: 14.r),
                                            SizedBox(width: 6.r),
                                            Text("1 Photo Attached", style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Interactive Poll Creator Widget
                          if (_hasPoll)
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: _hasPoll ? 1.0 : 0.0,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 24.r),
                                padding: EdgeInsets.all(20.r),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(24.r),
                                  border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.5), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(color: AppColors.accentGreen.withValues(alpha: 0.1), blurRadius: 16.r, offset: Offset(0, 4.r)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.bar_chart_rounded, color: AppColors.accentGreen),
                                            SizedBox(width: 8.r),
                                            Text(
                                              "COMMUNITY POLL",
                                              style: TextStyle(
                                                color: AppColors.accentGreen,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.sp,
                                                letterSpacing: 1.0.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.close, color: AppColors.secondaryText, size: 20.r),
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            setState(() => _hasPoll = false);
                                          },
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 16.r),
                                    Text(
                                      "Options (Members will be able to cast 1 vote):",
                                      style: TextStyle(color: AppColors.secondaryText, fontSize: 12.sp),
                                    ),
                                    SizedBox(height: 12.r),
                                    ..._pollControllers.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final controller = entry.value;
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 10.r),
                                        decoration: BoxDecoration(
                                          color: AppColors.card,
                                          borderRadius: BorderRadius.circular(14.r),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
                                        child: Row(
                                          children: [
                                            Text("${index + 1}.", style: const TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.bold)),
                                            SizedBox(width: 12.r),
                                            Expanded(
                                              child: TextField(
                                                controller: controller,
                                                style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp, fontWeight: FontWeight.w600),
                                                decoration: InputDecoration(
                                                  hintText: "Option ${index + 1}",
                                                  hintStyle: const TextStyle(color: AppColors.secondaryText),
                                                  filled: false,
                                                  fillColor: Colors.transparent,
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(vertical: 10.r),
                                                ),
                                              ),
                                            ),
                                            if (_pollControllers.length > 2)
                                              GestureDetector(
                                                onTap: () => _removePollOption(index),
                                                child: Padding(
                                                  padding: EdgeInsets.all(4.0.r),
                                                  child: Icon(Icons.remove_circle_outline, color: AppColors.secondaryText, size: 18.r),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    if (_pollControllers.length < 4)
                                      GestureDetector(
                                        onTap: _addPollOption,
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(vertical: 12.r),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14.r),
                                            border: Border.all(color: AppColors.accentGreen, style: BorderStyle.solid),
                                            color: AppColors.accentGreen.withValues(alpha: 0.1),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "+ Add Another Option",
                                              style: TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold, fontSize: 13.sp),
                                            ),
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
                  ],
                ),
              ),
            ),

            // Bottom Interactive Toolbar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 12.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  // Photo Button
                  IconButton(
                    icon: Icon(
                      _hasImageAttachment ? Icons.image : Icons.image_outlined,
                      color: _hasImageAttachment ? AppColors.accentPink : AppColors.primaryText,
                      size: 26.r,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _hasImageAttachment = !_hasImageAttachment;
                      });
                    },
                    tooltip: "Attach Photo",
                  ),
                  SizedBox(width: 8.r),

                  // Poll Button
                  IconButton(
                    icon: Icon(
                      _hasPoll ? Icons.poll : Icons.poll_outlined,
                      color: _hasPoll ? AppColors.accentGreen : AppColors.primaryText,
                      size: 26.r,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _hasPoll = !_hasPoll;
                      });
                    },
                    tooltip: "Create Poll",
                  ),
                  SizedBox(width: 8.r),

                  // Location Button
                  IconButton(
                    icon: Icon(
                      _taggedLocation != null ? Icons.location_on : Icons.location_on_outlined,
                      color: _taggedLocation != null ? AppColors.accentBlue : AppColors.primaryText,
                      size: 26.r,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _taggedLocation = _taggedLocation == null ? "Marine Drive, Raipur" : null;
                      });
                    },
                    tooltip: "Tag Location",
                  ),
                  const Spacer(),

                  // Character indicator
                  ValueListenableBuilder(
                    valueListenable: _contentController,
                    builder: (context, value, child) {
                      final len = value.text.length;
                      return Text(
                        "$len / 500",
                        style: TextStyle(
                          color: len > 500 ? Colors.red : AppColors.secondaryText,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
