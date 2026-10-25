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

---

## 3. Bespoke Date Picker (`ImpalDatePickerDialog`) Rules
- **No Day-Month-Date Banner**:
  - The bulky top header displaying the day of week, month, and date (e.g. `"SELECT DATE \n Fri, Oct 25"`) is completely eliminated.
  - The dialog opens directly with a clean, concise title (e.g. `'Select Date'`) and quick `'Today'` shortcut.
- **Seamless Connected Month & Year (No Boxed Containers)**:
  - The month and year are displayed seamlessly side-by-side as natural continuous typography (e.g. `"October 2026"`), rather than separated inside isolated box containers.
  - **Tapping the Month Word** (e.g. `'October'`): Switches directly to a 12-month selector grid (`Jan`..`Dec`) so the user can change the month immediately with one tap.
  - **Tapping the Year Word** (e.g. `'2026'`): Switches directly to a scrollable year selector grid so the user can change the year immediately with one tap.
  - When active, the selected word is highlighted in Coral `Color(0xFFFA6144)` with an underline indicator.
  - Previous (`<`) and Next (`>`) arrows on the right allow sequential navigation between adjacent months/years.
- **Harmonized Soft Grey Surfaces**:
  - Container background: `Color(0xFF282D37)` with border `Color(0xFF3B4150)`.
  - Selected day highlight: Circle in Coral `Color(0xFFFA6144)` with bold white text.
  - Current day (*Today*): Indicated with a subtle Coral border outline when unselected.
- **Action Buttons**:
  - Dismiss: `'Cancel'` with `Color(0xFF8E95A5)` text, background `Color(0xFF282D37)`, border `Color(0xFF3B4150)`.
  - Confirm: `'Done'` with white text and coral button `Color(0xFFFA6144)`.

---

## 4. Automatic Schedule Status Determination Rules
- **Automatic Status Calculation**:
  - The status of any schedule must be calculated automatically based on current date and real-time clock:
    - **Ongoing**: When the current date & time falls within `[startDateTime, endDateTime]` (e.g. today during lecture/event hours).
    - **Upcoming**: When the schedule start date & time has not yet arrived (`now < startDateTime`).
    - **Completed**: When the schedule end date & time has already passed (`now > endDateTime`).
- **Visual Color Representation**:
  - **Ongoing**: Coral accent `Color(0xFFFF826E)` (pill badge, border highlight, and icons).
  - **Completed**: Emerald green accent `Color(0xFF10B981)` (pill badge, border highlight, and icons).
  - **Upcoming**: Slate grey accent `Color(0xFF8E95A5)` with background `Color(0xFF3B4150)`.
- **Dynamic Calculation in Models & Forms**:
  - In `ScheduleModel`, the `status` getter computes dynamically using `calculateStatus(...)` so schedules automatically transition as real time passes.
  - In `EditSchedule` and `AddNewSchedule`, selecting or modifying date/time immediately recalculates and reflects the new automatic status with an `'Auto-determined'` indicator.

---

## 5. Home Page Today's Schedule Carousel Ordering & Focus Rules
- **Chronological & Status Ordering**:
  - Today's schedules in `HomePage` must strictly be arranged in the sequence: `Completed` -> `Ongoing` -> `Upcoming` (and within each status group, sorted chronologically by start time).
- **Initial Focus on Ongoing**:
  - When the user opens the Home page, the horizontal carousel must automatically focus/scroll to the currently active (`Ongoing`) schedule card.
  - The user can scroll to the left to view past `Completed` schedules.
  - The user can scroll to the right to view future `Upcoming` schedules.
  - If there is no `Ongoing` schedule currently active, it focuses on the first `Upcoming` schedule (or index 0).

---

## 6. Schedule Form Architecture & Layout Rules (`ScheduleFormPage`, `AddNewSchedule`, & `EditSchedule`)
- **Unified Single Form Component (`ScheduleFormPage`)**:
  - `AddNewSchedule` and `EditSchedule` delegate directly to a single, unified `ScheduleFormPage` component with dual-mode support (`schedule == null` for Add, `schedule != null` for Edit).
- **Unified Course / Title Field (Single Controller for DB Simplicity)**:
  - Course (for Lecture) and Schedule Title (for External) share the **exact same text controller** (`_titleController`), adapting dynamically:
    - **When Lecture**: Label displays as **"Course"**, Hint is `'e.g. SSIF-04-REG • Software Testing & Implementation'`, Icon is `Icons.school_outlined`.
    - **When External**: Label displays as **"Schedule Title"**, Hint is `'e.g. Meet Impal Kelompok 7'`, Icon is `Icons.menu_book_rounded`.
    - **Database Mapping**: The value is saved directly to `title`, and duplicated to `course` when type is `Lecture`, keeping database structures clean and seamless without dual controllers.
- **Conditional Date Picker on Repeat Weekly**:
  - When **Repeat Weekly** is enabled (`true`), the **"Date"** picker section is **completely hidden** (no date selection required).
  - When Repeat Weekly is disabled (`false`), the **"Date"** picker appears seamlessly in the form.
- **Strict Form Sequence**:
  1. Schedule Type (`Lecture` / `External`)
  2. Course (if Lecture) OR Schedule Title (if External)
  3. Location / Room
  4. Repeat Weekly Switch
  5. Date Picker (only if Repeat Weekly is OFF)
  6. Time Duration (Start Time - End Time)
  7. Notes (Optional)
  8. Submit / Save Changes Button
  *(Note: The manual/chip status selector is completely eliminated from EditSchedule because schedule status is fully automated by ScheduleModel based on real-time clock and schedule dates).*
- **Unified Control Sizing & Spacing**:
  - **Single-row Controls Height**: All single-row containers and controls MUST have a unified height of **48px**:
    - Type selection buttons: `height: 48`.
    - Single-line TextFields: `isDense: true` with `contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14)`.
    - Date picker container: `height: 48` with `padding: EdgeInsets.symmetric(horizontal: 14)`.
    - Time duration containers: `height: 48` with `padding: EdgeInsets.symmetric(horizontal: 14)`.
    - Repeat Weekly container: `height: 48` with `padding: EdgeInsets.symmetric(horizontal: 14)`.
    - Action buttons: `height: 48`.
  - **Repeat Weekly Switch**: To prevent the switch container from bulging larger than other fields, use:
    - `Transform.scale(scale: 0.82)`
    - `materialTapTargetSize: MaterialTapTargetSize.shrinkWrap`
  - **Standard Spacing**:
    - Gap between label and input control: `height: 8`.
    - Gap between form sections: `height: 16`.
    - Gap before submit button: `height: 24`.

