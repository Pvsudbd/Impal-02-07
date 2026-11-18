class AuthenticationForgatPassword extends StatelessWidget {
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
                      width: 440,
                      height: 689.38,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 24,
                            child: Container(
                              width: 440,
                              height: 167.88,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 188,
                                    top: 0,
                                    child: Container(
                                      width: 58,
                                      height: 60,
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 58,
                                            height: 58,
                                            padding: const EdgeInsets.only(top: 13, bottom: 14),
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFFA6144) /* Primary */,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18),
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
                                              children: [
                                                Container(
                                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(2.46),
                                                  width: 40,
                                                  height: 40,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(),
                                                  child: Stack(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 82,
                                    child: SizedBox(
                                      width: 440,
                                      height: 32,
                                      child: Text(
                                        'Forgot Password?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w800,
                                          height: 1.14,
                                          letterSpacing: -0.70,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 50,
                                    top: 124,
                                    child: SizedBox(
                                      width: 340,
                                      child: Text(
                                        'Enter your registered Student ID or campus email to receive password reset instructions.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF8E95A5),
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.62,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 220.19,
                            child: Container(
                              width: 440,
                              height: 405,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 18,
                                children: [
                                  SizedBox(
                                    width: 440,
                                    height: 16,
                                    child: Text(
                                      'Email',
                                      style: TextStyle(
                                        color: const Color(0xFFCBD5E1),
                                        fontSize: 12,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w600,
                                        height: 1.33,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 12,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
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
                                                        SizedBox(
                                                          width: 378,
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
                                  Container(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      spacing: 18,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFF323846),
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 1,
                                                color: const Color(0xFF3B4150),
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 12,
                                            children: [
                                              Container(
                                                width: 16,
                                                height: 16,
                                                decoration: ShapeDecoration(
                                                  color: const Color(0xFF323846),
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                      width: 1,
                                                      color: const Color(0xFF6B7280),
                                                    ),
                                                    borderRadius: BorderRadius.circular(50),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  spacing: 2,
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(
                                                            width: 350,
                                                            child: Text(
                                                              'Send to Email',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
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
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(
                                                            width: 350,
                                                            child: Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text: 'Link dispatched to Yog••••••••••••.',
                                                                    style: TextStyle(
                                                                      color: const Color(0xFF8E95A5),
                                                                      fontSize: 11,
                                                                      fontFamily: 'Inter',
                                                                      fontWeight: FontWeight.w400,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: 'com',
                                                                    style: TextStyle(
                                                                      color: const Color(0xFF8E95A5),
                                                                      fontSize: 12,
                                                                      fontFamily: 'Inter',
                                                                      fontWeight: FontWeight.w400,
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
                                                width: 20,
                                                height: 20,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Stack(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFF323846),
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 1,
                                                color: const Color(0xFF3B4150),
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 12,
                                            children: [
                                              Container(
                                                width: 16,
                                                height: 16,
                                                decoration: ShapeDecoration(
                                                  color: const Color(0xFF323846),
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                      width: 1,
                                                      color: const Color(0xFF6B7280),
                                                    ),
                                                    borderRadius: BorderRadius.circular(50),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  spacing: 2,
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(
                                                            width: 350,
                                                            child: Text(
                                                              'Send 6-Digit Code via SMS',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
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
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(
                                                            width: 350,
                                                            child: Text(
                                                              'Dispatched to +62 812••••••••8904',
                                                              style: TextStyle(
                                                                color: const Color(0xFF8E95A5),
                                                                fontSize: 12,
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
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(1),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xE6323846),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: Colors.white.withValues(alpha: 0.05),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 12,
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 67,
                                          decoration: BoxDecoration(color: const Color(0xFFF26444)),
                                        ),
                                        Container(
                                          width: 14,
                                          height: 14,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(),
                                          child: Stack(),
                                        ),
                                        SizedBox(
                                          width: 370,
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Important: ',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.58,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: 'Recovery links remain valid for ',
                                                  style: TextStyle(
                                                    color: const Color(0xFF94A3B8),
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.58,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '5 minutes ',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.58,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '. If you cannot locate the message, check your Junk/Spam folder. ',
                                                  style: TextStyle(
                                                    color: const Color(0xFF94A3B8),
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.58,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 48,
                                    decoration: ShapeDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment(0.15, 0.15),
                                        end: Alignment(0.85, 0.85),
                                        colors: [const Color(0xFFF4694A), const Color(0xFFEB5735)],
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      shadows: [
                                        BoxShadow(
                                          color: Color(0x8CF26444),
                                          blurRadius: 25,
                                          offset: Offset(0, 8),
                                          spreadRadius: -4,
                                        )
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 145.34,
                                          top: 14,
                                          child: SizedBox(
                                            width: 150,
                                            height: 20,
                                            child: Text(
                                              'Send Recovery Code',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                                height: 1.43,
                                                letterSpacing: 0.35,
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
                          ),
                          Positioned(
                            left: 0,
                            top: 649.38,
                            child: Container(
                              width: 440,
                              height: 16,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 113,
                                    top: -0.50,
                                    child: SizedBox(
                                      width: 172,
                                      height: 16,
                                      child: Text(
                                        'Remembered your password?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF8E95A5),
                                          fontSize: 12,
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 289,
                                    top: -0.50,
                                    child: Text(
                                      'Sign In',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFFF26444),
                                        fontSize: 11.69,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        height: 1.37,
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