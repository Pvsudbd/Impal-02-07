import 'package:flutter/material.dart';

/// Sistem Spacing Standar untuk IMPAL UI (8-point Grid System).
/// Lihat file `TYPOGRAPHY_GUIDE.md` untuk aturan dan panduan lengkapnya.
abstract class AppSpacing {
  // --- Skala Spacing Dasar (8pt Grid & 4pt Half-Steps) ---
  /// 4.0 - Micro-spacing: Jarak ikon dan teks dalam badge/chip/tag
  static const double xxs = 4.0;

  /// 8.0 - Compact: Jarak label ke input form, jarak ikon tombol ke teks
  static const double xs = 8.0;

  /// 12.0 - Component Item: Jarak antar card dalam list, gap tombol dialog
  static const double sm = 12.0;

  /// 16.0 - Standard Form & Card: Jarak antar baris form input, card horizontal padding
  static const double md = 16.0;

  /// 20.0 - Page Margin: Margin horizontal halaman layar mobile, dialog body to actions
  static const double lg = 20.0;

  /// 24.0 - Section: Jarak antar section besar, jarak form ke tombol submit CTA
  static const double xl = 24.0;

  /// 32.0 - Hero: Jarak logo / hero auth ke form
  static const double xxl = 32.0;

  /// 40.0 - Large Separation: Padding empty state
  static const double xxxl = 40.0;

  // --- EdgeInsets Preset Standar ---
  /// Padding standar satu halaman layar mobile: Left 20, Top 16, Right 20, Bottom 110 (navbar)
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(lg, md, lg, 110.0);

  /// Padding standar halaman auth form
  static const EdgeInsets authPagePadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);

  /// Padding dalam Schedule Card
  static const EdgeInsets cardPadding = EdgeInsets.fromLTRB(md, sm, 14.0, sm);

  /// Margin bawah antar Card dalam list
  static const EdgeInsets cardMarginBottom = EdgeInsets.only(bottom: sm);

  /// Padding dalam Pop-up Konfirmasi Modal
  static const EdgeInsets dialogPadding = EdgeInsets.symmetric(horizontal: lg, vertical: xl);

  /// Padding Toast Pemberitahuan atas
  static const EdgeInsets notificationPadding = EdgeInsets.symmetric(horizontal: md, vertical: sm);

  // --- SizedBox Spacers Cepat ---
  static const Widget vGapXXS = SizedBox(height: xxs);
  static const Widget vGapXS = SizedBox(height: xs);
  static const Widget vGapSM = SizedBox(height: sm);
  static const Widget vGapMD = SizedBox(height: md);
  static const Widget vGapLG = SizedBox(height: lg);
  static const Widget vGapXL = SizedBox(height: xl);
  static const Widget vGapXXL = SizedBox(height: xxl);

  static const Widget hGapXXS = SizedBox(width: xxs);
  static const Widget hGapXS = SizedBox(width: xs);
  static const Widget hGapSM = SizedBox(width: sm);
  static const Widget hGapMD = SizedBox(width: md);
  static const Widget hGapLG = SizedBox(width: lg);
  static const Widget hGapXL = SizedBox(width: xl);
}
