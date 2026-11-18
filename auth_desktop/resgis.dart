class AuthenticationRegister extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 1440,
          height: 1024,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 864,
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, 0.50),
                    end: Alignment(1.00, 0.50),
                    colors: [Colors.white.withValues(alpha: 0.03) /* color-white--3% */, Colors.white.withValues(alpha: 0) /* color-white--0% */],
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.06) /* color-white--6% */,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: -96,
                      top: -96,
                      child: Opacity(
                        opacity: 0.20,
                        child: Container(
                          width: 480,
                          height: 480,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF26444) /* color-red-61 */,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 591.41,
                      top: 800.58,
                      child: Opacity(
                        opacity: 0.10,
                        child: Container(
                          width: 315,
                          height: 325.82,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF6366F1) /* color-blue-67 */,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 489.57,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 16,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: ShapeDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(0.00, 0.00),
                                    end: Alignment(1.00, 1.00),
                                    colors: [const Color(0xFFFF6B4A) /* color-red-65 */, const Color(0xFFF26444) /* color-red-61 */],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: Colors.white.withValues(alpha: 0.15) /* color-white--15% */,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: ShapeDecoration(
                                          color: Colors.white.withValues(alpha: 0) /* color-white--0_2% */,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          shadows: [
                                            BoxShadow(
                                              color: Color(0x7FF26444),
                                              blurRadius: 30,
                                              offset: Offset(0, 10),
                                              spreadRadius: -5,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                            spreadRadius: 0,
                                          )BoxShadow(
                                            color: Color(0x0F000000),
                                            blurRadius: 1,
                                            offset: Offset(0, 1),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              width: 24,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(),
                                              child: Stack(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Smart Task Manager',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.56,
                                          letterSpacing: -0.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AI Academic Ecosystem',
                                          style: TextStyle(
                                            color: const Color(0xFF8E95A5),
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.33,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 672, minHeight: 593.38),
                        child: Container(
                          width: 672,
                          padding: const EdgeInsets.symmetric(vertical: 258.81),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 672),
                                child: Container(
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 16,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: ShapeDecoration(
                                          color: const Color(0x19F26444) /* color-red-61-10% */,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: const Color(0x3FF26444) /* color-red-61-25% */,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          spacing: 8,
                                          children: [
                                            Container(
                                              width: 14,
                                              height: 14,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(),
                                              child: Stack(),
                                            ),
                                            Text(
                                              'INTELLIGENT DECISION SUPPORT',
                                              style: TextStyle(
                                                color: const Color(0xFFFF6B4A) /* color-red-65 */,
                                                fontSize: 12,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                                height: 1.33,
                                                letterSpacing: 0.30,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 672,
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'AI-Driven Academic Task &\nSchedule ',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 40,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w800,
                                                        height: 1.18,
                                                        letterSpacing: -1,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: 'Prioritization System',
                                                      style: TextStyle(
                                                        color: const Color(0xFFFF6B4A),
                                                        fontSize: 40,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w800,
                                                        height: 1.18,
                                                        letterSpacing: -1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: 576),
                                        child: Container(
                                          width: 576,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Automatically rank coursework deadlines, lab deliverables, and group\nsprints using real-time weight analysis, credit load, and personal energy\nwindows.',
                                                style: TextStyle(
                                                  color: const Color(0xFF8E95A5),
                                                  fontSize: 16,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.50,
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.06) /* color-white--6% */,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 526.92,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'IMPAL Group 7 • Telkom University © 2026',
                                style: TextStyle(
                                  color: const Color(0xFF8E95A5),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.33,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 20,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 6,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFF26444) /* color-red-61 */,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Fuzzy-AHP Engine',
                                    style: TextStyle(
                                      color: const Color(0xFF8E95A5),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.33,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bandung, Indonesia',
                                    style: TextStyle(
                                      color: const Color(0xFF8E95A5),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.33,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 576,
                height: 1024,
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
                decoration: BoxDecoration(color: const Color(0xFF282D37)),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 40,
                      padding: const EdgeInsets.only(top: 7, left: 439.56, bottom: 7),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: ShapeDecoration(
                              color: Colors.white.withValues(alpha: 0.04) /* color-white--4% */,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Colors.white.withValues(alpha: 0.07) /* color-white--7% */,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Authentication page',
                                  style: TextStyle(
                                    color: const Color(0xFFD1D5DB) /* color-azure-84 */,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.33,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 9,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 2.90,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 416,
                                              child: Text(
                                                'Create Account',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -0.50,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.only(bottom: 0.69),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 416,
                                              child: Text(
                                                'Register your student identity for smart academic\nprioritization.',
                                                style: TextStyle(
                                                  color: const Color(0xFF8E95A5),
                                                  fontSize: 12,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.40,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 14),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 12,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 5,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 416,
                                                    child: Text(
                                                      'Full Name',
                                                      style: TextStyle(
                                                        color: const Color(0xFFD1D5DB),
                                                        fontSize: 12,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      height: 48,
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14.50),
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF323846),
                                                        shape: RoundedRectangleBorder(
                                                          side: BorderSide(
                                                            width: 1,
                                                            color: const Color(0xFF323846),
                                                          ),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 4,
                                                        children: [
                                                          Container(
                                                            width: 20,
                                                            height: 20,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Stack(),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              clipBehavior: Clip.antiAlias,
                                                              decoration: BoxDecoration(),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  SizedBox(
                                                                    width: 370,
                                                                    child: Text(
                                                                      'Yoga Perkakas',
                                                                      style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 14,
                                                                        fontFamily: 'Inter',
                                                                        fontWeight: FontWeight.w400,
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
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 5,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 416,
                                                    child: Text(
                                                      'Email',
                                                      style: TextStyle(
                                                        color: const Color(0xFFD1D5DB),
                                                        fontSize: 12,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      height: 48,
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14.50),
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF323846),
                                                        shape: RoundedRectangleBorder(
                                                          side: BorderSide(
                                                            width: 1,
                                                            color: const Color(0xFF323846),
                                                          ),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 4,
                                                        children: [
                                                          Container(
                                                            width: 20,
                                                            height: 20,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Stack(),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              clipBehavior: Clip.antiAlias,
                                                              decoration: BoxDecoration(),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  SizedBox(
                                                                    width: 370,
                                                                    child: Text(
                                                                      'YogaPerkakas@gmail.com',
                                                                      style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 14,
                                                                        fontFamily: 'Inter',
                                                                        fontWeight: FontWeight.w400,
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
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 5,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 416,
                                                    child: Text(
                                                      'Password',
                                                      style: TextStyle(
                                                        color: const Color(0xFFD1D5DB),
                                                        fontSize: 12,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      height: 48,
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14.50),
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF323846),
                                                        shape: RoundedRectangleBorder(
                                                          side: BorderSide(
                                                            width: 1,
                                                            color: const Color(0xFF323846),
                                                          ),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              spacing: 4,
                                                              children: [
                                                                Container(
                                                                  width: 20,
                                                                  height: 20,
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                  child: Stack(),
                                                                ),
                                                                Container(
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 95,
                                                                        child: Text(
                                                                          '••••••••••••',
                                                                          style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontSize: 14,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w400,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 20,
                                                            height: 20,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Stack(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFF2D333F),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: Colors.white.withValues(alpha: 0.04),
                                            ),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 10,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 117.05,
                                                children: [
                                                  Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'PASSWORD STRENGTH',
                                                        style: TextStyle(
                                                          color: const Color(0xFF8E95A5),
                                                          fontSize: 11,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w600,
                                                          letterSpacing: 0.30,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Strong (92%)',
                                                        style: TextStyle(
                                                          color: const Color(0xFF6EE7B7),
                                                          fontSize: 11,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              height: 5,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF3F4756),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(99),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 3,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      height: double.infinity,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF10B981),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(99),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      height: double.infinity,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF10B981),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(99),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      height: double.infinity,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF10B981),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(99),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      height: double.infinity,
                                                      decoration: ShapeDecoration(
                                                        color: const Color(0xFF10B981),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(99),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 6,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      spacing: 8,
                                                      children: [
                                                        Container(
                                                          width: 16,
                                                          height: 16,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(0x3310B981),
                                                            shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 1,
                                                                color: const Color(0x6610B981),
                                                              ),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Container(
                                                                width: 10,
                                                                height: 10,
                                                                clipBehavior: Clip.antiAlias,
                                                                decoration: BoxDecoration(),
                                                                child: Stack(),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'At least 8 characters long (recommended 12+)',
                                                              style: TextStyle(
                                                                color: const Color(0xFFD1D5DB),
                                                                fontSize: 11,
                                                                fontFamily: 'Inter',
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      spacing: 8,
                                                      children: [
                                                        Container(
                                                          width: 16,
                                                          height: 16,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(0x3310B981),
                                                            shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 1,
                                                                color: const Color(0x6610B981),
                                                              ),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Container(
                                                                width: 10,
                                                                height: 10,
                                                                clipBehavior: Clip.antiAlias,
                                                                decoration: BoxDecoration(),
                                                                child: Stack(),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Includes uppercase & lowercase letters',
                                                              style: TextStyle(
                                                                color: const Color(0xFFD1D5DB),
                                                                fontSize: 11,
                                                                fontFamily: 'Inter',
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      spacing: 8,
                                                      children: [
                                                        Container(
                                                          width: 16,
                                                          height: 16,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(0x3310B981),
                                                            shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 1,
                                                                color: const Color(0x6610B981),
                                                              ),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Container(
                                                                width: 10,
                                                                height: 10,
                                                                clipBehavior: Clip.antiAlias,
                                                                decoration: BoxDecoration(),
                                                                child: Stack(),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          padding: const EdgeInsets.only(right: 16.06),
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'Includes at least one number and special symbol (#, !,\n@)',
                                                                style: TextStyle(
                                                                  color: const Color(0xFFD1D5DB),
                                                                  fontSize: 11,
                                                                  fontFamily: 'Inter',
                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 5,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(horizontal: 2),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                          width: 412,
                                                          child: Text(
                                                            'CONFIRM NEW PASSWORD',
                                                            style: TextStyle(
                                                              color: const Color(0xFF9CA3AF),
                                                              fontSize: 11.50,
                                                              fontFamily: 'Inter',
                                                              fontWeight: FontWeight.w600,
                                                              letterSpacing: 0.40,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              height: 48,
                                              padding: const EdgeInsets.symmetric(horizontal: 14),
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF323846),
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 1,
                                                    color: const Color(0x6610B981),
                                                  ),
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 12,
                                                children: [
                                                  Container(
                                                    width: 20,
                                                    height: 20,
                                                    clipBehavior: Clip.antiAlias,
                                                    decoration: BoxDecoration(),
                                                    child: Stack(),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration: BoxDecoration(),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            width: double.infinity,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  width: 281,
                                                                  child: Text(
                                                                    'YogaCerdas#2026!',
                                                                    style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: 13.50,
                                                                      fontFamily: 'Inter',
                                                                      fontWeight: FontWeight.w500,
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
                                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                    decoration: ShapeDecoration(
                                                      color: const Color(0x2D10B981),
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 1,
                                                          color: const Color(0x5910B981),
                                                        ),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      spacing: 4,
                                                      children: [
                                                        Container(
                                                          width: 10,
                                                          height: 10,
                                                          clipBehavior: Clip.antiAlias,
                                                          decoration: BoxDecoration(),
                                                          child: Stack(),
                                                        ),
                                                        Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Match',
                                                              style: TextStyle(
                                                                color: const Color(0xFF6EE7B7),
                                                                fontSize: 10,
                                                                fontFamily: 'Inter',
                                                                fontWeight: FontWeight.w700,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 8,
                                                children: [
                                                  Container(
                                                    width: 16,
                                                    height: 16,
                                                    child: Stack(
                                                      children: [
                                                        Positioned(
                                                          left: 0,
                                                          top: 0,
                                                          child: Container(
                                                            width: 16,
                                                            height: 16,
                                                            decoration: ShapeDecoration(
                                                              color: const Color(0xFF323846),
                                                              shape: RoundedRectangleBorder(
                                                                side: BorderSide(
                                                                  width: 1,
                                                                  color: const Color(0xFF6B7280),
                                                                ),
                                                                borderRadius: BorderRadius.circular(2.50),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 277,
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      spacing: 4.80,
                                                      children: [
                                                        Container(
                                                          width: double.infinity,
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            spacing: 3.50,
                                                            children: [
                                                              Text(
                                                                'I agree to the ',
                                                                style: TextStyle(
                                                                  color: const Color(0xFF8E95A5),
                                                                  fontSize: 11,
                                                                  fontFamily: 'Inter',
                                                                  fontWeight: FontWeight.w400,
                                                                  height: 1.40,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Terms of Service',
                                                                style: TextStyle(
                                                                  color: const Color(0xFFFF7D65),
                                                                  fontSize: 11,
                                                                  fontFamily: 'Inter',
                                                                  fontWeight: FontWeight.w400,
                                                                  height: 1.40,
                                                                ),
                                                              ),
                                                              Text(
                                                                'and acknowledge the',
                                                                style: TextStyle(
                                                                  color: const Color(0xFF8E95A5),
                                                                  fontSize: 11,
                                                                  fontFamily: 'Inter',
                                                                  fontWeight: FontWeight.w400,
                                                                  height: 1.40,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: 'Privacy Policy',
                                                                style: TextStyle(
                                                                  color: const Color(0xFFFF7D65),
                                                                  fontSize: 11,
                                                                  fontFamily: 'Inter',
                                                                  fontWeight: FontWeight.w400,
                                                                  height: 1.40,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: '.',
                                                                style: TextStyle(
                                                                  color: const Color(0xFF8E95A5),
                                                                  fontSize: 11,
                                                                  fontFamily: 'Inter',
                                                                  fontWeight: FontWeight.w400,
                                                                  height: 1.40,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 50,
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              height: 46,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFFA6144) /* Primary */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                shadows: [
                                                  BoxShadow(
                                                    color: Color(0x59EF4444),
                                                    blurRadius: 18,
                                                    offset: Offset(0, 8),
                                                    spreadRadius: 0,
                                                  )
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 6.01,
                                                children: [
                                                  Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        'Create Student Account',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.only(bottom: 1),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          '➔',
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontFamily: 'Inter',
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 17,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 331.04,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Protected by Telkom University Academic Auth',
                                style: TextStyle(
                                  color: const Color(0xB28E95A5) /* color-azure-60-70% */,
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'v2.4.0',
                                style: TextStyle(
                                  color: const Color(0xB28E95A5) /* color-azure-60-70% */,
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 319,
                      top: 3,
                      child: Container(
                        width: 256,
                        height: 256,
                        decoration: ShapeDecoration(
                          color: const Color(0x19F26444) /* color-red-61-10% */,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}