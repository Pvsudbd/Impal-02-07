# Header & Back Button Design Rules

Whenever creating or modifying pages in the IMPAL frontend:
1. **Header Consistency**:
   - Headers across tabs/pages (Dashboard, Schedule, Team List, etc.) MUST be unified in layout, height, typography, and spacing.
   - Title: `fontSize: 22`, `FontWeight.w700`, `letterSpacing: -0.3`, `height: 1.2`, color `Colors.white`, text `'Hi <userName>'`.
   - Subtitle: `fontSize: 12.5`, `FontWeight.w600`, `letterSpacing: 0.15`, color `Color(0xFFFF7D65)`.
   - Vertical gap between title and subtitle: `3px` (`SizedBox(height: 3)`).
   - Bottom gap below header: `16px` (`SizedBox(height: 16)`).

2. **Square Back Button**:
   - Back buttons MUST NOT be circular. They must be a **rounded square** (`38px` × `38px`, `BorderRadius.circular(10)`).
   - Background: `Color(0xFF323846)`, border: `Border.all(color: Color(0xFF3B4150), width: 1)`.
   - Icon: `Icons.arrow_back_ios_new_rounded`, size `16`, color `Colors.white`.
   - Gap between back button and title text: `12px` (`SizedBox(width: 12)`).

3. **User Avatar**:
   - Right side avatar container: `42px` × `42px`, `shape: BoxShape.circle`.
   - Background: `Color(0xFF323846)`, border: `Border.all(color: Color(0xFF3B4150), width: 1)`.
   - Initials: `fontSize: 13.5`, `FontWeight.w700`, `letterSpacing: 0.2`, color `Color(0xFF8E95A5)`.
