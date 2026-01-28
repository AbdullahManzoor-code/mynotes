# MyNotes

## 📚 Feature Documentation
- 🔔 [Reminders & Alarms](docs/reminders.md)
- ✅ [Todo Tasks](docs/todo_tasks.md)
- 📝 [Notes (Text, Audio, Video)](docs/notes.md)
- 🧠 [Ask Yourself](docs/ask_yourself.md)

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
Here is a comprehensive **Feature Checklist / Specification Document** for the MyNotes app development. Use this for tracking implementation, QA testing, and sprint planning.

---

# ✅ MyNotes App - Feature Checklist & Specification

## 📋 Legend
- **[P0]** = Critical (Must have for MVP)
- **[P1]** = Important (Should have)
- **[P2]** = Nice to have (Could have)
- **Status**: ⬜ Not Started | 🟡 In Progress | ✅ Completed | 🧪 Testing

---

## 🏠 **1. CORE APP INFRASTRUCTURE**

### 1.1 App Shell & Navigation
| ID | Feature | Priority | UI Components | Backend | Status |
|---|---|---|---|---|---|
| APP-001 | Splash Screen (2s duration, logo animation, init checks) | P0 | Logo, Loader, Version text | DB init, Pref load | ⬜ |
| APP-002 | Onboarding Flow (3 pages, swipeable, skip option) | P0 | Illustrations, Page indicators, CTA | First-launch flag | ⬜ |
| APP-003 | Bottom Navigation (4 tabs: Notes, Reminders, Todos, Reflect) | P0 | NavBar, FAB, Badges | State persistence | ⬜ |
| APP-004 | Biometric Lock Screen (Fingerprint/FaceID + PIN fallback) | P1 | Auth icons, Error states, PIN keypad | local_auth integration | ⬜ |
| APP-005 | Auto-lock Timer (App background timeout) | P1 | Timeout settings | Timer service | ⬜ |
| APP-006 | Global Search (Cross-module, debounced, highlighted results) | P1 | Search bar, Filter chips, Result cards | FTS search index | ⬜ |
| APP-007 | Responsive Layout (Mobile/Tablet/Desktop breakpoints) | P1 | Adaptive grids, Navigation rail | Layout logic | ⬜ |

### 1.2 Theming & Customization
| ID | Feature | Priority | Specs | Status |
|---|---|---|---|---|
| THM-001 | 7 Theme Variants (System, Light, Dark, Ocean, Forest, Sunset, Midnight) | P0 | Color tokens, Dynamic theming | ⬜ |
| THM-002 | 6 Font Families (Roboto, Open Sans, Lato, Montserrat, Poppins, System) | P1 | Typography scale, Line height | ⬜ |
| THM-003 | Font Size Scaling (0.8x - 1.5x) | P1 | Accessibility settings | ⬜ |
| THM-004 | Dynamic Theme Switching (Runtime toggle without restart) | P1 | BLoC state management | ⬜ |

---

## 📝 **2. NOTES MODULE**

