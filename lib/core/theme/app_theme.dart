import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  fontFamily: GoogleFonts.inter().fontFamily,
  scaffoldBackgroundColor: AppColors.bg,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    foregroundColor: AppColors.text,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
  ),
  useMaterial3: true,
);
