import 'package:flutter/material.dart';

enum _DatePickerView { day, month, year }

/// Opens the bespoke IMPAL 24-hour styled Date Picker Dialog.
///
/// Features:
/// - Eliminates the large top "day, month, date" banner for a clean minimalist aesthetic.
/// - Allows switching directly to Month picker by tapping the month button.
/// - Allows switching directly to Year picker by tapping the year button.
/// - Harmonized dark slate grey surfaces [Color(0xFF282D37)] and soft borders [Color(0xFF3B4150)].
/// - Accent color [Color(0xFFFA6144)] on selected day/month/year and confirm action.
Future<DateTime?> showImpalDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = 'Select Date',
}) async {
  return showDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (context) => ImpalDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2035),
      title: title,
    ),
  );
}

class ImpalDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  const ImpalDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.title = 'Select Date',
  });

  @override
  State<ImpalDatePickerDialog> createState() => _ImpalDatePickerDialogState();
}

class _ImpalDatePickerDialogState extends State<ImpalDatePickerDialog> {
  late DateTime _selectedDate;
  late DateTime _viewDate;
  _DatePickerView _currentView = _DatePickerView.day;

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _viewDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      1,
    );
  }

  void _onPrevMonth() {
    setState(() {
      if (_currentView == _DatePickerView.year) {
        final newYear = (_viewDate.year - 12).clamp(widget.firstDate.year, widget.lastDate.year);
        _viewDate = DateTime(newYear, _viewDate.month, 1);
      } else {
        final prev = DateTime(_viewDate.year, _viewDate.month - 1, 1);
        if (!prev.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month, 1))) {
          _viewDate = prev;
        }
      }
    });
  }

  void _onNextMonth() {
    setState(() {
      if (_currentView == _DatePickerView.year) {
        final newYear = (_viewDate.year + 12).clamp(widget.firstDate.year, widget.lastDate.year);
        _viewDate = DateTime(newYear, _viewDate.month, 1);
      } else {
        final next = DateTime(_viewDate.year, _viewDate.month + 1, 1);
        if (!next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month, 1))) {
          _viewDate = next;
        }
      }
    });
  }

  void _confirm() {
    Navigator.of(context).pop(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 334,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF282D37),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF3B4150),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header: Title only (No day-month-date banner)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  onTap: () {
                    final today = DateTime.now();
                    setState(() {
                      _selectedDate = DateTime(today.year, today.month, today.day);
                      _viewDate = DateTime(today.year, today.month, 1);
                      _currentView = _DatePickerView.day;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282D37),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF3B4150)),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        color: Color(0xFFFA6144),
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Month & Year Selector Controls
            _buildMonthYearBar(),
            const SizedBox(height: 12),

            // Main Body: Day Calendar, Month Selector, or Year Selector
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 236, maxHeight: 236),
              child: _buildCurrentView(),
            ),
            const SizedBox(height: 16),

            // Bottom Actions: Cancel & Done
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(null),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF282D37),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF3B4150),
                          width: 1.0,
                        ),
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

  Widget _buildMonthYearBar() {
    final monthName = _months[_viewDate.month - 1];
    final yearStr = '${_viewDate.year}';
    final isMonthActive = _currentView == _DatePickerView.month;
    final isYearActive = _currentView == _DatePickerView.year;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          // Seamless Month & Year title: "October 2026"
          InkWell(
            key: const ValueKey('month_selector_button'),
            onTap: () {
              setState(() {
                _currentView = isMonthActive ? _DatePickerView.day : _DatePickerView.month;
              });
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                monthName,
                style: TextStyle(
                  color: isMonthActive ? const Color(0xFFFA6144) : Colors.white,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  decoration: isMonthActive ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: const Color(0xFFFA6144),
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            key: const ValueKey('year_selector_button'),
            onTap: () {
              setState(() {
                _currentView = isYearActive ? _DatePickerView.day : _DatePickerView.year;
              });
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                yearStr,
                style: TextStyle(
                  color: isYearActive ? const Color(0xFFFA6144) : Colors.white,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  decoration: isYearActive ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: const Color(0xFFFA6144),
                ),
              ),
            ),
          ),
          const Spacer(),

          // Previous Month Arrow
          InkWell(
            key: const ValueKey('prev_month_button'),
            onTap: _onPrevMonth,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: const Icon(
                Icons.chevron_left,
                size: 22,
                color: Color(0xFF8E95A5),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Next Month Arrow
          InkWell(
            key: const ValueKey('next_month_button'),
            onTap: _onNextMonth,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: const Icon(
                Icons.chevron_right,
                size: 22,
                color: Color(0xFF8E95A5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case _DatePickerView.day:
        return _buildDayCalendar();
      case _DatePickerView.month:
        return _buildMonthGrid();
      case _DatePickerView.year:
        return _buildYearGrid();
    }
  }

  // --- 1. Day Calendar View ---
  Widget _buildDayCalendar() {
    final firstDayOfMonth = DateTime(_viewDate.year, _viewDate.month, 1);
    final daysInMonth = DateTime(_viewDate.year, _viewDate.month + 1, 0).day;
    // Monday = 1, Sunday = 7 -> leading empty cells:
    final leadingEmpty = firstDayOfMonth.weekday - 1;
    final totalCells = leadingEmpty + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    final today = DateTime.now();

    return Column(
      children: [
        // Weekday Headers
        Row(
          children: _weekdays.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    color: Color(0xFF8E95A5),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Day Grid
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(rowCount, (rowIndex) {
              return Row(
                children: List.generate(7, (colIndex) {
                  final cellIndex = rowIndex * 7 + colIndex;
                  final dayNumber = cellIndex - leadingEmpty + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 28));
                  }

                  final isSelected = _selectedDate.year == _viewDate.year &&
                      _selectedDate.month == _viewDate.month &&
                      _selectedDate.day == dayNumber;

                  final isToday = today.year == _viewDate.year &&
                      today.month == _viewDate.month &&
                      today.day == dayNumber;

                  return Expanded(
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDate = DateTime(_viewDate.year, _viewDate.month, dayNumber);
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 29,
                          height: 29,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? const Color(0xFFFA6144) : Colors.transparent,
                            border: isToday && !isSelected
                                ? Border.all(color: const Color(0xFFFA6144), width: 1.2)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
                              fontSize: 12.5,
                              fontFamily: 'Inter',
                              fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }

  // --- 2. Month Selector Grid ---
  Widget _buildMonthGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final monthNumber = index + 1;
        final monthName = _shortMonths[index];
        final isSelected = _viewDate.month == monthNumber;

        return InkWell(
          onTap: () {
            setState(() {
              _viewDate = DateTime(_viewDate.year, monthNumber, 1);
              // Also update selectedDate month to keep in sync if in current year
              _selectedDate = DateTime(
                _selectedDate.year,
                monthNumber,
                _selectedDate.day.clamp(1, DateTime(_selectedDate.year, monthNumber + 1, 0).day),
              );
              _currentView = _DatePickerView.day;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF282D37),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF3B4150),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              monthName,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8E95A5),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  // --- 3. Year Selector Grid ---
  Widget _buildYearGrid() {
    final startYear = widget.firstDate.year;
    final endYear = widget.lastDate.year;
    final years = List.generate(endYear - startYear + 1, (i) => startYear + i);

    return GridView.builder(
      itemCount: years.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = _viewDate.year == year;

        return InkWell(
          onTap: () {
            setState(() {
              _viewDate = DateTime(year, _viewDate.month, 1);
              // Also update selectedDate year
              _selectedDate = DateTime(
                year,
                _selectedDate.month,
                _selectedDate.day.clamp(1, DateTime(year, _selectedDate.month + 1, 0).day),
              );
              _currentView = _DatePickerView.day;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF282D37),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? const Color(0xFFFA6144) : const Color(0xFF3B4150),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$year',
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8E95A5),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}
