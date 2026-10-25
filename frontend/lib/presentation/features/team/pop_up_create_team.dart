import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';

/// Aliases for backwards compatibility with Figma export & routes
typedef FormCreateTeam = PopUpCreateTeam;

/// Result returned when a team is successfully created
class CreateTeamResult {
  final String name;
  final String description;
  final String inviteCode;

  const CreateTeamResult({
    required this.name,
    this.description = '',
    required this.inviteCode,
  });
}

/// Pop up dialog for creating a team matching the Figma design
class PopUpCreateTeam extends StatefulWidget {
  final String initialName;
  final String initialDescription;
  final String? initialCode;
  final String buttonLabel;
  final ValueChanged<CreateTeamResult>? onCreated;

  const PopUpCreateTeam({
    super.key,
    this.initialName = '',
    this.initialDescription = '',
    this.initialCode,
    this.buttonLabel = 'Create Team',
    this.onCreated,
  });

  /// Helper to show the Create Team popup as a modal dialog
  static Future<CreateTeamResult?> show(
    BuildContext context, {
    String initialName = '',
    String initialDescription = '',
    String? initialCode,
    String buttonLabel = 'Create Team',
  }) {
    return showDialog<CreateTeamResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => PopUpCreateTeam(
        initialName: initialName,
        initialDescription: initialDescription,
        initialCode: initialCode,
        buttonLabel: buttonLabel,
      ),
    );
  }

  @override
  State<PopUpCreateTeam> createState() => _PopUpCreateTeamState();
}

class _PopUpCreateTeamState extends State<PopUpCreateTeam> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late String _inviteCode;
  bool _isCopied = false;
  Timer? _copyTimer;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descController = TextEditingController(text: widget.initialDescription);
    _inviteCode = widget.initialCode ?? _generateRandomCode();
  }

  @override
  void dispose() {
    _copyTimer?.cancel();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _generateRandomCode() {
    const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  void _generateNewCode() {
    setState(() {
      _inviteCode = _generateRandomCode();
      _isCopied = false;
    });
  }

  void _copyInviteCode() {
    Clipboard.setData(ClipboardData(text: _inviteCode));
    setState(() => _isCopied = true);
    PopUpPemberitahuan.codeCopied(context, code: _inviteCode);

    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  void _handleCreate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      PopUpPemberitahuan.teamWarning(
        context,
        title: 'Team Name Required',
        message: 'Please enter team name.',
      );
      return;
    }

    final result = CreateTeamResult(
      name: name,
      description: _descController.text.trim(),
      inviteCode: _inviteCode,
    );

    if (widget.onCreated != null) {
      widget.onCreated!(result);
    }

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 352,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
        child: SingleChildScrollView(
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
                      'Create Team',
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
                    key: const ValueKey('close_create_team_button'),
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
              const SizedBox(height: 14),

              // Team Name Field
              const Text(
                'Team Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.75,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.20,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: ShapeDecoration(
                  color: const Color(0xFF282D37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Name meeting',
                    hintStyle: TextStyle(
                      color: Color(0xFF8E95A5),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Description (Optional)
              const Text(
                'Description (Optional)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.55,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.03,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: ShapeDecoration(
                  color: const Color(0xFF282D37),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFF282D37),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: TextField(
                  controller: _descController,
                  maxLines: 3,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write a description here',
                    hintStyle: TextStyle(
                      color: Color(0xFF8E95A5),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Team Invite Code
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Flexible(
                    child: Text(
                      'Team Invite Code',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.75,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    key: const ValueKey('generate_new_code_button'),
                    onTap: _generateNewCode,
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sync_rounded,
                            color: Color(0xFFFA6144),
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Generate New',
                            style: TextStyle(
                              color: Color(0xFFFA6144),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: ShapeDecoration(
                  color: const Color(0xFF282D37),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFFA6144),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.vpn_key_outlined,
                      color: Color(0xFFFA6144),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _inviteCode,
                        style: const TextStyle(
                          color: Color(0xFFFA6144),
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    InkWell(
                      key: const ValueKey('copy_invite_code_button'),
                      onTap: _copyInviteCode,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: ShapeDecoration(
                          color: const Color(0x33FA6144),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 0.50,
                              color: Color(0xFFFA6144),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          _isCopied ? 'Copied!' : 'Copy',
                          style: const TextStyle(
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
              ),
              const SizedBox(height: 20),

              // Submit Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('create_team_submit_button'),
                  onTap: _handleCreate,
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
                    child: Text(
                      widget.buttonLabel,
                      style: const TextStyle(
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
      ),
    );
  }
}