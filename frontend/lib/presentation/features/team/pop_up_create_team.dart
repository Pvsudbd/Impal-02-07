import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_context.dart';
import '../../../core/widgets/unfocus_on_tap.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import '../smart_system/models/course_rubric_repository.dart';

/// Aliases for backwards compatibility with Figma export & routes
typedef FormCreateTeam = PopUpCreateTeam;

/// Result returned when a team is successfully created
class CreateTeamResult {
  final String name;
  final String description;
  final String inviteCode;
  final String? rubricCourseId;
  final String? rubricComponentId;

  const CreateTeamResult({
    required this.name,
    this.description = '',
    required this.inviteCode,
    this.rubricCourseId,
    this.rubricComponentId,
  });
}

/// Unified Create Team modal dialog for both Mobile and Desktop.
///
/// Combines FigCraft `Modal - Create Team (Pop-Up)` (node `7122`) card polish
/// with mobile `PopUpCreateTeam` wording & layout: Title Case labels,
/// `Team Invite Code` with top-right `Generate New` refresh action, icon-only
/// copy button, no member quota selector, and no redundant Cancel button.
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
  String? _selectedCourseId;
  String? _selectedComponentId;
  bool _isCopied = false;
  Timer? _copyTimer;

  @override
  void initState() {
    super.initState();
    CourseRubricRepository().init();
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

    if (_selectedCourseId != null && _selectedComponentId != null) {
      CourseRubricRepository().assignComponentToTeam(
        courseId: _selectedCourseId!,
        componentId: _selectedComponentId!,
        teamId: _inviteCode,
        teamName: name,
      );
    }

    final result = CreateTeamResult(
      name: name,
      description: _descController.text.trim(),
      inviteCode: _inviteCode,
      rubricCourseId: _selectedCourseId,
      rubricComponentId: _selectedComponentId,
    );

    widget.onCreated?.call(result);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final horizontalPad = isMobile ? 18.0 : 28.0;
    final verticalPad = isMobile ? 18.0 : 24.0;
    final sectionGap = isMobile ? 14.0 : 16.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 20 : 24,
      ),
      child: UnfocusOnTap(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isMobile ? 360 : 480),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPad,
              vertical: verticalPad,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
              boxShadow: const [
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
                  _buildHeaderRow(context),
                  SizedBox(height: sectionGap),
                  _buildFieldLabel(context, 'Team Name'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Enter team name',
                    maxLength: 50,
                  ),
                  SizedBox(height: sectionGap),
                  _buildFieldLabel(context, 'Description (Optional)'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _descController,
                    hint: 'Write a description here',
                    maxLength: 250,
                    maxLines: 3,
                  ),
                  SizedBox(height: sectionGap),
                  _buildInviteCodeHeader(context),
                  const SizedBox(height: 6),
                  _buildInviteCodeBox(context),
                  SizedBox(height: sectionGap),
                  _buildRubricLinkSection(context),
                  SizedBox(height: isMobile ? 18 : 22),
                  SizedBox(
                    width: double.infinity,
                    height: isMobile ? 44 : 46,
                    child: ElevatedButton(
                      key: const ValueKey('create_team_submit_button'),
                      onPressed: _handleCreate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.buttonLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(14.5, min: 13.5, max: 15.5),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Create Team',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(20, min: 18, max: 22),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            key: const ValueKey('close_create_team_button'),
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop();
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white,
        fontSize: context.rFont(13.5, min: 12.5, max: 14.5),
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLength,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      buildCounter: (
        context, {
        required currentLength,
        required isFocused,
        required maxLength,
      }) =>
          null,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13.5,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: AppColors.bgPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildInviteCodeHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: _buildFieldLabel(context, 'Team Invite Code'),
        ),
        const SizedBox(width: 8),
        InkWell(
          key: const ValueKey('generate_new_code_button'),
          onTap: _generateNewCode,
          borderRadius: BorderRadius.circular(6),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sync_rounded,
                  color: AppColors.primary,
                  size: 15,
                ),
                SizedBox(width: 4),
                Text(
                  'Generate New',
                  style: TextStyle(
                    color: AppColors.primary,
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
    );
  }

  Widget _buildInviteCodeBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.vpn_key_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _inviteCode,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Tooltip(
            message: _isCopied ? 'Copied!' : 'Copy invite code',
            child: Material(
              color: const Color(0x33FA6144),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                key: const ValueKey('copy_invite_code_button'),
                onTap: _copyInviteCode,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary, width: 0.75),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ),
              ),
            ),
          ),
                ],
      ),
    );
  }

  Widget _buildRubricLinkSection(BuildContext context) {
    final repo = CourseRubricRepository();
    final courses = repo.courses;
    final selectedCourse = repo.getCourseById(_selectedCourseId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFieldLabel(context, 'Course Grading Rubric (Optional)'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String?>(
          key: const ValueKey('create_team_rubric_course_dropdown'),
          initialValue: _selectedCourseId,
          isExpanded: true,
          dropdownColor: AppColors.bgCard,
          style: TextStyle(
            color: Colors.white,
            fontSize: context.rFont(13, min: 11.5, max: 14),
            fontFamily: 'Inter',
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgPrimary,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          hint: const Text(
            'Select Course (None)',
            style: TextStyle(color: AppColors.textSubtle),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('No Linked Course Rubric'),
            ),
            ...courses.map(
              (c) => DropdownMenuItem<String?>(
                value: c.id,
                child: Text(
                  c.displayLabel,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: (courseId) {
            setState(() {
              _selectedCourseId = courseId;
              final c = repo.getCourseById(courseId);
              _selectedComponentId = (c != null && c.components.isNotEmpty)
                  ? c.components.last.id
                  : null;
            });
          },
        ),
        if (selectedCourse != null && selectedCourse.components.isNotEmpty) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            key: ValueKey('create_team_rubric_comp_${selectedCourse.id}'),
            initialValue: _selectedComponentId,
            isExpanded: true,
            dropdownColor: AppColors.bgCard,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(13, min: 11.5, max: 14),
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.bgPrimary,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            items: selectedCourse.components
                .map(
                  (comp) => DropdownMenuItem<String?>(
                    value: comp.id,
                    child: Text('${comp.name} (${comp.weightPercent}%)'),
                  ),
                )
                .toList(),
            onChanged: (compId) {
              setState(() => _selectedComponentId = compId);
            },
          ),
        ],
      ],
    );
  }
}
