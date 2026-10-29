import 'package:flutter/material.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';

/// Aliases for backwards compatibility with Figma export & routes
typedef JoinTeam = PopUpJoinTeam;

/// Pop up dialog for joining a team matching the Figma design
class PopUpJoinTeam extends StatefulWidget {
  final String initialCode;
  final ValueChanged<String>? onJoined;

  const PopUpJoinTeam({
    super.key,
    this.initialCode = '',
    this.onJoined,
  });

  /// Helper to show the Join Team popup as a modal dialog
  static Future<String?> show(
    BuildContext context, {
    String initialCode = '',
  }) {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => PopUpJoinTeam(
        initialCode: initialCode,
      ),
    );
  }

  @override
  State<PopUpJoinTeam> createState() => _PopUpJoinTeamState();
}

class _PopUpJoinTeamState extends State<PopUpJoinTeam> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleJoin() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      PopUpPemberitahuan.teamWarning(
        context,
        title: 'Invite Code Required',
        message: 'Please enter team invite code.',
      );
      return;
    }

    if (widget.onJoined != null) {
      widget.onJoined!(code);
    }

    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 352,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFF323846),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 30,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Flexible(
                  child: Text(
                    'Join Team',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.07,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  key: const ValueKey('close_join_team_button'),
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: ShapeDecoration(
                      color: const Color(0x33FA6144),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFFFA6144),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Enter Code Input Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: ShapeDecoration(
                color: const Color(0xFF282D37),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: TextField(
                controller: _codeController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter Code',
                  hintStyle: TextStyle(
                    color: Color(0xFF8E95A5),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (_) => _handleJoin(),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button ("Become Member")
            Material(
              color: Colors.transparent,
              child: InkWell(
                key: const ValueKey('join_team_submit_button'),
                onTap: _handleJoin,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFA6144),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Become Member',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
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
}