import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows the bespoke IMPAL 24-hour time picker dialog with optimized
/// spacing, centered typography, and support for both Dial ("Roda") and
/// Input ("Ketik") modes.
Future<TimeOfDay?> showImpalTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  String title = 'Select Time',
}) {
  return showDialog<TimeOfDay>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (ctx) => ImpalTimePickerDialog(
      initialTime: initialTime,
      title: title,
    ),
  );
}

/// Custom 24-Hour Time Picker Dialog built specifically for IMPAL's design system.
class ImpalTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final String title;

  const ImpalTimePickerDialog({
    super.key,
    required this.initialTime,
    this.title = 'Select Time',
  });

  @override
  State<ImpalTimePickerDialog> createState() => _ImpalTimePickerDialogState();
}

class _ImpalTimePickerDialogState extends State<ImpalTimePickerDialog> {
  late int _hour;
  late int _minute;
  bool _isDialMode = true; // true = Dial/Roda, false = Ketik/Input
  bool _isPickingHour = true; // true = Picking Hour, false = Picking Minute

  late final TextEditingController _hourController;
  late final TextEditingController _minuteController;
  final FocusNode _hourFocus = FocusNode();
  final FocusNode _minuteFocus = FocusNode();

  double _hourDragAccumulator = 0.0;
  double _minuteDragAccumulator = 0.0;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;

    _hourController = TextEditingController(text: _hour.toString().padLeft(2, '0'));
    _minuteController = TextEditingController(text: _minute.toString().padLeft(2, '0'));

    _hourController.addListener(_onHourTextChanged);
    _minuteController.addListener(_onMinuteTextChanged);

