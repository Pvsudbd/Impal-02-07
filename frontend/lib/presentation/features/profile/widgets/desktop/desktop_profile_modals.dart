import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/page_transitions.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../../core/widgets/unfocus_on_tap.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../../auth/forgot_password_page.dart';
import '../../models/user_profile_model.dart';

/// Shared label builder for desktop profile modals.
class _ModalFieldLabel extends StatelessWidget {
  final String label;
  final Widget? trailing;

  const _ModalFieldLabel({
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Shared status pill inside desktop modal headers & field labels.
class _ModalPillBadge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;

  const _ModalPillBadge({
    required this.text,
    required this.bgColor,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(8),
        vertical: context.rSpacing(3),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: context.rIcon(11), color: textColor),
            SizedBox(width: context.rSpacing(4)),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: context.rFont(10.5, min: 9.5, max: 11.5),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _desktopModalInputDecoration(
  BuildContext context, {
  required String hint,
  Widget? suffixIcon,
  bool isLocked = false,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: AppColors.textMuted.withValues(alpha: 0.65),
      fontSize: context.rFont(13, min: 12, max: 14),
    ),
    filled: true,
    fillColor: isLocked
        ? AppColors.bgPrimary.withValues(alpha: 0.55)
        : AppColors.bgPrimary,
    contentPadding: EdgeInsets.symmetric(
      horizontal: context.rSpacing(14),
      vertical: context.rSpacing(12),
    ),
    counterText: '',
    suffixIcon: suffixIcon,
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
      borderSide: BorderSide(
        color: isLocked ? AppColors.borderSubtle : AppColors.primaryAccent,
        width: isLocked ? 1 : 1.4,
      ),
    ),
  );
}

/// Modal - Edit Profile (`FigCraft node 6182`, 520dp) + Mobile Camera/Gallery & Notice Banner.
class DesktopEditProfileModal extends StatefulWidget {
  final UserProfileModel profile;
  final BuildContext parentContext;
  final ValueChanged<UserProfileModel>? onSaved;

  const DesktopEditProfileModal({
    super.key,
    required this.profile,
    required this.parentContext,
    this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required UserProfileModel profile,
    ValueChanged<UserProfileModel>? onSaved,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => DesktopEditProfileModal(
        profile: profile,
        parentContext: context,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<DesktopEditProfileModal> createState() =>
      _DesktopEditProfileModalState();
}

class _DesktopEditProfileModalState extends State<DesktopEditProfileModal> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _studentIdController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _majorController;
  late final TextEditingController _groupRoleController;
  late final TextEditingController _bioController;

  bool _showPhotoSourcePicker = false;
  bool _hasCustomPhoto = false;
  bool _isSaving = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _studentIdController =
        TextEditingController(text: widget.profile.studentId);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _majorController = TextEditingController(text: widget.profile.majorCampus);
    _groupRoleController =
        TextEditingController(text: widget.profile.groupRole);
    _bioController = TextEditingController(text: widget.profile.bio);

    _fullNameController.addListener(() {
      if (mounted) {
        setState(() {
          if (_validationError != null) _validationError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _majorController.dispose();
    _groupRoleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String get _computedInitials {
    final parts = _fullNameController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'ST';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  void _selectPhotoSource() {
    setState(() {
      _hasCustomPhoto = true;
      _showPhotoSourcePicker = false;
    });
    if (widget.parentContext.mounted) {
      PopUpPemberitahuan.profilePictureUpdated(widget.parentContext);
    }
  }

  void _removePhoto() {
    setState(() {
      _hasCustomPhoto = false;
      _showPhotoSourcePicker = false;
    });
    if (widget.parentContext.mounted) {
      PopUpPemberitahuan.show(
        widget.parentContext,
        title: 'Photo Removed',
        message: 'Profile avatar reverted to student initials.',
        icon: Icons.account_circle_outlined,
        iconBgColor: PopUpPemberitahuan.negativeColor,
      );
    }
  }

  void _handleSave() {
    if (_isSaving) return;
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();

    if (fullName.isEmpty) {
      setState(() => _validationError = 'Full name cannot be empty.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _validationError = 'Please enter a valid SSO email.');
      return;
    }

    setState(() {
      _isSaving = true;
      _validationError = null;
    });

    final updated = widget.profile.copyWith(
      fullName: fullName,
      email: email,
      phoneNumber: _phoneController.text.trim(),
      majorCampus: _majorController.text.trim(),
      groupRole: _groupRoleController.text.trim(),
      bio: _bioController.text.trim(),
    );

    UserProfileRepository().updateProfile(updated);
    widget.onSaved?.call(updated);

    Navigator.of(context).pop();
    if (widget.parentContext.mounted) {
      PopUpPemberitahuan.profileUpdated(widget.parentContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(context.rSpacing(20)),
      child: UnfocusOnTap(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: maxHeight,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgSidebar,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(context.rSpacing(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvatarRow(context),
                        if (_showPhotoSourcePicker) ...[
                          SizedBox(height: context.rSpacing(12)),
                          _buildPhotoSourceChooser(context),
                        ],
                        SizedBox(height: context.rSpacing(18)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _ModalFieldLabel(label: 'Full Name'),
                                  SizedBox(height: context.rSpacing(6)),
                                  TextField(
                                    key: const Key('desktop_edit_fullname_field'),
                                    controller: _fullNameController,
                                    maxLength: 100,
                                    style: TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize:
                                          context.rFont(13.5, min: 12, max: 15),
                                    ),
                                    decoration: _desktopModalInputDecoration(
                                      context,
                                      hint: 'Yoga Perkasa Didik',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: context.rSpacing(12)),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _ModalFieldLabel(
                                    label: 'Student ID (Locked)',
                                    trailing: _ModalPillBadge(
                                      text: 'SSO Locked',
                                      bgColor: Color(0xFF282D37),
                                      textColor: AppColors.textMuted,
                                      icon: Icons.lock_outline_rounded,
                                    ),
                                  ),
                                  SizedBox(height: context.rSpacing(6)),
                                  TextField(
                                    key: const Key('desktop_edit_nim_field'),
                                    controller: _studentIdController,
                                    readOnly: true,
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize:
                                          context.rFont(13, min: 12, max: 14),
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                    decoration: _desktopModalInputDecoration(
                                      context,
                                      hint: '103072400106',
                                      isLocked: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.rSpacing(14)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _ModalFieldLabel(
                                    label: 'Campus Email (Official)',
                                    trailing: _ModalPillBadge(
                                      text: '✓ Verified',
                                      bgColor: Color(0xFF1F3D35),
                                      textColor: Color(0xFF4EB089),
                                    ),
                                  ),
                                  SizedBox(height: context.rSpacing(6)),
                                  TextField(
                                    key: const Key('desktop_edit_email_field'),
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    maxLength: 120,
                                    style: TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize:
                                          context.rFont(13, min: 12, max: 14),
                                    ),
                                    decoration: _desktopModalInputDecoration(
                                      context,
                                      hint:
                                          'yogaperkasa@student.telkomuniversity.ac.id',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: context.rSpacing(12)),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _ModalFieldLabel(
                                      label: 'WhatsApp / Mobile Number'),
                                  SizedBox(height: context.rSpacing(6)),
                                  TextField(
                                    key: const Key('desktop_edit_phone_field'),
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 20,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9+\-\s]'),
                                      ),
                                    ],
                                    style: TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize:
                                          context.rFont(13, min: 12, max: 14),
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                    decoration: _desktopModalInputDecoration(
                                      context,
                                      hint: '+62 812-3456-7890',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.rSpacing(14)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _ModalFieldLabel(
                                      label: 'Study Program & Faculty'),
                                  SizedBox(height: context.rSpacing(6)),
                                  TextField(
                                    key: const Key('desktop_edit_major_field'),
                                    controller: _majorController,
                                    maxLength: 120,
                                    style: TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize:
                                          context.rFont(13, min: 12, max: 14),
                                    ),
                                    decoration: _desktopModalInputDecoration(
                                      context,
                                      hint:
                                          'S1 Informatika • Telkom University Surabaya',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: context.rSpacing(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _ModalFieldLabel(
                                      label: 'Team & Project Role'),
                                  SizedBox(height: context.rSpacing(6)),
                                  TextField(
                                    key: const Key('desktop_edit_role_field'),
                                    controller: _groupRoleController,
                                    maxLength: 120,
                                    style: TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize:
                                          context.rFont(13, min: 12, max: 14),
                                    ),
                                    decoration: _desktopModalInputDecoration(
                                      context,
                                      hint: 'Kelompok 7 IMPAL (Lead Architect)',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.rSpacing(14)),
                        const _ModalFieldLabel(label: 'Status / Bio'),
                        SizedBox(height: context.rSpacing(6)),
                        TextField(
                          key: const Key('desktop_edit_bio_field'),
                          controller: _bioController,
                          maxLines: 2,
                          maxLength: 200,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: context.rFont(13, min: 12, max: 14),
                          ),
                          decoration: _desktopModalInputDecoration(
                            context,
                            hint:
                                'Informatics Engineering student focused on Flutter & AI systems.',
                          ),
                        ),
                        if (_validationError != null) ...[
                          SizedBox(height: context.rSpacing(10)),
                          Text(
                            _validationError!,
                            style: TextStyle(
                              color: AppColors.primaryAccent,
                              fontSize: context.rFont(12, min: 11, max: 13),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        SizedBox(height: context.rSpacing(14)),
                        Container(
                          key: const Key('desktop_edit_notice_banner'),
                          padding: EdgeInsets.all(context.rSpacing(12)),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A)
                                .withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.skyBadge.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: context.rIcon(18),
                                color: AppColors.skyBadge,
                              ),
                              SizedBox(width: context.rSpacing(10)),
                              Expanded(
                                child: Text(
                                  'Profile information and credentials are encrypted and synchronized securely.',
                                  style: TextStyle(
                                    color: AppColors.skyBadge,
                                    fontSize:
                                        context.rFont(12, min: 11, max: 13),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.rSpacing(24),
        context.rSpacing(18),
        context.rSpacing(16),
        context.rSpacing(16),
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: context.rIcon(38),
            height: context.rIcon(38),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              Icons.manage_accounts_rounded,
              color: AppColors.primaryAccent,
              size: context.rIcon(20),
            ),
          ),
          SizedBox(width: context.rSpacing(12)),
          Expanded(
            child: Text(
              'Edit Profile',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: context.rFont(16, min: 14, max: 18),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.textMuted,
              size: context.rIcon(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.rSpacing(14)),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          GestureDetector(
            key: const Key('desktop_edit_avatar_picker'),
            onTap: () => setState(
              () => _showPhotoSourcePicker = !_showPhotoSourcePicker,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _hasCustomPhoto
                        ? AppColors.primaryAccent.withValues(alpha: 0.22)
                        : AppColors.bgSidebar,
                    border: Border.all(
                      color: AppColors.primaryAccent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: _hasCustomPhoto
                        ? Icon(
                            Icons.person_pin_rounded,
                            color: AppColors.primaryAccent,
                            size: context.rIcon(28),
                          )
                        : Text(
                            _computedInitials,
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: context.rFont(18, min: 16, max: 20),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    key: const Key('desktop_edit_camera_badge'),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bgPrimary, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.rSpacing(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Picture',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: context.rFont(13.5, min: 12, max: 15),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.rSpacing(2)),
                Text(
                  'PNG/JPG max 2MB atau inisial nama otomatis',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(11.5, min: 10.5, max: 12.5),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            key: const Key('desktop_change_photo_button'),
            onPressed: () => setState(
              () => _showPhotoSourcePicker = !_showPhotoSourcePicker,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textWhite,
              side: const BorderSide(color: AppColors.borderSubtle),
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(12),
                vertical: context.rSpacing(10),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(Icons.photo_camera_outlined, size: context.rIcon(15)),
            label: Text(
              'Ganti Foto',
              style: TextStyle(
                fontSize: context.rFont(12, min: 11, max: 13),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: context.rSpacing(8)),
          TextButton(
            key: const Key('desktop_remove_photo_button'),
            onPressed: _removePhoto,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryAccent,
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(10),
                vertical: context.rSpacing(10),
              ),
            ),
            child: Text(
              'Hapus',
              style: TextStyle(
                fontSize: context.rFont(12, min: 11, max: 13),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSourceChooser(BuildContext context) {
    return Container(
      key: const Key('desktop_photo_source_chooser'),
      padding: EdgeInsets.all(context.rSpacing(12)),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _selectPhotoSource,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textWhite,
                side: const BorderSide(color: AppColors.borderSubtle),
                padding: EdgeInsets.symmetric(vertical: context.rSpacing(12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primaryAccent,
                size: context.rIcon(18),
              ),
              label: Text(
                'Take Photo with Camera',
                style: TextStyle(
                  fontSize: context.rFont(12, min: 11, max: 13),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: context.rSpacing(10)),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _selectPhotoSource,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textWhite,
                side: const BorderSide(color: AppColors.borderSubtle),
                padding: EdgeInsets.symmetric(vertical: context.rSpacing(12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                Icons.photo_library_outlined,
                color: AppColors.skyBadge,
                size: context.rIcon(18),
              ),
              label: Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontSize: context.rFont(12, min: 11, max: 13),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.rSpacing(24),
        context.rSpacing(14),
        context.rSpacing(24),
        context.rSpacing(18),
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              side: const BorderSide(color: AppColors.borderSubtle),
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(18),
                vertical: context.rSpacing(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Batal',
              style: TextStyle(
                fontSize: context.rFont(13, min: 12, max: 14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: context.rSpacing(12)),
          ElevatedButton(
            key: const Key('desktop_edit_save_button'),
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(20),
                vertical: context.rSpacing(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSaving) ...[
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: context.rSpacing(8)),
                ],
                Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    fontSize: context.rFont(13, min: 12, max: 14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal - Change Password (`FigCraft node 6246`, 480dp) + Mobile Forgot? Flow.
class DesktopChangePasswordModal extends StatefulWidget {
  final String email;
  final BuildContext parentContext;
  final VoidCallback? onUpdated;

  const DesktopChangePasswordModal({
    super.key,
    required this.email,
    required this.parentContext,
    this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required String email,
    VoidCallback? onUpdated,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => DesktopChangePasswordModal(
        email: email,
        parentContext: context,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<DesktopChangePasswordModal> createState() =>
      _DesktopChangePasswordModalState();
}

class _DesktopChangePasswordModalState
    extends State<DesktopChangePasswordModal> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    void listener() {
      if (mounted) {
        setState(() {
          if (_errorMessage != null) _errorMessage = null;
        });
      }
    }

    _currentController.addListener(listener);
    _newController.addListener(listener);
    _confirmController.addListener(listener);
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _newController.text.length >= 8;
  bool get _hasUpperLowerNumber =>
      RegExp(r'[A-Z]').hasMatch(_newController.text) &&
      RegExp(r'[a-z]').hasMatch(_newController.text) &&
      RegExp(r'[0-9]').hasMatch(_newController.text);
  bool get _hasSpecialChar =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\[\]\\/+=~`]').hasMatch(_newController.text);

  int get _strengthScore {
    if (_newController.text.isEmpty) return 0;
    int score = 0;
    if (_hasMinLength) score++;
    if (RegExp(r'[A-Z]').hasMatch(_newController.text) &&
        RegExp(r'[a-z]').hasMatch(_newController.text)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(_newController.text)) score++;
    if (_hasSpecialChar) score++;
    return score;
  }

  bool get _passwordsMatch =>
      _confirmController.text.isNotEmpty &&
      _newController.text == _confirmController.text;

  (String, Color) get _strengthDescriptor {
    switch (_strengthScore) {
      case 4:
        return ('Strong', const Color(0xFF4EB089));
      case 3:
        return ('Good', AppColors.skyBadge);
      case 2:
        return ('Fair', const Color(0xFFFBBF24));
      case 1:
        return ('Weak', AppColors.primaryAccent);
      default:
        return ('Empty', AppColors.textMuted);
    }
  }

  void _openForgotFlow() {
    Navigator.of(context).pop();
    if (!widget.parentContext.mounted) return;
    Navigator.of(widget.parentContext).push(
      AuthFadeRoute(
        page: ForgotPassword(initialEmail: widget.email),
      ),
    );
  }

  void _handleUpdatePassword() {
    if (_isSaving) return;
    if (_currentController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your current password.');
      return;
    }
    if (!_hasMinLength || !_hasUpperLowerNumber) {
      setState(
        () => _errorMessage =
            'New password must be at least 8 characters with uppercase, lowercase, and numbers.',
      );
      return;
    }
    if (_newController.text != _confirmController.text) {
      setState(
        () => _errorMessage = 'Password confirmation does not match.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    widget.onUpdated?.call();
    Navigator.of(context).pop();

    if (widget.parentContext.mounted) {
      PopUpPemberitahuan.show(
        widget.parentContext,
        title: 'Password Updated',
        message: 'Your account credentials have been secured successfully.',
        icon: Icons.verified_user_rounded,
        iconBgColor: PopUpPemberitahuan.positiveColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    final (strengthLabel, strengthColor) = _strengthDescriptor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(context.rSpacing(20)),
      child: UnfocusOnTap(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 480,
            maxHeight: maxHeight,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgSidebar,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(context.rSpacing(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ModalFieldLabel(
                          label: 'Current Password',
                          trailing: InkWell(
                            key: const Key('desktop_forgot_password_link'),
                            onTap: _openForgotFlow,
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.rSpacing(6),
                                vertical: context.rSpacing(2),
                              ),
                              child: Text(
                                'Forgot?',
                                style: TextStyle(
                                  color: AppColors.primaryAccent,
                                  fontSize:
                                      context.rFont(11.5, min: 10.5, max: 12.5),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.rSpacing(6)),
                        TextField(
                          key: const Key('desktop_current_password_field'),
                          controller: _currentController,
                          obscureText: _obscureCurrent,
                          maxLength: 128,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: context.rFont(13, min: 12, max: 14),
                          ),
                          decoration: _desktopModalInputDecoration(
                            context,
                            hint: 'Enter current password',
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscureCurrent = !_obscureCurrent,
                              ),
                              icon: Icon(
                                _obscureCurrent
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textMuted,
                                size: context.rIcon(18),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.rSpacing(16)),
                        _ModalFieldLabel(
                          label: 'New Password',
                          trailing: Text(
                            strengthLabel,
                            style: TextStyle(
                              color: strengthColor,
                              fontSize: context.rFont(11, min: 10, max: 12),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: context.rSpacing(6)),
                        TextField(
                          key: const Key('desktop_new_password_field'),
                          controller: _newController,
                          obscureText: _obscureNew,
                          maxLength: 128,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: context.rFont(13, min: 12, max: 14),
                          ),
                          decoration: _desktopModalInputDecoration(
                            context,
                            hint: 'Create a strong new password',
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                              icon: Icon(
                                _obscureNew
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textMuted,
                                size: context.rIcon(18),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.rSpacing(10)),
                        Row(
                          key: const Key('desktop_password_strength_meter'),
                          children: List.generate(4, (index) {
                            final active = index < _strengthScore;
                            return Expanded(
                              child: Container(
                                height: 5,
                                margin: EdgeInsets.only(
                                  right: index < 3 ? context.rSpacing(6) : 0,
                                ),
                                decoration: BoxDecoration(
                                  color: active
                                      ? strengthColor
                                      : AppColors.borderSubtle,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: context.rSpacing(12)),
                        Container(
                          padding: EdgeInsets.all(context.rSpacing(12)),
                          decoration: BoxDecoration(
                            color: AppColors.bgPrimary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Column(
                            children: [
                              _RequirementRow(
                                label: 'Minimum 8 characters',
                                met: _hasMinLength,
                              ),
                              SizedBox(height: context.rSpacing(6)),
                              _RequirementRow(
                                label: 'Mix of upper & lowercase + numbers',
                                met: _hasUpperLowerNumber,
                              ),
                              SizedBox(height: context.rSpacing(6)),
                              _RequirementRow(
                                label:
                                    'At least 1 special character (@#\$!%*?& etc.)',
                                met: _hasSpecialChar,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: context.rSpacing(16)),
                        _ModalFieldLabel(
                          label: 'Confirm New Password',
                          trailing: _confirmController.text.isEmpty
                              ? null
                              : _ModalPillBadge(
                                  text: _passwordsMatch ? '✓ Match' : 'Mismatch',
                                  bgColor: _passwordsMatch
                                      ? const Color(0xFF1F3D35)
                                      : AppColors.primaryAccent
                                          .withValues(alpha: 0.18),
                                  textColor: _passwordsMatch
                                      ? const Color(0xFF4EB089)
                                      : AppColors.primaryAccent,
                                ),
                        ),
                        SizedBox(height: context.rSpacing(6)),
                        TextField(
                          key: const Key('desktop_confirm_password_field'),
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          maxLength: 128,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: context.rFont(13, min: 12, max: 14),
                          ),
                          decoration: _desktopModalInputDecoration(
                            context,
                            hint: 'Re-enter new password',
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textMuted,
                                size: context.rIcon(18),
                              ),
                            ),
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          SizedBox(height: context.rSpacing(10)),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: AppColors.primaryAccent,
                              fontSize: context.rFont(12, min: 11, max: 13),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.rSpacing(24),
        context.rSpacing(18),
        context.rSpacing(16),
        context.rSpacing(16),
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: context.rIcon(38),
            height: context.rIcon(38),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              color: AppColors.primaryAccent,
              size: context.rIcon(20),
            ),
          ),
          SizedBox(width: context.rSpacing(12)),
          Expanded(
            child: Text(
              'Change Password',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: context.rFont(16, min: 14, max: 18),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.textMuted,
              size: context.rIcon(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.rSpacing(24),
        context.rSpacing(14),
        context.rSpacing(24),
        context.rSpacing(18),
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              side: const BorderSide(color: AppColors.borderSubtle),
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(18),
                vertical: context.rSpacing(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: context.rFont(13, min: 12, max: 14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: context.rSpacing(12)),
          ElevatedButton(
            key: const Key('desktop_update_password_button'),
            onPressed: _isSaving ? null : _handleUpdatePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(20),
                vertical: context.rSpacing(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Update Password',
              style: TextStyle(
                fontSize: context.rFont(13, min: 12, max: 14),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  final bool met;

  const _RequirementRow({
    required this.label,
    required this.met,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: context.rIcon(15),
          color: met ? const Color(0xFF4EB089) : AppColors.textMuted,
        ),
        SizedBox(width: context.rSpacing(8)),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: met ? AppColors.textWhite : AppColors.textMuted,
              fontSize: context.rFont(12, min: 11, max: 13),
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

/// Modal - Terms and Privacy Policy (`FigCraft node 6296`, 560dp).
class DesktopTermsPrivacyModal extends StatelessWidget {
  const DesktopTermsPrivacyModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => const DesktopTermsPrivacyModal(),
    );
  }

  static const _clauses = [
    (
      '1. Scope of Academic Productivity',
      'Aplikasi Todolist Sistem Cerdas IMPAL dirancang khusus untuk membantu mahasiswa mengelola tugas kuliah, kolaborasi kelompok, dan jadwal akademik.'
    ),
    (
      '2. Telkom University SSO & Identity Verification',
      'Kredensial mahasiswa dan NIM terverifikasi melalui Telkom University CAS SSO dan dilindungi oleh enkripsi standar institusi.'
    ),
    (
      '3. Explainable AI (XAI) & Mamdani Fuzzy Logic Disclaimer',
      'Skor prioritas otomatis dihasilkan menggunakan sistem inferensi Fuzzy Mamdani Max-Min sebagai rekomendasi pendukung keputusan akademik.'
    ),
    (
      '4. Personal Schedule & Team Data Confidentiality',
      'Data tugas pribadi bersifat privat, sementara jadwal dan progres milestone kelompok hanya dibagikan kepada anggota tim yang terdaftar.'
    ),
    (
      '5. Notification Preferences & Background Sync',
      'Pengingat deadline dan Daily Morning Briefing dikirim secara adaptif sesuai konfigurasi kategori notifikasi mahasiswa.'
    ),
    (
      '6. Data Retention, Integrity & Academic Ethics',
      'Mahasiswa bertanggung jawab penuh atas keabsahan jadwal ujian dan pengumpulan tugas sesuai kode etik Telkom University.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    const indigoAccent = Color(0xFF778BEB);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(context.rSpacing(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: maxHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgSidebar,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(
                  context.rSpacing(24),
                  context.rSpacing(18),
                  context.rSpacing(16),
                  context.rSpacing(16),
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: context.rIcon(38),
                      height: context.rIcon(38),
                      decoration: BoxDecoration(
                        color: indigoAccent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: indigoAccent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        Icons.verified_user_outlined,
                        color: indigoAccent,
                        size: context.rIcon(20),
                      ),
                    ),
                    SizedBox(width: context.rSpacing(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms & Privacy Policy',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: context.rFont(16, min: 14, max: 18),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: context.rSpacing(2)),
                          Text(
                            'Academic Agreement, XAI Governance & Data Protection',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: context.rFont(12, min: 11, max: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textMuted,
                        size: context.rIcon(20),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.rSpacing(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(context.rSpacing(16)),
                        decoration: BoxDecoration(
                          color: AppColors.bgPrimary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < _clauses.length; i++) ...[
                              Text(
                                _clauses[i].$1,
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize:
                                      context.rFont(13, min: 12, max: 14),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: context.rSpacing(4)),
                              Text(
                                _clauses[i].$2,
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize:
                                      context.rFont(12, min: 11, max: 13),
                                  height: 1.45,
                                ),
                              ),
                              if (i < _clauses.length - 1) ...[
                                SizedBox(height: context.rSpacing(12)),
                                const Divider(
                                  color: AppColors.borderSubtle,
                                  height: 1,
                                ),
                                SizedBox(height: context.rSpacing(12)),
                              ],
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: context.rSpacing(14)),
                      Container(
                        padding: EdgeInsets.all(context.rSpacing(12)),
                        decoration: BoxDecoration(
                          color: indigoAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: indigoAccent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              color: indigoAccent,
                              size: context.rIcon(18),
                            ),
                            SizedBox(width: context.rSpacing(10)),
                            Expanded(
                              child: Text(
                                'Academic Advisory: Rekomendasi AI bersifat pendukung keputusan. Pastikan seluruh deadline portal LMS tetap dipantau.',
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize:
                                      context.rFont(12, min: 11, max: 13),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  context.rSpacing(24),
                  context.rSpacing(14),
                  context.rSpacing(24),
                  context.rSpacing(18),
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: context.rSpacing(8),
                        runSpacing: context.rSpacing(6),
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Pembaruan Kebijakan: Nov 2026',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize:
                                  context.rFont(11.5, min: 10.5, max: 12.5),
                            ),
                          ),
                          const _ModalPillBadge(
                            text: 'v1.2 Active',
                            bgColor: Color(0xFF1F3D35),
                            textColor: Color(0xFF4EB089),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.rSpacing(12)),
                    ElevatedButton(
                      key: const Key('desktop_terms_close_button'),
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: indigoAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.rSpacing(18),
                          vertical: context.rSpacing(12),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Saya Mengerti & Tutup',
                        style: TextStyle(
                          fontSize: context.rFont(12.5, min: 11.5, max: 14),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
