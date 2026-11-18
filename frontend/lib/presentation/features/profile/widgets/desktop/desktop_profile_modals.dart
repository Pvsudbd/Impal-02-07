import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/page_transitions.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../../core/widgets/unfocus_on_tap.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../../auth/forgot_password_page.dart';
import '../../models/user_profile_model.dart';

/// Desktop Pop-Up Dialog mirroring Mobile [EditProfilePage] layout & fields
/// (`FULL NAME`, `EMAIL` + Verified pill, `WHATSAPP / MOBILE NUMBER`, `STATUS / BIO`),
/// centered 94dp coral-ring avatar + `Change Profile Picture` chooser, info notice
/// banner, `[✕]` close button without `Cancel`, and full-width `Save Changes` CTA.
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
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  bool _showPhotoSourcePicker = false;
  bool _hasCustomPhoto = false;
  bool _isSaving = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _fullNameController = TextEditingController(text: p.fullName);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phoneNumber);
    _bioController = TextEditingController(text: p.bio);

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
    _emailController.dispose();
    _phoneController.dispose();
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
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  void _close() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop();
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
      bio: _bioController.text.trim(),
    );

    UserProfileRepository().updateProfile(updated);
    widget.onSaved?.call(updated);

    _close();
    if (widget.parentContext.mounted) {
      PopUpPemberitahuan.profileUpdated(widget.parentContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final modalWidth = (screenSize.width - 48).clamp(320.0, 480.0);
    final maxModalHeight = (screenSize.height * 0.9).clamp(440.0, 780.0);
    final disableAnimations = context.animationsDisabled;
    final animDuration =
        disableAnimations ? Duration.zero : const Duration(milliseconds: 180);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(24),
        vertical: context.rSpacing(20),
      ),
      child: UnfocusOnTap(
        child: TweenAnimationBuilder<double>(
          duration: animDuration,
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.96, end: 1.0),
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: ((scale - 0.96) / 0.04).clamp(0.0, 1.0),
              child: child,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: modalWidth,
              maxHeight: maxModalHeight,
            ),
            child: Container(
              width: modalWidth,
              decoration: BoxDecoration(
                color: AppColors.bgDialog,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x8A000000),
                    blurRadius: 30,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderSubtle,
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        context.rSpacing(24),
                        context.rSpacing(20),
                        context.rSpacing(24),
                        context.rSpacing(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCenteredAvatar(context),
                          if (_showPhotoSourcePicker) ...[
                            SizedBox(height: context.rSpacing(14)),
                            _buildPhotoSourceChooser(context),
                          ],
                          SizedBox(height: context.rSpacing(20)),
                          _buildMobileStyleField(
                            context,
                            label: 'FULL NAME',
                            fieldKey: const Key('desktop_edit_fullname_field'),
                            controller: _fullNameController,
                            leadingIcon: Icons.person_outline_rounded,
                            hint: 'Yoga Perkasa Didik',
                            maxLength: 100,
                          ),
                          SizedBox(height: context.rSpacing(14)),
                          _buildMobileStyleField(
                            context,
                            label: 'EMAIL',
                            fieldKey: const Key('desktop_edit_email_field'),
                            controller: _emailController,
                            leadingIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            hint: 'yogaperkasa@student.telkomuniversity.ac.id',
                            maxLength: 120,
                            trailing: _buildVerifiedPill(context),
                          ),
                          SizedBox(height: context.rSpacing(14)),
                          _buildMobileStyleField(
                            context,
                            label: 'WHATSAPP / MOBILE NUMBER',
                            fieldKey: const Key('desktop_edit_phone_field'),
                            controller: _phoneController,
                            leadingIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            hint: '+62 812-3456-7890',
                            maxLength: 20,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+\-\s]'),
                              ),
                            ],
                            tabularNumbers: true,
                          ),
                          SizedBox(height: context.rSpacing(14)),
                          _buildMobileStyleField(
                            context,
                            label: 'STATUS / BIO',
                            fieldKey: const Key('desktop_edit_bio_field'),
                            controller: _bioController,
                            leadingIcon: Icons.edit_note_rounded,
                            maxLines: 3,
                            maxLength: 200,
                            hint:
                                'Informatics Engineering student focused on Flutter & AI systems.',
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
                          SizedBox(height: context.rSpacing(16)),
                          _buildNoticeBanner(context),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.rSpacing(24),
        context.rSpacing(16),
        context.rSpacing(10),
        context.rSpacing(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Edit Profile',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.rFont(18, min: 16, max: 20),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('desktop_edit_close_button'),
              onTap: _close,
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Center(
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
    );
  }

  Widget _buildCenteredAvatar(BuildContext context) {
    return Center(
      child: Column(
        children: [
          InkWell(
            key: const Key('desktop_edit_avatar_picker'),
            onTap: () => setState(
              () => _showPhotoSourcePicker = !_showPhotoSourcePicker,
            ),
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 94,
                  height: 94,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _hasCustomPhoto
                        ? AppColors.primary.withValues(alpha: 0.22)
                        : const Color(0xFF2E3440),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _hasCustomPhoto
                      ? Icon(
                          Icons.person_pin_rounded,
                          color: AppColors.primaryAccent,
                          size: context.rIcon(40),
                        )
                      : Text(
                          _computedInitials,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(28, min: 24, max: 32),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    key: const Key('desktop_edit_camera_badge'),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bgCard, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.rSpacing(10)),
          InkWell(
            key: const Key('desktop_change_photo_button'),
            onTap: () => setState(
              () => _showPhotoSourcePicker = !_showPhotoSourcePicker,
            ),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                'Change Profile Picture',
                style: TextStyle(
                  color: AppColors.primaryAccent,
                  fontSize: context.rFont(12.5, min: 11.5, max: 14),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
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
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectPhotoSource,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textWhite,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: EdgeInsets.symmetric(vertical: context.rSpacing(12)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primaryAccent,
                    size: context.rIcon(18),
                  ),
                  label: Text(
                    'Take Photo with Camera',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.skyBadge,
                    size: context.rIcon(18),
                  ),
                  label: Text(
                    'Choose from Gallery',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.rFont(12, min: 11, max: 13),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_hasCustomPhoto) ...[
            SizedBox(height: context.rSpacing(8)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('desktop_remove_photo_button'),
                onPressed: _removePhoto,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryAccent,
                ),
                child: const Text(
                  'Revert to Initials',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerifiedPill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFF064E3B).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_rounded,
            size: 11,
            color: Color(0xFF34D399),
          ),
          const SizedBox(width: 3),
          Text(
            'Verified',
            style: TextStyle(
              color: const Color(0xFF34D399),
              fontSize: context.rFont(9.5, min: 8.5, max: 11),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStyleField(
    BuildContext context, {
    required String label,
    required Key fieldKey,
    required TextEditingController controller,
    required IconData leadingIcon,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool tabularNumbers = false,
    Widget? trailing,
  }) {
    final isMultiline = maxLines > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: context.rFont(10.5, min: 9.5, max: 12),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(height: context.rSpacing(7)),
        Stack(
          children: [
            TextField(
              key: fieldKey,
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              maxLength: maxLength,
              inputFormatters: inputFormatters,
              textAlignVertical:
                  isMultiline ? TextAlignVertical.top : TextAlignVertical.center,
              buildCounter: maxLength != null
                  ? (_,
                          {required currentLength,
                          required isFocused,
                          required maxLength}) =>
                      null
                  : null,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.rFont(13.5, min: 12, max: 15),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontFeatures:
                    tabularNumbers ? const [FontFeature.tabularFigures()] : null,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.65),
                  fontSize: context.rFont(13, min: 12, max: 14),
                ),
                filled: true,
                fillColor: AppColors.bgCard,
                prefixIcon: isMultiline
                    ? null
                    : Icon(
                        leadingIcon,
                        size: 18,
                        color: const Color(0xFF8E95A5),
                      ),
                suffixIcon: trailing != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [trailing],
                        ),
                      )
                    : null,
                contentPadding: isMultiline
                    ? const EdgeInsets.fromLTRB(44, 14, 14, 14)
                    : const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: const Color(0xFF434A59).withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.4,
                  ),
                ),
              ),
            ),
            if (isMultiline)
              Positioned(
                top: 15,
                left: 14,
                child: IgnorePointer(
                  child: Icon(
                    leadingIcon,
                    size: 18,
                    color: const Color(0xFF8E95A5),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoticeBanner(BuildContext context) {
    return Container(
      key: const Key('desktop_edit_notice_banner'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(14),
        vertical: context.rSpacing(12),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2838),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF5B93FF).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFF5B93FF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Profile information and credentials are encrypted and synchronized securely.',
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: context.rFont(11.5, min: 10, max: 13),
                fontFamily: 'Inter',
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.rSpacing(24),
        context.rSpacing(8),
        context.rSpacing(24),
        context.rSpacing(18),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          key: const Key('desktop_edit_save_button'),
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSaving) ...[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: context.rSpacing(8)),
              ],
              Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(14, min: 13, max: 16),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Desktop confirmation Pop-Up mirroring Mobile `ProfilePage._showChangePasswordModal`.
/// Redirects the user to [ForgotPassword] (recovery method selection → OTP → reset password).
class DesktopChangePasswordModal extends StatelessWidget {
  final String email;
  final BuildContext parentContext;

  const DesktopChangePasswordModal({
    super.key,
    required this.email,
    required this.parentContext,
  });

  static Future<void> show(
    BuildContext context, {
    required String email,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => DesktopChangePasswordModal(
        email: email,
        parentContext: context,
      ),
    );
  }

  void _close(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop();
  }

  void _continueToReset(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop();
    if (!parentContext.mounted) return;
    Navigator.of(parentContext).push(
      AuthFadeRoute(
        page: ForgotPassword(initialEmail: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final modalWidth = (screenWidth * 0.9).clamp(320.0, 440.0);
    final disableAnimations = context.animationsDisabled;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(context.rSpacing(20)),
      child: UnfocusOnTap(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: disableAnimations ? 1.0 : 0.96, end: 1.0),
          duration:
              disableAnimations ? Duration.zero : const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: disableAnimations ? 1.0 : scale,
              child: child,
            ),
          ),
          child: SizedBox(
            width: modalWidth,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                context.rSpacing(22),
                context.rSpacing(18),
                context.rSpacing(22),
                context.rSpacing(22),
              ),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.48),
                    blurRadius: 32,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF38BDF8),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Change Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(18, min: 16, max: 20),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        key: const Key('desktop_change_password_close_button'),
                        onPressed: () => _close(context),
                        tooltip: 'Close',
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.textMuted,
                          size: context.rIcon(20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.rSpacing(12)),
                  Text(
                    'To change your password, you will be redirected to the secure verification and password reset flow for your registered account ($email).',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: context.rFont(13, min: 12, max: 14.5),
                      fontFamily: 'Inter',
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: context.rSpacing(22)),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      key: const Key('desktop_continue_reset_password_button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _continueToReset(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Continue to Reset Password',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Colors.white,
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

/// Desktop Pop-Up Dialog mirroring Mobile [TermsPrivacyPage] (`isFromRegister: false`)
/// read-only document view (`Terms & Privacy`, `'v1.2 Active'`, 6 English clauses,
/// `Academic Advisory Note`, bullet points, top-right `[✕]` without bottom CTA).
class DesktopTermsPrivacyModal extends StatelessWidget {
  const DesktopTermsPrivacyModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => const DesktopTermsPrivacyModal(),
    );
  }

  void _close(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final modalWidth = (screenSize.width - 48).clamp(320.0, 560.0);
    final maxModalHeight = (screenSize.height * 0.88).clamp(440.0, 820.0);
    final disableAnimations = context.animationsDisabled;
    final animDuration =
        disableAnimations ? Duration.zero : const Duration(milliseconds: 180);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(24),
        vertical: context.rSpacing(20),
      ),
      child: TweenAnimationBuilder<double>(
        duration: animDuration,
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0.96, end: 1.0),
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: ((scale - 0.96) / 0.04).clamp(0.0, 1.0),
            child: child,
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: modalWidth,
            maxHeight: maxModalHeight,
          ),
          child: Container(
            width: modalWidth,
            decoration: BoxDecoration(
              color: AppColors.bgDialog,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x8A000000),
                  blurRadius: 30,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.rSpacing(22),
                    context.rSpacing(16),
                    context.rSpacing(10),
                    context.rSpacing(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Terms & Privacy',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(16, min: 14, max: 18),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF064E3B).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                const Color(0xFF10B981).withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'v1.2 Active',
                          style: TextStyle(
                            color: const Color(0xFF34D399),
                            fontSize: context.rFont(10.5, min: 9.5, max: 12),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: const Key('desktop_terms_close_button'),
                          onTap: () => _close(context),
                          borderRadius: BorderRadius.circular(8),
                          child: const SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
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
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderSubtle,
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      context.rSpacing(22),
                      context.rSpacing(18),
                      context.rSpacing(22),
                      context.rSpacing(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms of Service & Privacy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(20, min: 18, max: 24),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'IMPAL Smart Task & Schedule Prioritization System • Telkom University',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: context.rFont(11.5, min: 10.5, max: 13),
                            fontFamily: 'Inter',
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: context.rSpacing(14)),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(context.rSpacing(16)),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E232E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.borderSubtle
                                  .withValues(alpha: 0.45),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSection(
                                context,
                                title: '1. Acceptance of Terms',
                                content:
                                    'By creating an account, registering your student credentials, or connecting through Telkom University Single Sign-On (SSO), you agree to comply with and be bound by these Terms of Service and all applicable university academic policies.',
                              ),
                              SizedBox(height: context.rSpacing(16)),
                              _buildSection(
                                context,
                                title: '2. AI-Driven Recommendation Core',
                                content:
                                    'IMPAL integrates a Mamdani Fuzzy Inference System that analyzes deadline proximity, syllabus grade weight, and complexity to compute a crisp recommendation score (0–100).',
                              ),
                              SizedBox(height: context.rSpacing(10)),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  color: const Color(0xFF252A36),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          width: 3.5,
                                          color: AppColors.primary,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              context.rSpacing(12),
                                            ),
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text:
                                                        'Academic Advisory Note: ',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        'Priority scores generated by the system serve solely as planning guidance. Students retain complete individual responsibility for meeting all submission deadlines set by course lecturers.',
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.textMuted,
                                                      fontSize: context.rFont(
                                                        11,
                                                        min: 10,
                                                        max: 12,
                                                      ),
                                                      fontFamily: 'Inter',
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: context.rSpacing(16)),
                              _buildSection(
                                context,
                                title: '3. Student Privacy & SSO Data Security',
                                content:
                                    'We collect and process your Student ID (NIM), registered university email, academic program, and course schedules synchronized via the Central Authentication Service (CAS).',
                              ),
                              SizedBox(height: context.rSpacing(6)),
                              _buildBullet(
                                context,
                                'All student credential exchanges use TLS 1.3 protocol encryption.',
                              ),
                              _buildBullet(
                                context,
                                'Data is restricted exclusively to task calculation and timetable syncing.',
                              ),
                              _buildBullet(
                                context,
                                'Student records are never sold, rented, or distributed to commercial parties.',
                              ),
                              SizedBox(height: context.rSpacing(16)),
                              _buildSection(
                                context,
                                title:
                                    '4. Team Collaboration Code of Conduct',
                                content:
                                    'When participating in team workspaces (Group Projects):',
                              ),
                              SizedBox(height: context.rSpacing(6)),
                              _buildBullet(
                                context,
                                'Do not delete or alter task items assigned to other team members without mutual agreement.',
                              ),
                              _buildBullet(
                                context,
                                'Keep 4-character team join codes confidential within your designated project group',
                              ),
                              _buildBullet(
                                context,
                                'Observe the Telkom University Academic Honor Code in all shared group deliverables',
                              ),
                              SizedBox(height: context.rSpacing(16)),
                              _buildSection(
                                context,
                                title: '5. Algorithm Explainability (XAI) Rights',
                                content:
                                    'Users possess the explicit right to inspect how priorities were deduced through the Explainability Modal, detailing membership degrees, fired fuzzy rules, and centroid calculation formulas.',
                              ),
                              SizedBox(height: context.rSpacing(16)),
                              _buildSection(
                                context,
                                title: '6. Termination & Account Unlinking',
                                content:
                                    'Students may unlink their Telkom SSO account, clear local cached schedules, or request full task catalog deletion upon semester completion.',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: context.rSpacing(16)),
                        Center(
                          child: Text(
                            'IMPAL Group 7 • Telkom University © 2026',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontSize: context.rFont(10.5, min: 9.5, max: 12),
                              fontFamily: 'Inter',
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
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: context.rFont(13.5, min: 12.5, max: 15),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          content,
          style: TextStyle(
            color: const Color(0xFFCBD5E1),
            fontSize: context.rFont(12, min: 11, max: 13.5),
            fontFamily: 'Inter',
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: const Color(0xFFCBD5E1),
                fontSize: context.rFont(11.5, min: 10.5, max: 13),
                fontFamily: 'Inter',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
