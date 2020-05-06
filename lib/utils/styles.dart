import 'package:flutter/material.dart';

class AppColors {
  static const Color red = Colors.redAccent;
  static const Color white = const Color(0xFFFFFFFF);
  static const Color black = const Color(0xFF222222);
  static const Color cardinal = const Color(0xFFBC154C);
  static const Color razzmatazz = const Color(0xFFF01C62);
  static const Color blueGrey = Colors.blueGrey;
  static const Color blackLight = const Color(0xFF555555);
  static const Color whiteLight = const Color.fromRGBO(255, 255, 255, 0.7);
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static Color getColorByName(player) {
    switch (player) {
      case 'blue':
        return Colors.blue;
        break;
      case 'yellow':
        return Colors.yellow;
        break;
      case 'green':
        return Colors.green;
        break;
      case 'orange':
        return Colors.orange;
        break;
      default:
        return Colors.red;
    }
  }
}

class AppFonts {
  static const String primary = 'Roboto Slab';
  static const String secondary = 'Audiowide';
  static const String third = 'Bungee Inline';
}

class AppTextStyles {
  static const TextStyle regularText =
      const TextStyle(fontSize: 16.0, color: AppColors.white);
  static const TextStyle mediumText = const TextStyle(
      fontSize: 22.0, fontWeight: FontWeight.w500, color: AppColors.white);
  static const TextStyle boldText = const TextStyle(
      fontSize: 24.0, fontWeight: FontWeight.w600, color: AppColors.white);
  static const TextStyle landingHeadingText = const TextStyle(
      fontFamily: AppFonts.third, fontSize: 42.0, color: AppColors.cardinal);
  static const TextStyle buttonText =
      const TextStyle(color: AppColors.white, fontSize: 22.0);
  static const TextStyle confirmationTitle =
      const TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600);
  static const TextStyle confirmationMessage =
      const TextStyle(fontFamily: AppFonts.secondary, fontSize: 18.0);
  static const TextStyle confirmationButton = const TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.w400, color: AppColors.blackLight);
  static const TextStyle rulesHeading = const TextStyle(
      color: AppColors.black,
      fontFamily: AppFonts.primary,
      fontSize: 20.0,
      fontWeight: FontWeight.bold);
  static const TextStyle rulesText = const TextStyle(
      color: AppColors.black,
      fontFamily: AppFonts.primary,
      fontSize: 15.0,
      fontWeight: FontWeight.w500);
}