    _hourFocus.addListener(_onFocusChanged);
    _minuteFocus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!_hourFocus.hasFocus && !_minuteFocus.hasFocus) {
      _syncControllers();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hourFocus.removeListener(_onFocusChanged);
    _minuteFocus.removeListener(_onFocusChanged);
    _hourController.removeListener(_onHourTextChanged);
    _minuteController.removeListener(_onMinuteTextChanged);
    _hourController.dispose();
    _minuteController.dispose();
    _hourFocus.dispose();
    _minuteFocus.dispose();
    super.dispose();
  }

  void _onHourTextChanged() {
    final text = _hourController.text.trim();
    if (text.isNotEmpty) {
      final val = int.tryParse(text);
      if (val != null && val >= 0 && val <= 23) {
        _hour = val;
        if (text.length == 2 && _hourFocus.hasFocus) {
          _minuteFocus.requestFocus();
          _minuteController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _minuteController.text.length,
          );
        }
      }
    }
  }

  void _onMinuteTextChanged() {
    final text = _minuteController.text.trim();
    if (text.isNotEmpty) {
      final val = int.tryParse(text);
      if (val != null && val >= 0 && val <= 59) {
        _minute = val;
      }
    }
  }

  void _syncControllers() {
    final hVal = int.tryParse(_hourController.text.trim());
    if (hVal != null && hVal >= 0 && hVal <= 23) {
      _hour = hVal;
    }
    final mVal = int.tryParse(_minuteController.text.trim());
    if (mVal != null && mVal >= 0 && mVal <= 59) {
      _minute = mVal;
    }

    final newH = _hour.toString().padLeft(2, '0');
    final newM = _minute.toString().padLeft(2, '0');
    if (_hourController.text != newH) {
      _hourController.text = newH;
    }
    if (_minuteController.text != newM) {
      _minuteController.text = newM;
    }
  }

  void _updateHour(int newHour) {
    setState(() {
      _hour = newHour.clamp(0, 23);
      _hourController.text = _hour.toString().padLeft(2, '0');
    });
  }

  void _updateMinute(int newMinute) {
    setState(() {
      _minute = newMinute.clamp(0, 59);
      _minuteController.text = _minute.toString().padLeft(2, '0');
    });
  }

  void _handleHourDrag(double dy) {
    _hourDragAccumulator += dy;
    const threshold = 12.0;
    if (_hourDragAccumulator >= threshold) {
      // Scrolled / dragged down -> value increases (makin besar)
      _updateHour((_hour + 1) % 24);
      _hourDragAccumulator = 0.0;
    } else if (_hourDragAccumulator <= -threshold) {
      // Scrolled / dragged up -> value decreases (makin kecil)
      _updateHour((_hour - 1 + 24) % 24);
      _hourDragAccumulator = 0.0;
    }
  }

  void _handleMinuteDrag(double dy) {
    _minuteDragAccumulator += dy;
    const threshold = 10.0;
    if (_minuteDragAccumulator >= threshold) {
      // Scrolled / dragged down -> value increases (makin besar)
      _updateMinute((_minute + 1) % 60);
      _minuteDragAccumulator = 0.0;
    } else if (_minuteDragAccumulator <= -threshold) {
      // Scrolled / dragged up -> value decreases (makin kecil)
      _updateMinute((_minute - 1 + 60) % 60);
      _minuteDragAccumulator = 0.0;
    }
  }

  void _handleHourPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (event.scrollDelta.dy > 0) {
        // Scrolled down -> value increases (makin besar)
        _updateHour((_hour + 1) % 24);
      } else if (event.scrollDelta.dy < 0) {
        // Scrolled up -> value decreases (makin kecil)
        _updateHour((_hour - 1 + 24) % 24);
      }
    }
  }

  void _handleMinutePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (event.scrollDelta.dy > 0) {
        // Scrolled down -> value increases (makin besar)
        _updateMinute((_minute + 1) % 60);
      } else if (event.scrollDelta.dy < 0) {
        // Scrolled up -> value decreases (makin kecil)
        _updateMinute((_minute - 1 + 60) % 60);
      }
    }
  }

  void _confirm() {
    final hVal = int.tryParse(_hourController.text.trim());
    if (hVal != null && hVal >= 0 && hVal <= 23) {
      _hour = hVal;
    }
    final mVal = int.tryParse(_minuteController.text.trim());
    if (mVal != null && mVal >= 0 && mVal <= 59) {
      _minute = mVal;
    }
    Navigator.of(context).pop(TimeOfDay(hour: _hour, minute: _minute));
  }

  @override
  Widget build(BuildContext context) {
    final hourStr = _hour.toString().padLeft(2, '0');
    final minuteStr = _minute.toString().padLeft(2, '0');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 330,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: const Color(0xFF282D37),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            width: 1,
            color: const Color(0xFF3B4150),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 35,
              offset: Offset(0, 18),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Top Title & Mode Toggle Bar
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isDialMode = !_isDialMode;
                      _syncControllers();
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF282D37),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3B4150), width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _isDialMode ? Icons.keyboard_alt_outlined : Icons.access_time_rounded,
                      size: 17,
                      color: const Color(0xFFFA6144),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Mode Content: Dial ("Roda") or Ketik ("Input")
            if (_isDialMode) ...[
              // Dial Mode: Time Display Header
              _buildDialTimeHeader(hourStr, minuteStr),
              const SizedBox(height: 16),
              // Dial Clock Face
              _buildDialSection(),
            ] else ...[
              // Ketik Mode: SINGLE unified minimalist time container (typeable & scrollable)
              const SizedBox(height: 6),
              _buildKetikTimeCard(),
              const SizedBox(height: 14),
              const Text(
                'Scroll up (-) / down (+) or tap to type',
                style: TextStyle(
                  color: Color(0xFF8E95A5),
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              // Quick minute presets
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMinutePresetChip(':00', 0),
                  const SizedBox(width: 8),
                  _buildMinutePresetChip(':15', 15),
                  const SizedBox(width: 8),
                  _buildMinutePresetChip(':30', 30),
                  const SizedBox(width: 8),
                  _buildMinutePresetChip(':45', 45),
                ],
              ),
              const SizedBox(height: 6),
            ],

            const SizedBox(height: 20),

            // 3. Action Buttons (Cancel & Done)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF282D37),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF3B4150), width: 1),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF8E95A5),
                          fontSize: 13.5,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _confirm,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFA6144),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFA6144).withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Ketik Mode: Single Unified Time Display (Typing + Scrolling) ---
  Widget _buildKetikTimeCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildInteractiveTimeBox(
          controller: _hourController,
          focusNode: _hourFocus,
          label: 'HOUR',
          onDragUpdate: _handleHourDrag,
          onPointerSignal: _handleHourPointerSignal,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            ':',
            style: TextStyle(
              color: Color(0xFF8E95A5),
              fontSize: 32,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
        ),
        _buildInteractiveTimeBox(
          controller: _minuteController,
          focusNode: _minuteFocus,
          label: 'MINUTE',
          onDragUpdate: _handleMinuteDrag,
          onPointerSignal: _handleMinutePointerSignal,
        ),
      ],
    );
  }

  Widget _buildInteractiveTimeBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required Function(double) onDragUpdate,
    required Function(PointerSignalEvent) onPointerSignal,
  }) {
    final isFocused = focusNode.hasFocus;

    return Listener(
      onPointerSignal: onPointerSignal,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) => onDragUpdate(details.delta.dy),
        onVerticalDragEnd: (_) {
          _hourDragAccumulator = 0.0;
          _minuteDragAccumulator = 0.0;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF282D37),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFocused ? const Color(0xFFFA6144) : const Color(0xFF3B4150),
                  width: isFocused ? 1.5 : 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: TextField(
                key: ValueKey('${label.toLowerCase()}_text_field'),
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isFocused ? const Color(0xFFFA6144) : Colors.white,
                  fontSize: 34,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (text) {
                  final val = int.tryParse(text.trim());
                  if (val != null) {
                    if (label == 'HOUR' && val >= 0 && val <= 23) {
                      _hour = val;
                      if (text.trim().length == 2 && focusNode.hasFocus) {
                        _minuteFocus.requestFocus();
                      }
                    } else if (label == 'MINUTE' && val >= 0 && val <= 59) {
                      _minute = val;
                    }
                  }
                },
                onTap: () {
                  focusNode.requestFocus();
                  controller.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: controller.text.length,
                  );
                },
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isFocused ? const Color(0xFFFA6144) : const Color(0xFF8E95A5),
                fontSize: 10.5,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dial Mode: Time Display Header ---
  Widget _buildDialTimeHeader(String hourStr, String minuteStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Hour Card
        _buildDialTimeCard(
          title: 'HOUR',
          value: hourStr,
          isSelected: _isPickingHour,
          onTap: () => setState(() => _isPickingHour = true),
          onDragUpdate: _handleHourDrag,
          onPointerSignal: _handleHourPointerSignal,
        ),
        // Separator
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            ':',
            style: TextStyle(
              color: Color(0xFF8E95A5),
              fontSize: 32,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
        ),
        // Minute Card
        _buildDialTimeCard(
          title: 'MINUTE',
          value: minuteStr,
          isSelected: !_isPickingHour,
          onTap: () => setState(() => _isPickingHour = false),
          onDragUpdate: _handleMinuteDrag,
          onPointerSignal: _handleMinutePointerSignal,
        ),
      ],
    );
  }

  Widget _buildDialTimeCard({
    required String title,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
    Function(double)? onDragUpdate,
    Function(PointerSignalEvent)? onPointerSignal,
  }) {
    return Listener(
      onPointerSignal: onPointerSignal,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onVerticalDragUpdate: onDragUpdate != null ? (details) => onDragUpdate(details.delta.dy) : null,
        onVerticalDragEnd: (_) {
          _hourDragAccumulator = 0.0;
          _minuteDragAccumulator = 0.0;
        },
        child: Column(
          children: [
            Container(
              width: 86,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF282D37),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF3B4150),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFA6144) : Colors.white,
                  fontSize: 34,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF8E95A5),
                fontSize: 10.5,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dial ("Roda") Section ---
  Widget _buildDialSection() {
    return Column(
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: GestureDetector(
            onPanStart: (details) => _handleDialTouch(details.localPosition),
            onPanUpdate: (details) => _handleDialTouch(details.localPosition),
            onTapUp: (details) => _handleDialTouch(details.localPosition, isTap: true),
            child: CustomPaint(
              size: const Size(220, 220),
              painter: _ClockDialPainter(
                hour: _hour,
                minute: _minute,
                isPickingHour: _isPickingHour,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isPickingHour
              ? 'Select Hour (Inner: 01-12, Outer: 13-00)'
              : 'Select Minute (Tap or drag dial)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8E95A5),
            fontSize: 10.5,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  void _handleDialTouch(Offset localPos, {bool isTap = false}) {
    const center = Offset(110, 110);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);

    // Angle 0 degrees at top (12 o'clock), moving clockwise
    final rad = math.atan2(dx, -dy);
    var deg = rad * (180 / math.pi);
    if (deg < 0) deg += 360;

    if (_isPickingHour) {
      // 12 hours steps = 30 deg per step
      final step = ((deg / 30).round()) % 12;

      int selectedHour;
      if (dist < 68) {
        // Inner ring: 01 - 12
        selectedHour = step == 0 ? 12 : step;
      } else {
        // Outer ring: 13 - 23, 00
        selectedHour = step == 0 ? 0 : step + 12;
      }

      _updateHour(selectedHour);

      if (isTap) {
        // Smoothly advance to minutes on deliberate tap
        Future.delayed(const Duration(milliseconds: 240), () {
          if (mounted) {
            setState(() => _isPickingHour = false);
          }
        });
      }
    } else {
      // 60 minutes steps = 6 deg per step
      final selectedMinute = ((deg / 6).round()) % 60;
      _updateMinute(selectedMinute);
    }
  }

  Widget _buildMinutePresetChip(String label, int minuteVal) {
    final isSelected = _minute == minuteVal;
    return InkWell(
      onTap: () => _updateMinute(minuteVal),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF282D37),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF3B4150),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF8E95A5),
            fontSize: 11.5,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the 24-hour clock face dial.
class _ClockDialPainter extends CustomPainter {
  final int hour;
  final int minute;
  final bool isPickingHour;

  const _ClockDialPainter({
    required this.hour,
    required this.minute,
    required this.isPickingHour,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Dial Background Circle (Matches surrounding dialog soft grey)
    final bgPaint = Paint()
      ..color = const Color(0xFF282D37)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF3B4150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, borderPaint);

    if (isPickingHour) {
      _paintHours(canvas, center);
    } else {
      _paintMinutes(canvas, center);
    }

    // Center hub point
    final hubPaint = Paint()..color = const Color(0xFFFA6144);
    canvas.drawCircle(center, 3.5, hubPaint);
  }

  void _paintHours(Canvas canvas, Offset center) {
    const outerR = 86.0;
    const innerR = 56.0;

    // Identify position of current selected hour
    final isInner = hour >= 1 && hour <= 12;
    final activeRadius = isInner ? innerR : outerR;
    final activeStep = isInner ? (hour % 12) : ((hour - 12) % 12);
    final activeAngle = activeStep * 30.0 * (math.pi / 180.0);
    final activeTarget = Offset(
      center.dx + activeRadius * math.sin(activeAngle),
      center.dy - activeRadius * math.cos(activeAngle),
    );

    // Pointer line from center to selected hour circle
    final pointerPaint = Paint()
      ..color = const Color(0xFFFA6144)
      ..strokeWidth = 2.0;
    canvas.drawLine(center, activeTarget, pointerPaint);

    // Selected highlight circle
    final activeCirclePaint = Paint()
      ..color = const Color(0xFFFA6144)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(activeTarget, 14.0, activeCirclePaint);

    // Paint Outer Ring: 00, 13..23
    for (int i = 0; i < 12; i++) {
      final h = i == 0 ? 0 : i + 12;
      final angle = i * 30.0 * (math.pi / 180.0);
      final pos = Offset(
        center.dx + outerR * math.sin(angle),
        center.dy - outerR * math.cos(angle),
      );
      final isSelected = hour == h;
      _drawCenteredText(
        canvas: canvas,
        text: h.toString().padLeft(2, '0'),
        center: pos,
        color: isSelected ? Colors.white : const Color(0xFFC5C9D3),
        fontSize: 12.0,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      );
    }

    // Paint Inner Ring: 12, 1..11
    for (int i = 0; i < 12; i++) {
      final h = i == 0 ? 12 : i;
      final angle = i * 30.0 * (math.pi / 180.0);
      final pos = Offset(
        center.dx + innerR * math.sin(angle),
        center.dy - innerR * math.cos(angle),
      );
      final isSelected = hour == h;
      _drawCenteredText(
        canvas: canvas,
        text: h.toString().padLeft(2, '0'),
        center: pos,
        color: isSelected ? Colors.white : const Color(0xFF8E95A5),
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
      );
    }
  }

  void _paintMinutes(Canvas canvas, Offset center) {
    const r = 84.0;
    final activeAngle = minute * 6.0 * (math.pi / 180.0);
    final activeTarget = Offset(
      center.dx + r * math.sin(activeAngle),
      center.dy - r * math.cos(activeAngle),
    );

    // Pointer line from center to selected minute
    final pointerPaint = Paint()
      ..color = const Color(0xFFFA6144)
      ..strokeWidth = 2.0;
    canvas.drawLine(center, activeTarget, pointerPaint);

    // Selected highlight circle
    final activeCirclePaint = Paint()
      ..color = const Color(0xFFFA6144)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(activeTarget, 14.0, activeCirclePaint);

    // Draw 5-minute interval numbers (00, 05, 10 ... 55)
    for (int i = 0; i < 60; i += 5) {
      final angle = i * 6.0 * (math.pi / 180.0);
      final pos = Offset(
        center.dx + r * math.sin(angle),
        center.dy - r * math.cos(angle),
      );
      final isSelected = minute == i;
      _drawCenteredText(
        canvas: canvas,
        text: i.toString().padLeft(2, '0'),
        center: pos,
        color: isSelected ? Colors.white : const Color(0xFFC5C9D3),
        fontSize: 12.0,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      );
    }
  }

  void _drawCenteredText({
    required Canvas canvas,
    required String text,
    required Offset center,
    required Color color,
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: 'Inter',
          fontWeight: fontWeight,
          height: 1.0,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      center.dx - (tp.width / 2.0),
      center.dy - (tp.height / 2.0),
    );
    tp.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _ClockDialPainter oldDelegate) {
    return oldDelegate.hour != hour ||
        oldDelegate.minute != minute ||
        oldDelegate.isPickingHour != isPickingHour;
  }
}
