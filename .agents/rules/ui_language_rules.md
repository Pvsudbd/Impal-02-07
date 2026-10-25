# UI Language & Time Picker Design Rules

Whenever creating or modifying UI elements, widgets, dialogs, or text copy in the IMPAL application:

## 1. Universal English Language Standard
- **All User-Facing Copy in English**: All headers, titles, subtitles, button texts, tooltips, dialogs, form field labels, placeholder hints, error messages, and notification popups MUST be written in English.
- **Calendar & Days**:
  - Days of the week must strictly be in English: `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`, `Sunday`.
  - Date offsets must be in English: `Today`, `Tomorrow`, `Yesterday`.
- **System Defaults & Fallbacks**:
  - Default location names must be in English (e.g. `Classroom` instead of `Ruang Kelas`).
  - Section names must be in English (e.g. `Teams section` instead of `Kelompok section`).

---

## 2. Bespoke Time Picker (`ImpalTimePickerDialog`) Rules
- **Color Palette & Soft Grey Transitions**:
  - Dialog outer container: `Color(0xFF282D37)` with soft border `Color(0xFF3B4150)`.
  - Inner containers (Dial clock face background, Mode toggle, Ketik time display boxes, Preset chips, and Cancel button):
    - All share the consistent surrounding soft grey: `Color(0xFF282D37)` with border `Color(0xFF3B4150)`.
    - **Forbidden**: Do NOT use contrasting jet-black surfaces like `Color(0xFF1E222B)` or pitch-black cutouts; the transition from the outer dialog to inner interactive areas must remain smooth, soft, and harmonious.
  - Active selection highlight: Coral `Color(0xFFFA6144)`.

- **Clean Titles Without Suffixes**:
  - Dialog titles must be concise English action phrases: e.g. `'Select Start Time'`, `'Select End Time'`, or `'Select Time'`.
  - Never append format tags or suffixes such as `"(24.00)"` or `"(24:00)"` to the title string.

- **Mode Toggle Button (Top Right)**:
  - Must remain **strictly icon-only**.
  - Dimensions: `width: 32`, `height: 32`, `borderRadius: BorderRadius.circular(8)`.
  - Background: `Color(0xFF282D37)`, border: `1px solid Color(0xFF3B4150)`.
  - Icon: `Icons.keyboard_alt_outlined` (in Dial mode) and `Icons.access_time_rounded` (in Ketik mode), size `17`, color `Color(0xFFFA6144)`.
  - **Forbidden**: Do NOT place text labels such as `"Ketik"` or `"Roda"` beside the icon.

- **Ketik Mode: Single Unified Minimalist Time Card**:
  - **Single Unified Container**: In Ketik mode, there is only ONE time container on screen (`[ Hour ] : [ Minute ]`). Never duplicate the time display between a top card and a bottom input section.
  - **Direct Typing & Scroll Support**:
    - Users can tap directly on the hour or minute box to type numbers via on-screen or physical keyboard.
    - Users can vertically drag / mouse wheel scroll on the box:
      - Scrolling / dragging UP: Decreases value (`makin kecil`, e.g. 08 -> 07).
      - Scrolling / dragging DOWN: Increases value (`makin besar`, e.g. 08 -> 09).
  - **No Up/Down Arrow Buttons**: Arrow buttons are completely eliminated in favor of direct scrolling and typing.

- **Action Buttons**:
  - Dismiss: `'Cancel'` with `Color(0xFF8E95A5)` text and soft slate background `Color(0xFF282D37)` with border `Color(0xFF3B4150)`.
  - Confirm: `'Done'` with white text and coral button `Color(0xFFFA6144)`.
