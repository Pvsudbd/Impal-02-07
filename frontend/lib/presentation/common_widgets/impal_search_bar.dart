import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_context.dart';

/// Reusable dark-themed Search Bar conforming to the sleek IMPAL Design System.
/// Features a leading search icon, clear button when text is typed, and responsive styling.
class ImpalSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String initialValue;
  final FocusNode? focusNode;
  final Key? inputKey;

  const ImpalSearchBar({
    super.key,
    this.hintText = 'Search...',
    required this.onChanged,
    this.onClear,
    this.initialValue = '',
    this.focusNode,
    this.inputKey,
  });

  @override
  State<ImpalSearchBar> createState() => _ImpalSearchBarState();
}

class _ImpalSearchBarState extends State<ImpalSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _internalFocusNode;
  bool _hasFocus = false;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _internalFocusNode = FocusNode();
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted && _hasFocus != _effectiveFocusNode.hasFocus) {
      setState(() {
        _hasFocus = _effectiveFocusNode.hasFocus;
      });
    }
  }

  @override
  void didUpdateWidget(covariant ImpalSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;

    return Container(
      height: 44,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF323846),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasFocus
              ? AppColors.primary
              : const Color(0xFF3B4150),
          width: _hasFocus ? 1.4 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 12),
          const Icon(
            Icons.search_rounded,
            color: Color(0xFF8E95A5),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: widget.inputKey,
              controller: _controller,
              focusNode: _effectiveFocusNode,
              onChanged: (val) {
                widget.onChanged(val);
                setState(() {});
              },
              style: TextStyle(
                color: Colors.white,
                fontSize: context.rFont(13.5, min: 12, max: 15),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: const Color(0xFF8E95A5),
                  fontSize: context.rFont(13, min: 11.5, max: 14.5),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (hasText)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _handleClear,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Icon(
                    Icons.close_rounded,
                    color: Color(0xFF8E95A5),
                    size: 18,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}

