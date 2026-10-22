import 'package:flutter/material.dart';
import '../../../core/utils/top_toast.dart';

class TermsPrivacyPage extends StatefulWidget {
  const TermsPrivacyPage({super.key});

  @override
  State<TermsPrivacyPage> createState() => _TermsPrivacyPageState();
}

class _TermsPrivacyPageState extends State<TermsPrivacyPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _hasAgreed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent <= 10) {
        // If content fits completely on large screens without scrolling
        setState(() => _hasScrolledToBottom = true);
      }
    });
  }

  void _onScroll() {
    if (!_hasScrolledToBottom && _scrollController.hasClients) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 40) {
        setState(() => _hasScrolledToBottom = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  void _onAccept() {
    if (!_hasScrolledToBottom) {
      showTopToast(
        context,
        'Please scroll and read all the terms down to the bottom first.',
        type: ToastType.warning,
      );
      return;
    }
    if (!_hasAgreed) {
      showTopToast(
        context,
        'Please check the agreement box first.',
        type: ToastType.error,
      );
      return;
    }
    Navigator.pop(context, true);
  }

  void _onDecline() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282D37),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _onDecline,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF323846),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        'Terms & Privacy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: _hasScrolledToBottom ? const Color(0x2610B981) : const Color(0x26F59E0B),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _hasScrolledToBottom ? const Color(0x4C10B981) : const Color(0x4CF59E0B)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _hasScrolledToBottom ? Icons.check_circle_outline_rounded : Icons.arrow_downward_rounded,
                              size: 12,
                              color: _hasScrolledToBottom ? const Color(0xFF6EE7B7) : const Color(0xFFFBBF24),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _hasScrolledToBottom ? 'Read Complete' : 'Scroll to Read',
                              style: TextStyle(
                                color: _hasScrolledToBottom ? const Color(0xFF6EE7B7) : const Color(0xFFFBBF24),
                                fontSize: 11,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Title & Subtitle Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms of Service & Privacy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'IMPAL Smart Task & Schedule Prioritization System • Telkom University',
                        style: TextStyle(
                          color: Color(0xFF8E95A5),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFF3B4150)),

                // Scrollable Content directly on page (No card container)
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          title: '1. Acceptance of Terms',
                          content:
                              'By creating an account, registering your student credentials, or connecting through Telkom University Single Sign-On (SSO), you agree to comply with and be bound by these Terms of Service and all applicable university academic policies.',
                        ),
                        const SizedBox(height: 18),

                        _buildSection(
                          title: '2. AI-Driven Recommendation Core',
                          content:
                              'IMPAL integrates a Mamdani Fuzzy Inference System that analyzes deadline proximity, syllabus grade weight, and complexity to compute a crisp recommendation score (0–100).',
                        ),
                        const SizedBox(height: 10),

                        // Advisory Note Box
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            color: const Color(0xFF1F242F),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    width: 3.5,
                                    color: const Color(0xFFFA6144),
                                  ),
                                  const Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
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
                                                color: Color(0xFF8E95A5),
                                                fontSize: 11,
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
                        const SizedBox(height: 18),

                        _buildSection(
                          title: '3. Student Privacy & SSO Data Security',
                          content:
                              'We collect and process your Student ID (NIM), registered university email, academic program, and course schedules synchronized via the Central Authentication Service (CAS).',
                        ),
                        const SizedBox(height: 6),
                        _buildBullet('All student credential exchanges use TLS 1.3 protocol encryption.'),
                        _buildBullet('Data is restricted exclusively to task calculation and timetable syncing.'),
                        _buildBullet('Student records are never sold, rented, or distributed to commercial parties.'),
                        const SizedBox(height: 18),

                        _buildSection(
                          title: '4. Team Collaboration Code of Conduct',
                          content: 'When participating in team workspaces (Group Projects):',
                        ),
                        const SizedBox(height: 6),
                        _buildBullet('Do not delete or alter task items assigned to other team members without mutual agreement.'),
                        _buildBullet('Keep 4-character team join codes confidential within your designated project group.'),
                        _buildBullet('Observe the Telkom University Academic Honor Code in all shared group deliverables.'),
                        const SizedBox(height: 18),

                        _buildSection(
                          title: '5. Algorithm Explainability (XAI) Rights',
                          content:
                              'Users possess the explicit right to inspect how priorities were deduced through the Explainability Modal, detailing membership degrees, fired fuzzy rules, and centroid calculation formulas.',
                        ),
                        const SizedBox(height: 18),

                        _buildSection(
                          title: '6. Termination & Account Unlinking',
                          content:
                              'Students may unlink their Telkom SSO account, clear local cached schedules, or request full task catalog deletion upon semester completion.',
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1, color: Color(0xFF3B4150)),

                // Bottom Action Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Quick Scroll to bottom button if not reached yet
                      if (!_hasScrolledToBottom)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: _scrollToBottom,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF323846),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF4B5563)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFFFA6144)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Scroll down to read all terms',
                                    style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 11.5, fontFamily: 'Inter', fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Checkbox Agreement
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () {
                          if (!_hasScrolledToBottom) {
                            showTopToast(
                              context,
                              'Please scroll and read all the terms down to the bottom first.',
                              type: ToastType.warning,
                            );
                            return;
                          }
                          setState(() => _hasAgreed = !_hasAgreed);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: _hasAgreed
                                      ? const Color(0xFFFA6144)
                                      : _hasScrolledToBottom
                                          ? const Color(0xFF323846)
                                          : const Color(0xFF222630),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: _hasAgreed
                                        ? const Color(0xFFFA6144)
                                        : _hasScrolledToBottom
                                            ? const Color(0xFF4B5563)
                                            : const Color(0xFF374151),
                                    width: 1.5,
                                  ),
                                ),
                                child: _hasAgreed
                                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                                    : !_hasScrolledToBottom
                                        ? const Icon(Icons.lock_outline_rounded, size: 11, color: Color(0xFF6B7280))
                                        : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _hasScrolledToBottom
                                      ? 'I have read and agree to the Terms of Service & Privacy Policy.'
                                      : 'Read all the way to the bottom to unlock agreement.',
                                  style: TextStyle(
                                    color: _hasScrolledToBottom ? const Color(0xFFD1D5DB) : const Color(0xFF8E95A5),
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: _hasScrolledToBottom ? FontWeight.w500 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: OutlinedButton(
                                onPressed: _onDecline,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF3B4150)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  backgroundColor: const Color(0xFF323846),
                                ),
                                child: const Text(
                                  'Decline',
                                  style: TextStyle(
                                    color: Color(0xFFD1D5DB),
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: (_hasScrolledToBottom && _hasAgreed) ? _onAccept : _onAccept,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: (_hasScrolledToBottom && _hasAgreed) ? const Color(0xFFFA6144) : const Color(0xFF323846),
                                  elevation: (_hasScrolledToBottom && _hasAgreed) ? 4 : 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Accept & Continue',
                                      style: TextStyle(
                                        color: (_hasScrolledToBottom && _hasAgreed) ? Colors.white : const Color(0xFF9CA3AF),
                                        fontSize: 13,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 15,
                                      color: (_hasScrolledToBottom && _hasAgreed) ? Colors.white : const Color(0xFF9CA3AF),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Footer
                      const Text(
                        'IMPAL Group 7 • Telkom University © 2026',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 10,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFA6144),
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            color: Color(0xFFD1D5DB),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFA6144),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFD1D5DB),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alias for backwards compatibility
typedef TermsPrivacy = TermsPrivacyPage;
