import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../../core/widgets/unfocus_on_tap.dart';
import '../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../schedule/pop_up_konfirmasi_delete.dart';
import '../models/tag_model.dart';
import '../models/tag_repository.dart';

/// Unified modal dialog to create a new Custom Task Tag with color preset.
/// Used across Mobile & Desktop Home Categories AND inline inside Task/Team Forms.
class AddCustomTagDialog extends StatefulWidget {
  const AddCustomTagDialog({super.key});

  static Future<CustomTagModel?> show(BuildContext context) {
    return showDialog<CustomTagModel>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => const AddCustomTagDialog(),
    );
  }

  @override
  State<AddCustomTagDialog> createState() => _AddCustomTagDialogState();
}

class _AddCustomTagDialogState extends State<AddCustomTagDialog> {
  final TextEditingController _nameController = TextEditingController();
  TagColorPreset _selectedPreset = TagColorPreset.presets.first;
  String? _errorText;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _close([CustomTagModel? result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(result);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final res = await TaskTagRepository().addTag(
      label: _nameController.text,
      colorPreset: _selectedPreset,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!res.success || res.tag == null) {
      setState(() => _errorText = res.errorMessage ?? 'Unable to create tag.');
      PopUpPemberitahuan.show(
        context,
        title: 'Tag Not Added',
        message: res.errorMessage ?? 'Invalid tag name.',
        icon: Icons.warning_amber_rounded,
        iconBgColor: PopUpPemberitahuan.negativeColor,
      );
      return;
    }

    PopUpPemberitahuan.show(
      context,
      title: 'Tag Added',
      message: 'Tag "${res.tag!.label}" is ready across Home filters & Task forms.',
      icon: Icons.label_outline_rounded,
      iconBgColor: PopUpPemberitahuan.positiveColor,
    );
    _close(res.tag);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(20),
        vertical: context.rSpacing(24),
      ),
      child: UnfocusOnTap(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: EdgeInsets.all(context.rSpacing(22)),
            decoration: BoxDecoration(
              color: AppColors.bgDialog,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add Custom Tag',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(17, min: 15, max: 19),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: const ValueKey('add_tag_modal_close_btn'),
                          onTap: () => _close(),
                          borderRadius: BorderRadius.circular(10),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close_rounded,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.rSpacing(12)),
                  Text(
                    'Tag Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(13, min: 11.5, max: 14.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.rSpacing(6)),
                  TextField(
                    key: const ValueKey('custom_tag_name_input'),
                    controller: _nameController,
                    maxLength: 24,
                    onChanged: (_) {
                      if (_errorText != null) setState(() => _errorText = null);
                    },
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(13, min: 11.5, max: 14.5),
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Organization, Sprint, Exam',
                      hintStyle: const TextStyle(color: AppColors.textSubtle),
                      counterStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                      errorText: _errorText,
                      filled: true,
                      fillColor: AppColors.bgCard,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: context.rSpacing(14),
                        vertical: context.rSpacing(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.rSpacing(12)),
                  Text(
                    'Tag Color',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(13, min: 11.5, max: 14.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.rSpacing(8)),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: TagColorPreset.presets.map((preset) {
                      final isSelected = _selectedPreset.id == preset.id;
                      return InkWell(
                        key: ValueKey('tag_color_${preset.id}'),
                        onTap: () => setState(() => _selectedPreset = preset),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: preset.backgroundColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: preset.textColor,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: context.rSpacing(20)),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      key: const ValueKey('confirm_add_custom_tag_btn'),
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSubmitting) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          const Flexible(
                            child: Text(
                              'Add Tag',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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
}

Future<void> _confirmAndDeleteTag(
  BuildContext context, {
  required CustomTagModel tag,
  VoidCallback? onDeleted,
}) async {
  final confirmed = await PopUpKonfirmasiDelete.show(
    context,
    title: 'Delete Tag?',
    message:
        'Remove tag "${tag.label}" from quick filters & task forms? Existing tasks keep their label.',
  );
  if (confirmed == true) {
    await TaskTagRepository().deleteTag(tag.id);
    onDeleted?.call();
    if (context.mounted) {
      PopUpPemberitahuan.show(
        context,
        title: 'Tag Deleted',
        message: 'Tag "${tag.label}" removed.',
        icon: Icons.delete_outline_rounded,
        iconBgColor: PopUpPemberitahuan.negativeColor,
      );
    }
  }
}

/// Shared multi-select Task Tag selector used inside Personal/College Task forms
/// (`CreateTaskPage`, `DesktopPersonalTaskModal`) AND Team Task forms
/// (`CreateTaskTeamPage`, `DesktopTeamTaskModal`).
/// Supports deleting any existing tag: via `✕` icon on Desktop, or long-press on Mobile.
class TaskTagSelectorSection extends StatelessWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onTagsChanged;
  final bool darkSurface;

  const TaskTagSelectorSection({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
    this.darkSurface = false,
  });

  void _toggleTag(String label) {
    final lower = label.toLowerCase();
    final exists = selectedTags.any((t) => t.toLowerCase() == lower);
    if (exists) {
      onTagsChanged(
        selectedTags.where((t) => t.toLowerCase() != lower).toList(),
      );
    } else {
      onTagsChanged([...selectedTags, label]);
    }
  }

  void _handleDeleteTag(BuildContext context, CustomTagModel tag) {
    _confirmAndDeleteTag(
      context,
      tag: tag,
      onDeleted: () {
        final lower = tag.label.toLowerCase();
        if (selectedTags.any((t) => t.toLowerCase() == lower)) {
          onTagsChanged(
            selectedTags.where((t) => t.toLowerCase() != lower).toList(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return ListenableBuilder(
      listenable: TaskTagRepository(),
      builder: (context, _) {
        final tags = TaskTagRepository().tags;
        final pillBg = darkSurface ? AppColors.bgPrimary : AppColors.bgCard;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tags (Optional)',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: context.rFont(13, min: 11, max: 15),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isDesktop)
                  Flexible(
                    child: Text(
                      'Hold tag to delete',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.rFont(10.5, min: 9.5, max: 11.5),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: context.rSpacing(8)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...tags.map((tag) {
                  final isSelected = selectedTags.any(
                    (s) => s.toLowerCase() == tag.label.toLowerCase(),
                  );
                  return InkWell(
                    key: ValueKey('task_tag_option_${tag.id}'),
                    onTap: () => _toggleTag(tag.label),
                    onLongPress: !isDesktop
                        ? () => _handleDeleteTag(context, tag)
                        : null,
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.only(
                        left: 11,
                        right: isDesktop ? 7 : 11,
                        top: 7,
                        bottom: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? tag.backgroundColor : pillBg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? tag.backgroundColor
                              : AppColors.borderSubtle,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? tag.textColor
                                  : tag.backgroundColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tag.label,
                            style: TextStyle(
                              color: isSelected
                                  ? tag.textColor
                                  : AppColors.textBody,
                              fontSize: context.rFont(11.5, min: 10.5, max: 13),
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          if (isDesktop) ...[
                            const SizedBox(width: 5),
                            InkWell(
                              key: ValueKey('task_tag_delete_${tag.id}'),
                              onTap: () => _handleDeleteTag(context, tag),
                              borderRadius: BorderRadius.circular(999),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 13,
                                  color: isSelected
                                      ? tag.textColor.withValues(alpha: 0.85)
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                InkWell(
                  key: const ValueKey('task_form_add_tag_btn'),
                  onTap: () async {
                    final created = await AddCustomTagDialog.show(context);
                    if (created != null) {
                      onTagsChanged([...selectedTags, created.label]);
                    }
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          size: 14,
                          color: AppColors.primaryAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'New Tag',
                          style: TextStyle(
                            color: AppColors.primaryAccent,
                            fontSize: context.rFont(11.5, min: 10.5, max: 13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Shared Tag Filter Strip with optional custom-tag deletion & inline `+ Add Tag`
/// used on Mobile Home, Mobile `TaskPage`, and Desktop `DesktopTasksManagementView`.
class TagFilterStrip extends StatelessWidget {
  final String? selectedTag;
  final ValueChanged<String?> onTagSelected;
  final bool includeAllOption;
  final bool showAddButton;
  final bool scrollable;
  final List<Widget> leadingChips;

  const TagFilterStrip({
    super.key,
    required this.selectedTag,
    required this.onTagSelected,
    this.includeAllOption = false,
    this.showAddButton = false,
    this.scrollable = false,
    this.leadingChips = const [],
  });

  void _handleDeleteTag(BuildContext context, CustomTagModel tag) {
    _confirmAndDeleteTag(
      context,
      tag: tag,
      onDeleted: () {
        if (selectedTag?.toLowerCase() == tag.label.toLowerCase()) {
          onTagSelected(null);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return ListenableBuilder(
      listenable: TaskTagRepository(),
      builder: (context, _) {
        final tags = TaskTagRepository().tags;
        final chipWidgets = <Widget>[
          ...leadingChips,
          if (includeAllOption)
            InkWell(
              key: const ValueKey('tag_filter_all'),
              onTap: () => onTagSelected(null),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selectedTag == null
                      ? AppColors.primary.withValues(alpha: 0.18)
                      : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selectedTag == null
                        ? AppColors.primary
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Text(
                  'All Tags',
                  style: TextStyle(
                    color: selectedTag == null
                        ? Colors.white
                        : AppColors.textMuted,
                    fontSize: context.rFont(11, min: 10, max: 12.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ...tags.map((tag) {
            final isSelected =
                selectedTag?.toLowerCase() == tag.label.toLowerCase();
            return InkWell(
              key: ValueKey('tag_filter_chip_${tag.id}'),
              onTap: () => onTagSelected(isSelected ? null : tag.label),
              onLongPress:
                  !isDesktop ? () => _handleDeleteTag(context, tag) : null,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: isDesktop ? 6 : 10,
                  top: 6,
                  bottom: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? tag.backgroundColor.withValues(alpha: 0.25)
                      : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? tag.backgroundColor
                        : AppColors.borderSubtle,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: tag.backgroundColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tag.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textBody,
                        fontSize: context.rFont(11, min: 10, max: 12.5),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (isDesktop) ...[
                      const SizedBox(width: 4),
                      InkWell(
                        key: ValueKey('delete_custom_tag_${tag.id}'),
                        onTap: () => _handleDeleteTag(context, tag),
                        borderRadius: BorderRadius.circular(999),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.close_rounded,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          if (showAddButton)
            InkWell(
              key: const ValueKey('tag_strip_add_btn'),
              onTap: () async {
                final created = await AddCustomTagDialog.show(context);
                if (created != null) {
                  onTagSelected(created.label);
                }
              },
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: 13,
                      color: AppColors.primaryAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Add Tag',
                      style: TextStyle(
                        color: AppColors.primaryAccent,
                        fontSize: context.rFont(11, min: 10, max: 12),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ];

        if (scrollable) {
          return SingleChildScrollView(
            key: const ValueKey('tag_filter_horizontal_scroll'),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (int i = 0; i < chipWidgets.length; i++) ...[
                  chipWidgets[i],
                  if (i < chipWidgets.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: chipWidgets,
        );
      },
    );
  }
}
