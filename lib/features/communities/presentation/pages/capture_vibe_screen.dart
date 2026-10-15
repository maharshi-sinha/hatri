import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/responsive/responsive.dart';

class CaptureVibeScreen extends StatefulWidget {
  const CaptureVibeScreen({super.key});

  @override
  State<CaptureVibeScreen> createState() => _CaptureVibeScreenState();
}

class _CaptureVibeScreenState extends State<CaptureVibeScreen> {
  bool _isPreviewMode = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _capturePhoto() {
    setState(() {
      _isPreviewMode = true;
    });
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _isPreviewMode = true;
      });
    }
  }

  void _retakePhoto() {
    setState(() {
      _isPreviewMode = false;
      _imageFile = null;
      _captionController.clear();
    });
  }

  void _postVibe() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Corners.xl)),
      ),
      builder: (context) => _buildCommunitySelector(),
    );
  }

  Widget _buildCommunitySelector() {
    final dummyCommunities = ['Foodies of Raipur', 'Night Riders', 'Study Buddies'];

    return Padding(
      padding: EdgeInsets.all(Insets.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.r,
              height: 4.r,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.r),
          Text(
            'POST VIBE TO...',
            style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w800,
              fontSize: 12.sp,
              letterSpacing: 1.2.sp,
              color: AppColors.muted,
            ),
          ),
          SizedBox(height: 16.r),
          ...dummyCommunities.map((name) => Padding(
            padding: EdgeInsets.only(bottom: 12.r),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // close bottom sheet
                Navigator.pop(context); // close capture screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vibe posted to $name!', style: TextStyle(fontFamily: 'GeneralSans', fontWeight: FontWeight.w600)),
                    backgroundColor: AppColors.fuchsia,
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 16.r),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(Corners.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        color: AppColors.paper,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, color: AppColors.muted, size: 14.r),
                  ],
                ),
              ),
            ),
          )),
          SizedBox(height: 32.r),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false, // let the camera go to the bottom edge if we want
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                margin: EdgeInsets.only(bottom: 24.r), // leave some space if needed, or fill
                decoration: BoxDecoration(
                  color: _isPreviewMode ? AppColors.indigo : AppColors.graphite,
                  borderRadius: BorderRadius.circular(Corners.xl), // smoother corners
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Corners.xl),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_imageFile != null)
                        Image.file(_imageFile!, fit: BoxFit.cover)
                      else if (!_isPreviewMode)
                        Center(
                          child: Icon(Icons.camera_alt_outlined, color: AppColors.muted, size: 48.r),
                        ),
                      
                      if (_isPreviewMode)
                        _buildPreviewOverlay(),

                      // Subtle gradient overlays to make UI pop
                      if (!_isPreviewMode)
                        Positioned(
                          top: 0, left: 0, right: 0,
                          height: 120.r,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                              ),
                            ),
                          ),
                        ),
                      if (!_isPreviewMode)
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          height: 180.r,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 24.r,
              left: 24.r,
              right: 24.r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _isPreviewMode ? _retakePhoto() : Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Icon(
                        _isPreviewMode ? Icons.close_rounded : Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24.r,
                      ),
                    ),
                  ),
                  if (!_isPreviewMode)
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Icon(Icons.flash_off_rounded, color: Colors.white, size: 24.r),
                    ),
                ],
              ),
            ),
            if (!_isPreviewMode)
              Positioned(
                bottom: 60.r,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _pickFromGallery,
                      child: Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Icon(Icons.photo_library_outlined, color: Colors.white, size: 28.r),
                      ),
                    ),
                    GestureDetector(
                      onTap: _capturePhoto,
                      child: Container(
                        width: 86.r,
                        height: 86.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 6.r),
                        ),
                        child: Center(
                          child: Container(
                            width: 68.r,
                            height: 68.r,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 28.r),
                    ),
                  ],
                ),
              ),
            if (_isPreviewMode)
              Positioned(
                bottom: 40.r,
                left: 24.r,
                right: 24.r,
                child: GestureDetector(
                  onTap: _postVibe,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 18.r),
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      borderRadius: BorderRadius.circular(Corners.pill),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lime.withValues(alpha: 0.3),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'POST VIBE',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w800,
                          fontSize: 16.sp,
                          letterSpacing: 1.sp,
                          color: AppColors.ground,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewOverlay() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black.withValues(alpha: 0.2),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.r),
            child: TextField(
              controller: _captionController,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                fontWeight: FontWeight.w600,
                fontSize: 32.sp,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ],
              ),
              decoration: InputDecoration(
                hintText: 'Type a caption...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          ),
        ),
      ],
    );
  }
}