### 2.1 Notes Management
| ID | Feature | Acceptance Criteria | Status |
|---|---|---|---|
| **NT-001** | Create Note | ⬜ Empty state handled<br>⬜ Auto-generate UUID<br>⬜ Timestamp createdAt/updatedAt<br>⬜ Auto-save on type (500ms debounce) | ⬜ |
| **NT-002** | Edit Note | ⬜ Rich text formatting (Bold, Italic, Underline)<br>⬜ Bulleted lists<br>⬜ Checkbox lists (interactive)<br>⬜ Undo/Redo support | ⬜ |
| **NT-003** | Delete Note | ⬜ Soft delete (archive) option<br>⬜ Hard delete with confirmation<br>⬜ Batch delete (multi-select) | ⬜ |
| **NT-004** | Pin/Unpin Note | ⬜ Max 10 pinned notes (limit)<br>⬜ Pinned notes appear first<br>⬜ Pin icon visual indicator | ⬜ |
| **NT-005** | Archive Note | ⬜ Separate archive view<br>⬜ Unarchive functionality<br>⬜ Auto-archive old notes (optional) | ⬜ |
| **NT-006** | Note Color Coding | ⬜ 8 colors: Default, Red, Pink, Purple, Blue, Green, Yellow, Orange<br>⬜ Color persists in DB<br>⬜ Visual card tinting | ⬜ |
| **NT-007** | Tagging System | ⬜ Add multiple tags (#work #urgent)<br>⬜ Tag autocomplete<br>⬜ Filter by tag<br>⬜ Tag cloud view | ⬜ |

### 2.2 Media Attachments
| ID | Feature | Technical Specs | Status |
|---|---|---|---|
| **MD-001** | Image Attachment | ⬜ Pick from Gallery<br>⬜ Capture from Camera<br>⬜ Compress to max 1080p (70% quality)<br>⬜ Thumbnail generation<br>⬜ Multiple images per note | ⬜ |
| **MD-002** | Video Attachment | ⬜ Pick video<br>⬜ Compress to 720p MP4<br>⬜ Extract thumbnail frame<br>⬜ Max duration limit (5 min)<br>⬜ Playback controls | ⬜ |
| **MD-003** | Audio Recording | ⬜ In-app recording (M4A format)<br>⬜ Pause/Resume recording<br>⬜ Waveform visualization<br>⬜ Playback with scrubber<br>⬜ Background recording support | ⬜ |
| **MD-004** | Link Attachments | ⬜ URL validation<br>⬜ Rich preview (OpenGraph)<br>⬜ In-app browser or external launch | ⬜ |
| **MD-005** | Media Viewer | ⬜ Fullscreen view<br>⬜ Zoom/pan images<br>⬜ Video controls (play, pause, seek)<br>⬜ Audio player mini-bar<br>⬜ Share media individually | ⬜ |

### 2.3 Note Organization
| ID | Feature | Details | Status |
|---|---|---|---|
| **ORG-001** | Grid/List Toggle | ⬜ Staggered grid (2 cols mobile, 3 cols tablet)<br>⬜ List view with swipe actions<br>⬜ View preference persistence | ⬜ |
| **ORG-002** | Sort Options | ⬜ Date Created (new/old)<br>⬜ Date Modified<br>⬜ Title (A-Z)<br>⬜ Color<br>⬜ Manual drag-drop reorder (P2) | ⬜ |
| **ORG-003** | Search Notes | ⬜ Title search<br>⬜ Content search<br>⬜ Tag search<br>⬜ Real-time results (300ms debounce)<br>⬜ Highlight matches | ⬜ |
| **ORG-004** | Note Templates | ⬜ 10 templates: Blank, Meeting, Journal, Recipe, To-Do, Project, Study, Travel, Book Summary, Brainstorm<br>⬜ Template preview<br>⬜ Custom templates (P2) | ⬜ |

### 2.4 Export & Share
| ID | Feature | Formats | Status |
|---|---|---|---|
| **EXP-001** | Export Single Note | ⬜ Plain Text (.txt)<br>⬜ Markdown (.md)<br>⬜ HTML (.html)<br>⬜ PDF (.pdf) | ⬜ |
| **EXP-002** | Export Multiple | ⬜ Bulk export as ZIP<br>⬜ Combined PDF | ⬜ |
| **EXP-003** | Share Functionality | ⬜ Native share sheet<br>⬜ Copy to clipboard<br>⬜ Email integration | ⬜ |
| **EXP-004** | Print Support | ⬜ Print dialog integration<br>⬜ Print formatting | ⬜ |

---

## 🔔 **3. REMINDERS MODULE**

### 3.1 Alarm Management
| ID | Feature | Specs | Status |
|---|---|---|---|
| **ALM-001** | Create Alarm | ⬜ Date + Time picker<br>⬜ Timezone aware<br>⬜ Link to specific note (optional)<br>⬜ Custom message (optional) | ⬜ |
| **ALM-002** | Recurring Patterns | ⬜ None (one-time)<br>⬜ Daily<br>⬜ Weekly (day selector)<br>⬜ Monthly (date selector)<br>⬜ Yearly | ⬜ |
| **ALM-003** | Alarm States | ⬜ Active/Inactive toggle<br>⬜ Triggered state<br>⬜ Snoozed state<br>⬜ Completed state | ⬜ |
| **ALM-004** | Alarm Indicators | ⬜ Visual: Red (overdue), Yellow (<1hr), Green (future)<br>⬜ Badge counts on tab icon | ⬜ |

### 3.2 Notification System
| ID | Feature | Requirements | Status |
|---|---|---|---|
| **NOT-001** | Local Notifications | ⬜ Exact alarm scheduling (Android 12+ compat)<br>⬜ Custom sounds<br>⬜ Vibration patterns<br>⬜ LED flash (Android)<br>⬜ Heads-up notification | ⬜ |
| **NOT-002** | Notification Actions | ⬜ "Open Note" → Launch app to note<br>⬜ "Snooze" → +10 min, +1 hour, +1 day options<br>⬜ "Dismiss" → Mark done | ⬜ |
| **NOT-003** | Do Not Disturb | ⬜ Quiet hours setting<br>⬜ Override DND for urgent alarms (P2) | ⬜ |

---

## ✅ **4. TODOS MODULE**

### 4.1 Task Management
| ID | Feature | Acceptance Criteria | Status |
|---|---|---|---|
| **TD-001** | Create Task | ⬜ Text input with voice option<br>⬜ Due date (optional)<br>⬜ Priority selection (4 levels)<br>⬜ Category selection | ⬜ |
| **TD-002** | Complete Task | ⬜ Checkbox toggle<br>⬜ Strikethrough animation<br>⬜ Completion timestamp<br>⬜ Progress ring update | ⬜ |
| **TD-003** | Edit Task | ⬜ Inline editing (P2) or Full edit<br>⬜ Modify all fields | ⬜ |
| **TD-004** | Delete Task | ⬜ Swipe to delete<br>⬜ Undo option (Snackbar 3s) | ⬜ |
| **TD-005** | Categories | ⬜ 8 categories: Personal, Work, Shopping, Health, Finance, Education, Home, Other<br>⬜ Icon per category<br>⬜ Filter by category | ⬜ |
| **TD-006** | Priority Levels | ⬜ Urgent (Red)<br>⬜ High (Orange)<br>⬜ Medium (Yellow)<br>⬜ Low (Green)<br>⬜ Sort by priority | ⬜ |

### 4.2 Subtasks & Hierarchy
| ID | Feature | Details | Status |
|---|---|---|---|
| **SUB-001** | Nested Subtasks | ⬜ Unlimited nesting depth<br>⬜ Visual indentation guides<br>⬜ Parent completion affects children (optional)<br>⬜ Drag to reorder (P1) | ⬜ |
| **SUB-002** | Progress Calculation | ⬜ Parent progress = average of children<br>⬜ Visual progress bar<br>⬜ Percentage display | ⬜ |

### 4.3 Focus Mode (Pomodoro)
| ID | Feature | Specs | Status |
|---|---|---|---|
| **POM-001** | Timer Function | ⬜ 25 min work (customizable)<br>⬜ 5 min short break<br>⬜ 15 min long break (after 4 sessions)<br>⬜ Pause/Resume/Reset<br>⬜ Skip break | ⬜ |
| **POM-002** | Visual Feedback | ⬜ Circular progress indicator<br>⬜ Color coding (Work=Blue, Break=Green)<br>⬜ Digital countdown display | ⬜ |
| **POM-003** | Session Tracking | ⬜ Session counter (1-4)<br>⬜ Daily/Weekly stats<br>⬜ Sound notifications on complete | ⬜ |
| **POM-004** | Background Mode | ⬜ Timer continues when minimized<br>⬜ Notification when complete<br>⬜ Keep screen awake option | ⬜ |

---

## 🧠 **5. REFLECTION (ASK YOURSELF) MODULE**

### 5.1 Question System
| ID | Feature | Details | Status |
|---|---|---|---|
| **REF-001** | Question Categories | ⬜ 4 categories: Life & Purpose, Daily Reflection, Career & Study, Mental Health<br>⬜ Category icons and colors | ⬜ |
| **REF-002** | Default Questions | ⬜ 50+ pre-loaded questions<br>⬜ Rotating daily prompt<br>⬜ Random shuffle | ⬜ |
| **REF-003** | Custom Questions | ⬜ User-created questions<br>⬜ Edit/Delete custom<br>⬜ Cannot delete defaults | ⬜ |
| **REF-004** | Question Display | ⬜ Card carousel view<br>⬜ Full list view<br>⬜ Category filter | ⬜ |

### 5.2 Answering & Journaling
| ID | Feature | Specs | Status |
|---|---|---|---|
| **ANS-001** | Rich Text Answer | ⬜ Multi-line text input<br>⬜ Voice-to-text input<br>⬜ Auto-save draft<br>⬜ Character counter | ⬜ |
| **ANS-002** | Mood Tracking | ⬜ 10 mood types with emojis<br>⬜ 1-5 value mapping<br>⬜ Energy level (1-5)<br>⬜ Sleep quality (1-5)<br>⬜ Activity tags | ⬜ |
| **ANS-003** | Reflection Timer | ⬜ Track time spent writing<br>⬜ Pause timer if idle<br>⬜ Store duration with answer | ⬜ |
| **ANS-004** | Privacy Mode | ⬜ Lock individual reflections<br>⬜ Biometric/PIN to view<br>⬜ Privacy indicator icon | ⬜ |

### 5.3 History & Analytics
| ID | Feature | Details | Status |
|---|---|---|---|
| **HIS-001** | Timeline View | ⬜ Chronological list<br>⬜ Calendar view (month grid)<br>⬜ Filter by mood<br>⬜ Filter by date range | ⬜ |
| **HIS-002** | Streak Tracking | ⬜ Daily streak counter<br>⬜ Longest streak record<br>⬜ Streak freeze (P2) | ⬜ |
| **HIS-003** | Mood Analytics | ⬜ Mood distribution chart<br>⬜ Trends over time (line chart)<br>⬜ Average mood score | ⬜ |
| **HIS-004** | Export Reflections | ⬜ Export as journal PDF<br>⬜ Backup to file | ⬜ |

---

## 🎤 **6. VOICE INTEGRATION**

| ID | Feature | Technical Requirements | Status |
|---|---|---|---|
| **VOC-001** | Speech-to-Text | ⬜ 24+ language support<br>⬜ Real-time transcription<br>⬜ Partial results display<br>⬜ Confidence scoring (>0.8)<br>⬜ Sound level visualization | ⬜ |
| **VOC-002** | Voice Commands | ⬜ "Bold", "Italic", "New line"<br>⬜ "Save", "Delete", "Cancel"<br>⬜ Punctuation: "Period", "Comma" | ⬜ |
| **VOC-003** | Audio Feedback | ⬜ Start recording sound<br>⬜ Stop confirmation<br>⬜ Error beep<br>⬜ Command recognized chime | ⬜ |
| **VOC-004** | Voice Settings | ⬜ Language selection<br>⬜ Confidence threshold slider<br>⬜ Timeout duration (5-30s)<br>⬜ Offline mode support (P2) | ⬜ |

---

## 💾 **7. DATA & STORAGE**

### 7.1 Local Database
| ID | Feature | Schema/Logic | Status |
|---|---|---|---|
| **DB-001** | SQLite Setup | ⬜ sqflite implementation<br>⬜ Desktop support (sqflite_common_ffi)<br>⬜ Migration strategy (versions 1-N) | ⬜ |
| **DB-002** | Entity Relations | ⬜ Note → Media (1:N)<br>⬜ Note → Alarm (1:N)<br>⬜ Note → Todo (1:N)<br>⬜ Question → Answer (1:N) | ⬜ |
| **DB-003** | CRUD Operations | ⬜ Create with transaction<br>⬜ Read with pagination (lazy load)<br>⬜ Update with timestamp<br>⬜ Soft delete option | ⬜ |
| **DB-004** | Data Integrity | ⬜ Foreign key constraints<br>⬜ Cascade delete for media files<br>⬜ Orphan file cleanup | ⬜ |

### 7.2 File Management
| ID | Feature | Specs | Status |
|---|---|---|---|
| **FIL-001** | Media Storage | ⬜ App documents directory<br>⬜ Organized subfolders (/images, /audio, /video)<br>⬜ UUID filenames | ⬜ |
| **FIL-002** | Compression | ⬜ Image: max 1080p, 70% quality<br>⬜ Video: 720p, H.264 encoding<br>⬜ Progress indicator | ⬜ |
| **FIL-003** | Cache Management | ⬜ Thumbnail cache<br>⬜ Clear cache button<br>⬜ Auto-clear old cache (>30 days) | ⬜ |
| **FIL-004** | Backup/Restore | ⬜ Export full DB + media as ZIP<br>⬜ Import with merge or replace option<br>⬜ Cloud backup prep (P2) | ⬜ |

---

## 🔐 **8. SECURITY & PERMISSIONS**

| ID | Feature | Implementation | Status |
|---|---|---|---|
| **SEC-001** | Biometric Auth | ⬜ Fingerprint (Android)<br>⬜ Face ID (iOS)<br>⬜ Iris (Samsung)<br>⬜ Fallback to PIN/Password | ⬜ |
| **SEC-002** | Permissions | ⬜ Camera (photos/video)<br>⬜ Microphone (voice/audio)<br>⬜ Storage (media access)<br>⬜ Notifications (alarms)<br>⬜ Biometric hardware | ⬜ |
| **SEC-003** | Data Encryption | ⬜ SQLCipher for database (P1)<br>⬜ Encrypted shared preferences<br>⬜ Secure file storage for sensitive notes | ⬜ |

---

## ⚙️ **9. SETTINGS & CONFIGURATION**

| ID | Feature | Options | Status |
|---|---|---|---|
| **SET-001** | Appearance Settings | ⬜ Theme selector<br>⬜ Font family dropdown<br>⬜ Font size slider (0.8x-1.5x)<br>⬜ Custom color picker (P2) | ⬜ |
| **SET-002** | Security Settings | ⬜ Biometric toggle<br>⬜ Auto-lock timer (1min, 5min, 15min, Never)<br>⬜ PIN setup/change<br>⬜ Privacy mode toggle | ⬜ |
| **SET-003** | Notification Settings | ⬜ Master toggle<br>⬜ Sound selection (default, custom)<br>⬜ Vibration toggle<br>⬜ LED flash toggle<br>⬜ Quiet hours | ⬜ |
| **SET-004** | Voice Settings | ⬜ Language selection (24+)<br>⬜ Voice commands toggle<br>⬜ Audio feedback toggle<br>⬜ Confidence threshold<br>⬜ Mic test | ⬜ |
| **SET-005** | Storage Info | ⬜ Storage used display<br>⬜ Cache size display<br>⬜ Clear cache button<br>⬜ Optimize storage (compress old media) | ⬜ |
| **SET-006** | About Section | ⬜ Version number<br>⬜ Privacy Policy link<br>⬜ Terms of Service<br>⬜ Rate app<br>⬜ Contact support | ⬜ |

---

## 📊 **10. ANALYTICS & INSIGHTS**

| ID | Feature | Metrics | Status |
|---|---|---|---|
| **ANL-001** | Notes Stats | ⬜ Total count<br>⬜ By color distribution<br>⬜ With media %<br>⬜ Pinned count | ⬜ |
| **ANL-002** | Productivity | ⬜ Tasks completion rate<br>⬜ Overdue tasks count<br>⬜ Pomodoro sessions completed<br>⬜ Priority distribution | ⬜ |
| **ANL-003** | Reflection Stats | ⬜ Total reflections<br>⬜ Current streak<br>⬜ Mood trend (weekly)<br>⬜ Category distribution | ⬜ |
| **ANL-004** | Usage Patterns | ⬜ Daily active usage<br>⬜ Most active hour<br>⬜ Feature usage breakdown | ⬜ |

---

## 🧪 **11. TESTING CHECKLIST**

### 11.1 Unit Tests
- [ ] BLoC event/state testing (all 6 blocs)
- [ ] Repository layer mocking
- [ ] Service layer (Speech, Biometric, Export)
- [ ] Utility functions (Date formatting, Compression)

### 11.2 Widget Tests
- [ ] Note card rendering (all states)
- [ ] Editor toolbar functionality
- [ ] Navigation flow
- [ ] Form validation
- [ ] Responsive layout breakpoints

### 11.3 Integration Tests
- [ ] End-to-end: Create note → Add media → Set reminder → Complete
- [ ] Voice input flow
- [ ] Biometric auth flow
- [ ] Export/Import roundtrip
- [ ] Background alarm trigger

### 11.4 Platform-Specific
- [ ] iOS: Permissions dialogs, Face ID, Safe areas
- [ ] Android: Back button, Permissions, Notifications channels
- [ ] Desktop: Window resizing, Menu bar, Keyboard shortcuts
- [ ] Web: Browser storage, PWA manifest

---

## 🚀 **12. DEPLOYMENT & DEVOPS**

| ID | Task | Details | Status |
|---|---|---|---|
| **DEP-001** | Build Configs | ⬜ Flavors (dev, staging, prod)<br>⬜ Environment variables<br>⬜ App signing (iOS/Android) | ⬜ |
| **DEP-002** | CI/CD | ⬜ GitHub Actions / Codemagic<br>⬜ Automated testing<br>⬜ Build artifacts | ⬜ |
| **DEP-003** | Store Preparation | ⬜ Screenshots (all themes)<br>⬜ App description<br>⬜ Privacy policy URL<br>⬜ App icon (all sizes) | ⬜ |

---

## 📱 **13. ACCESSIBILITY (A11Y)**

| ID | Feature | Requirement | Status |
|---|---|---|---|
| **A11Y-001** | Screen Reader | ⬜ All buttons labeled<br>⬜ Dynamic content announcements<br>⬜ Image descriptions (alt text) | ⬜ |
| **A11Y-002** | Text Scaling | ⬜ Support system font size up to 200%<br>⬜ No text truncation at large sizes | ⬜ |
| **A11Y-003** | Color Contrast | ⬜ WCAG AA compliance (4.5:1 for text)<br>⬜ Color not sole indicator (icons + color) | ⬜ |
| **A11Y-004** | Input Methods | ⬜ Keyboard navigation support<br>⬜ Voice control compatibility | ⬜ |

---

## 📋 **Sprint Planning Recommendations**

### **Sprint 1: Foundation**
- APP-001 to APP-004 (Core shell)
- THM-001 (Basic theming)
- DB-001 to DB-003 (Database setup)
- NT-001 to NT-003 (Basic notes)

### **Sprint 2: Rich Content**
- MD-001 to MD-003 (Media)
- NT-004 to NT-007 (Note features)
- VOC-001 (Basic voice input)

### **Sprint 3: Productivity**
- TD-001 to TD-006 (Todos)
- ALM-001 to ALM-003 (Reminders)
- NOT-001 (Notifications)

### **Sprint 4: Reflection**
- REF-001 to REF-004 (Questions)
- ANS-001 to ANS-004 (Answering)
- HIS-001 to HIS-003 (History)

### **Sprint 5: Polish & Security**
- SEC-001 to SEC-003 (Security)
- SET-001 to SET-006 (Settings)
- POM-001 to POM-004 (Focus mode)
- Testing & Bug fixes

---

**Total Features**: ~85 P0/P1 features + 15 P2 enhancements  
**Estimated Timeline**: 12-16 weeks with 2 Flutter developers  
**MVP Scope**: All P0 items (approximately 60 features)

Use this checklist with your project management tool (Jira, Trello, GitHub Projects) by importing the Feature IDs as tickets.