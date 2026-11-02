import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../../core/widgets/unfocus_on_tap.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import 'models/user_profile_model.dart';
import 'widgets/profile_text_field.dart';

// Aliases for backwards compatibility with Figma exports
typedef EditProfile = EditProfilePage;
typedef EditProfileScreen = EditProfilePage;

/// Full Edit Profile form screen.
///
/// Features:
/// - Avatar photo preview with coral ring and floating camera badge
/// - "Change Profile Picture" action with modal picker
/// - Standardized input fields (Full Name, NIM, Major & Campus, Official Campus Email with Verified pill,
///   WhatsApp Number, Group Role, Bio/Status multi-line)
/// - Information notice banner about SSO synchronization
/// - Save Changes button with anti-double submit and PopUpPemberitahuan
class EditProfilePage extends StatefulWidget {
  final UserProfileModel currentProfile;
  final ValueChanged<UserProfileModel>? onProfileSaved;
  final VoidCallback? onBack;

  const EditProfilePage({
    super.key,
    required this.currentProfile,
    this.onProfileSaved,
    this.onBack,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.currentProfile;
    _fullNameController = TextEditingController(text: p.fullName);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phoneNumber);
    _bioController = TextEditingController(text: p.bio);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showChangePhotoModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Profile Photo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(18, min: 16, max: 20),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select source to update your student avatar',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Take Photo with Camera',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  PopUpPemberitahuan.profilePictureUpdated(context);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B93FF).withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF5B93FF),
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  PopUpPemberitahuan.profilePictureUpdated(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_isSubmitting) return;

    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      PopUpPemberitahuan.warning(
        context,
        title: 'Validation Error',
        message: 'Full name cannot be empty.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final updated = widget.currentProfile.copyWith(
      fullName: fullName,
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      bio: _bioController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      PopUpPemberitahuan.profileUpdated(context);
      widget.onProfileSaved?.call(updated);
      Navigator.of(context).pop(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final formContent = CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            context.rSpacing(20),
            context.rSpacing(14),
            context.rSpacing(20),
            context.rSpacing(40),
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Top Bar: Back button and centered Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Edit Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(18, min: 16, max: 22),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  // Empty balanced placeholder
                  const SizedBox(width: 38),
                ],
              ),
              SizedBox(height: context.rSpacing(20)),

              // 2. Avatar Photo with Floating Camera Badge
              Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 94,
                          height: 94,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2E3440),
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
                          child: Text(
                            widget.currentProfile.initials,
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
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _showChangePhotoModal,
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.bgCard,
                                    width: 2,
                                  ),
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
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.rSpacing(10)),
                    InkWell(
                      onTap: _showChangePhotoModal,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
              ),
              SizedBox(height: context.rSpacing(20)),

              // 3. Form Field 1: FULL NAME
              ProfileTextField(
                label: 'FULL NAME',
                controller: _fullNameController,
                leadingIcon: Icons.person_outline_rounded,
              ),
              SizedBox(height: context.rSpacing(14)),

              // 4. Form Field 2: EMAIL with Verified pill
              ProfileTextField(
                label: 'EMAIL',
                controller: _emailController,
                leadingIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
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
                ),
              ),
              SizedBox(height: context.rSpacing(14)),

              // 5. Form Field 3: WHATSAPP / MOBILE NUMBER
              ProfileTextField(
                label: 'WHATSAPP / MOBILE NUMBER',
                controller: _phoneController,
                leadingIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: context.rSpacing(14)),

              // 6. Form Field 4: STATUS / BIO
              ProfileTextField(
                label: 'STATUS / BIO',
                controller: _bioController,
                leadingIcon: Icons.edit_note_rounded,
                maxLines: 3,
              ),
              SizedBox(height: context.rSpacing(16)),

              // 7. Information Notice Banner
              Container(
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
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.rSpacing(24)),

              // 11. Save Changes Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const ValueKey('save_profile_button'),
                  onPressed: _isSubmitting ? null : _handleSave,
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
                      if (_isSubmitting) ...[
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(14.5, min: 13, max: 16),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );

    final wrapped = UnfocusOnTap(child: formContent);

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(top: true, bottom: false, child: wrapped),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E222B),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 410, maxHeight: 844),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x8C000000),
                      blurRadius: 40,
                      offset: Offset(0, 20),
                    ),
                  ],
                ),
                child: wrapped,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
