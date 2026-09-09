import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/responsive/responsive.dart';
import '../../core/theme/app_theme.dart';

/// End-of-scroll cityscape moment — big italic #HATRI wordmark over a subtle
/// city-skyline line-art background. Reused by Home + City.
class CityscapeFooter extends StatelessWidget {
  const CityscapeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 620.r,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: Platform.isIOS ? 50.r : 0),
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/images/city_skyline.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(-1.0, 0.05),
            child: Padding(
              padding: EdgeInsets.only(left: 20.r, right: 20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#HATRI',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      fontSize: 52.sp,
                      height: 1.0,
                      letterSpacing: -1.6.sp,
                      color: AppColors.paper,
                    ),
                  ),
                  SizedBox(height: 2.r),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Crafted with ',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: AppColors.paper,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/icons/heart.svg',
                        width: 16.r,
                        height: 14.r,
                      ),
                      Text(
                        ' in India',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: AppColors.paper,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
