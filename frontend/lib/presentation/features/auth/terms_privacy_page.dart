import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';

/// Unified Terms of Service & Privacy Policy screen.
///
/// Supports two modes:
/// 1. [isFromRegister = true]: Used during onboarding/registration.
///    - Close button (✕) on top left.
///    - Agreement checkbox ("I have read and agree...")
///    - [Decline] and [Accept & Continue →] action buttons.
/// 2. [isFromRegister = false]: Used from Profile & Settings view.
///    - Back button (←) on top left.
///    - Read-only document view with NO checkbox and NO bottom buttons.
class TermsPrivacyPage extends StatefulWidget {
  final bool isFromRegister;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const TermsPrivacyPage({
    super.key,
    this.isFromRegister = false,
    this.onAccept,
    this.onDecline,
  });

  @override
  State<TermsPrivacyPage> createState() => _TermsPrivacyPageState();
}

class _TermsPrivacyPageState extends State<TermsPrivacyPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasAgreed = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleCloseOrBack() {
    if (widget.isFromRegister) {
      if (widget.onDecline != null) {
        widget.onDecline!();
      } else {
        Navigator.pop(context, false);
      }
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _handleAccept() {
    if (!_hasAgreed) {
      PopUpPemberitahuan.warning(
        context,
        title: 'Agreement Required',
        message: 'Please check the agreement box before proceeding.',
      );
      return;
    }

    if (widget.onAccept != null) {
      widget.onAccept!();
    } else {
      Navigator.pop(context, true);
    }
  }

  void _handleDecline() {
    if (widget.onDecline != null) {
      widget.onDecline!();
    } else {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282D37),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header Bar
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.rSpacing(18),
                    context.rSpacing(14),
                    context.rSpacing(18),
                    context.rSpacing(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back / Close Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _handleCloseOrBack,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF323846),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF434A59).withValues(alpha: 0.5),
                                width: 0.8,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              widget.isFromRegister
                                  ? Icons.close_rounded
                                  : Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: widget.isFromRegister ? 18 : 15,
                            ),
                          ),
                        ),
                      ),

                      // Title
                      Expanded(
                        child: Text(
                          'Terms & Privacy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(15, min: 14, max: 17),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      // Version Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
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
                    ],
                  ),
                ),

                // 2. Title & System Subtitle
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rSpacing(18),
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
                          color: const Color(0xFF8E95A5),
                          fontSize: context.rFont(11.5, min: 10.5, max: 13),
                          fontFamily: 'Inter',
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.rSpacing(12)),

                // 3. Scrollable Document Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rSpacing(18),
                      vertical: context.rSpacing(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Terms Unified Card Container
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(context.rSpacing(16)),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E232E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF3B4150).withValues(alpha: 0.45),
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

                              // Academic Advisory Note Box
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  color: const Color(0xFF252A36),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          width: 3.5,
                                          color: const Color(0xFFFA6144),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.all(context.rSpacing(12)),
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'Academic Advisory Note: ',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        'Priority scores generated by the system serve solely as planning guidance. Students retain complete individual responsibility for meeting all submission deadlines set by course lecturers.',
                                                    style: TextStyle(
                                                      color: const Color(0xFF8E95A5),
                                                      fontSize: context.rFont(11, min: 10, max: 12),
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
                                title: '4. Team Collaboration Code of Conduct',
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

                        // Bottom Actions (Only for Register flow)
                        if (widget.isFromRegister) ...[
                          SizedBox(height: context.rSpacing(16)),

                          // Checkbox Agreement
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () {
                                setState(() => _hasAgreed = !_hasAgreed);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 19,
                                      height: 19,
                                      decoration: BoxDecoration(
                                        color: _hasAgreed
                                            ? const Color(0xFFFA6144)
                                            : const Color(0xFF2E3440),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: _hasAgreed
                                              ? const Color(0xFFFA6144)
                                              : const Color(0xFF4B5563),
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: _hasAgreed
                                          ? const Icon(
                                              Icons.check,
                                              size: 13,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'I have read and agree to the Terms of Service & Privacy Policy.',
                                        style: TextStyle(
                                          color: const Color(0xFFCBD5E1),
                                          fontSize: context.rFont(12, min: 11, max: 13.5),
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: context.rSpacing(14)),

                          // Action Buttons
                          Row(
                            children: [
                              // Decline Button
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 44,
                                  child: OutlinedButton(
                                    onPressed: _handleDecline,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF3B4150),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: const Color(0xFF2A2F3D),
                                    ),
                                    child: const Text(
                                      'Decline',
                                      style: TextStyle(
                                        color: Color(0xFFCBD5E1),
                                        fontSize: 13.5,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Accept & Continue Button
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: _handleAccept,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _hasAgreed
                                          ? AppColors.primary
                                          : const Color(0xFF333846),
                                      foregroundColor: _hasAgreed
                                          ? Colors.white
                                          : const Color(0xFF94A3B8),
                                      elevation: _hasAgreed ? 2 : 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Accept & Continue',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: _hasAgreed
                                                  ? Colors.white
                                                  : const Color(0xFF94A3B8),
                                              fontSize: 13.5,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 15,
                                          color: _hasAgreed
                                              ? Colors.white
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Footer Note
                        SizedBox(height: context.rSpacing(16)),
                        Center(
                          child: Text(
                            'IMPAL Group 7 • Telkom University © 2026',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontSize: context.rFont(10.5, min: 9.5, max: 12),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: context.rSpacing(16)),
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
            color: const Color(0xFFFA6144),
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
              color: Color(0xFF8E95A5),
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
