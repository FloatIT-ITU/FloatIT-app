# FloatIT App - Complete Color Theme Guide# FloatIT App - Complete Color Theme Guide# FloatIT Color Theme System



This document explains the complete color theme system and how to customize EVERY color in the app.



## 📍 Color Configuration FileThis document explains the complete color theme system and how to customize EVERY color in the app.This document explains how to customize the color palette for both light and dark modes in the FloatIT app.



**All colors are centralized in:** `lib/src/theme_colors.dart`



## 🎨 Base Color Palette## 📍 Color Configuration File## Overview



The app uses a professionally shaded color system with the following palettes:



### Primary (Blue)**All colors are centralized in:** `lib/src/theme_colors.dart`The app uses a centralized color system defined in `lib/src/theme_colors.dart`. All colors are applied through the MaterialApp theme configuration in `lib/src/app.dart`, ensuring consistent application across the entire app.

| Shade | Light Mode | Dark Mode |

|-------|------------|-----------|

| 50 | `0xFFF0F6FF` | `0xFF0A1420` |

| 100 | `0xFFE0EDFE` | `0xFF162638` |## 🎨 Complete Color Inventory## Current Color Palette

| 200 | `0xFFBDD7FC` | `0xFF1E3449` |

| 300 | `0xFF85B8F8` | `0xFF2A4A6B` |

| 400 | `0xFF4897F3` | `0xFF3D6B96` |

| 500 | `0xFF458FCD` | `0xFF458FCD` |### 1. Light Mode Colors### Light Mode

| 600 | `0xFF2E75B8` | `0xFF5BA3E0` |

| 700 | `0xFF1F5A96` | `0xFF7AB8E8` |- **Primary/Main Color** (`#458fcd`): Used for menu items, event cards, buttons, sections, and highlights

| 800 | `0xFF1A4674` | `0xFF9DCBF0` |

| 900 | `0xFF183856` | `0xFFC5DFF7` |#### Primary Brand Colors- **Background** (`#c5dff7`): Main app background and surface colors



### Warning (Orange)- **`lightPrimary`** - `#458FCD` (Blue)- **Text/Buttons** (`#0a1420`): Primary text color and button text

| Shade | Light Mode | Dark Mode |

|-------|------------|-----------|  - Used in: Menu items, buttons, active states, highlights, links- **Success/Checkmarks** (`#22c55e`): Positive actions and confirmations

| 50 | `0xFFFFFBF0` | `0xFF2D1410` |

| 100 | `0xFFFEF3E2` | `0xFF4A2318` |- **`lightSecondary`** - `#458FCD` (Blue)- **Warning/Errors** (`#f36f47`): Warnings and destructive actions

| 200 | `0xFFFDE4B8` | `0xFF6B3420` |

| 300 | `0xFFFBD08A` | `0xFF8F4628` |  - Used in: Secondary buttons, less prominent elements

| 400 | `0xFFF89C5C` | `0xFFB85A32` |

| 500 | `0xFFF36F47` | `0xFFF36F47` |### Dark Mode

| 600 | `0xFFE55A2E` | `0xFFF78A68` |

| 700 | `0xFFC1471A` | `0xFFF9A689` |#### Backgrounds- Maintains the same primary colors for consistency

| 800 | `0xFF9E3712` | `0xFFFBC2AA` |

| 900 | `0xFF7F2D0F` | `0xFFFDDDCB` |- **`lightBackground`** - `#C5DFF7` (Light Blue)- Uses darker backgrounds (`#0d1b2a`, `#1b263b`) for proper contrast



### Success (Green)  - Used in: Main app background color- Light text (`#e0e1dd`) for readability on dark backgrounds

| Shade | Light Mode | Dark Mode |

|-------|------------|-----------|- **`lightSurface`** - `#C5DFF7` (Light Blue)

| 50 | `0xFFF0FDF4` | `0xFF0A1F0D` |

| 100 | `0xFFDCFCE7` | `0xFF14532D` |  - Used in: Cards, dialogs, bottom sheets, input field backgrounds## How to Change Colors

| 200 | `0xFFBBF7D0` | `0xFF166534` |

| 300 | `0xFF86EFAC` | `0xFF15803D` |- **`cardLight`** - `#C5DFF7` (Light Blue)

| 400 | `0xFF4ADE80` | `0xFF16A34A` |

| 500 | `0xFF22C55E` | `0xFF22C55E` |  - Used in: Event cards, user cards, list item backgrounds### Step 1: Update Color Definitions

| 600 | `0xFF16A34A` | `0xFF4ADE80` |

| 700 | `0xFF15803D` | `0xFF86EFAC` |

| 800 | `0xFF166534` | `0xFFBBF7D0` |

| 900 | `0xFF14532D` | `0xFFDCFCE7` |#### Text ColorsEdit `lib/src/theme_colors.dart`:



### Neutral (Gray)- **`lightText`** - `#0A1420` (Dark Blue)

| Shade | Light Mode | Dark Mode |

|-------|------------|-----------|  - Used in: All body text, headings, labels```dart

| 50 | `0xFFFAFAFA` | `0xFF09090B` |

| 100 | `0xFFF4F4F5` | `0xFF18181B` |- **`lightOnBackground`** - `#0A1420` (Dark Blue)class AppThemeColors {

| 200 | `0xFFE4E4E7` | `0xFF27272A` |

| 300 | `0xFFD4D4D8` | `0xFF3F3F46` |  - Used in: Text displayed directly on background  // Light theme colors

| 400 | `0xFFA1A1AA` | `0xFF52525B` |

| 500 | `0xFF71717A` | `0xFF71717A` |- **`lightOnPrimary`** - `#0A1420` (Dark Blue)  static const Color lightPrimary = Color(0xFF458FCD);    // Change this hex code

| 600 | `0xFF52525B` | `0xFFA1A1AA` |

| 700 | `0xFF3F3F46` | `0xFFD4D4D8` |  - Used in: Text on primary color buttons and surfaces  static const Color lightBackground = Color(0xFFC5DFF7); // Change this hex code

| 800 | `0xFF27272A` | `0xFFE4E4E7` |

| 900 | `0xFF18181B` | `0xFFF4F4F5` |  static const Color lightText = Color(0xFF0A1420);       // Change this hex code



---#### Status Colors  static const Color lightSuccess = Color(0xFF22C55E);    // Change this hex code



## 📱 Current Color Mapping- **`lightSuccess`** - `#22C55E` (Green)  static const Color lightWarning = Color(0xFFF36F47);    // Change this hex code



### Light Mode Colors  - Used in: Success messages, checkmarks, confirmation indicators



#### Backgrounds- **`lightWarning`** - `#F36F47` (Orange)  // Dark theme colors

- **`lightBackground`** - Primary 100 (`#E0EDFE`)

  - Used in: Main app background  - Used in: Warnings, errors, destructive action alerts  static const Color darkPrimary = Color(0xFF458FCD);     // Change this hex code

- **`lightSurface`** - Primary 200 (`#BDD7FC`)

  - Used in: Cards, dialogs, input fields, elevated surfaces  static const Color darkBackground = Color(0xFF0D1B2A);  // Change this hex code

- **`cardLight`** - Primary 200 (`#BDD7FC`)

  - Used in: Event cards, user cards (matches pool banner normal state)#### Badge Colors (for attendance status)  static const Color darkText = Color(0xFFE0E1DD);        // Change this hex code



#### Primary Actions- **`lightHostingBadge`** - `#9C27B0` (Purple)  // ... etc

- **`lightPrimary`** - Primary 500 (`#458FCD`)

  - Used in: Main brand color, ColorScheme primary (not directly on buttons)  - Used in: "Hosting" badge background when user is event host}

- **`lightSecondary`** - Primary 600 (`#2E75B8`)

  - Used in: Secondary elements, outlined button borders- **`lightAttendingBadge`** - `#22C55E` (Green)```



#### Text Colors  - Used in: "Attending" badge background when user is attending

- **`lightText`** - Primary 900 (`#183856`)

  - Used in: All body text, headings, labels- **`lightWaitingBadge`** - `#F36F47` (Orange)### Step 2: Convert Hex to Flutter Color

- **`lightOnBackground`** - Primary 900 (`#183856`)

  - Used in: Text displayed directly on background  - Used in: "Waiting List" badge background when user is on waiting list

- **`lightOnPrimary`** - White (`#FFFFFF`)

  - Used in: Text on primary-colored buttons- **`lightBadgeIcon`** - `#FFFFFF` (White)To convert a hex color like `#458fcd` to Flutter format:



#### Buttons (Inverted from Dark Mode)  - Used in: Icons inside all badge circles (star, check, hourglass)1. Remove the `#`

- **Button Background** - Primary 700 Dark (`#7AB8E8`) - Light blue

- **Button Text** - Primary 50 Dark (`#0A1420`) - Dark text2. Add `0xFF` prefix



#### Status Colors### 2. Dark Mode Colors3. Convert to uppercase: `Color(0xFF458FCD)`

- **`lightSuccess`** - Success 500 (`#22C55E`)

  - Used in: Success messages, checkmarks, attending badges

- **`lightWarning`** - Warning 500 (`#F36F47`)

  - Used in: Warnings, errors, waiting list badges#### Primary Brand Colors### Step 3: Restart the App



#### Badge Colors- **`darkPrimary`** - `#458FCD` (Blue)

- **`lightHostingBadge`** - Primary 600 (`#2E75B8`)

  - Used in: "Hosting" badge (darker blue)  - Same uses as light mode, maintains brand consistencyAfter changing colors, restart the Flutter app to see the changes. Hot reload may not apply theme changes.

- **`lightAttendingBadge`** - Success 500 (`#22C55E`)

  - Used in: "Attending" badge (green)- **`darkSecondary`** - `#458FCD` (Blue)

- **`lightWaitingBadge`** - Warning 500 (`#F36F47`)

  - Used in: "Waiting List" badge (orange)  - Same uses as light mode## Color Usage Guide

- **`lightBadgeIcon`** - White (`#FFFFFF`)

  - Used in: Icons inside badge circles



### Dark Mode Colors#### Backgrounds### Primary Colors



#### Backgrounds- **`darkBackground`** - `#0D1B2A` (Very Dark Blue)- `lightPrimary` / `darkPrimary`: Main brand color

- **`darkBackground`** - Primary 100 Dark (`#162638`)

  - Used in: Main app background (more blue than before)  - Used in: Main app background in dark mode  - Used for: Buttons, active states, highlights, menu items, event cards

- **`darkSurface`** - Primary 200 Dark (`#1E3449`)

  - Used in: Cards, dialogs, elevated surfaces (more blue)- **`darkSurface`** - `#1B263B` (Dark Blue-Grey)

- **`cardDark`** - Primary 200 Dark (`#1E3449`)

  - Used in: Event cards (matches pool banner normal state)  - Used in: Cards, dialogs, input fields, elevated surfaces### Background Colors



#### Primary Actions- **`cardDark`** - `#415A77` (Medium Blue-Grey)- `lightBackground` / `darkBackground`: Main app background

- **`darkPrimary`** - Primary 700 Dark (`#7AB8E8`)

  - Used in: Main brand color for dark mode, ColorScheme primary  - Used in: Event cards, user cards, distinguishable from surface- `lightSurface` / `darkSurface`: Card backgrounds, elevated surfaces

- **`darkSecondary`** - Primary 600 Dark (`#5BA3E0`)

  - Used in: Secondary elements- `cardLight` / `cardDark`: Specific card background colors



#### Text Colors#### Text Colors

- **`darkText`** - Primary 50 Light (`#F0F6FF`)

  - Used in: All body text, headings, labels- **`darkText`** - `#E0E1DD` (Light Grey)### Text Colors

- **`darkOnBackground`** - Primary 50 Light (`#F0F6FF`)

  - Used in: Text displayed directly on background  - Used in: All body text, headings, labels in dark mode- `lightText` / `darkText`: Primary text color

- **`darkOnPrimary`** - Primary 50 Dark (`#0A1420`)

  - Used in: Dark text on light primary buttons- **`darkOnBackground`** - `#E0E1DD` (Light Grey)  - Used for: Button text, list item text, general UI text



#### Buttons (Inverted from Light Mode)  - Used in: Text displayed directly on dark background

- **Button Background** - Primary 600 (`#2E75B8`) - Dark blue

- **Button Text** - White (`#FFFFFF`)- **`darkOnPrimary`** - `#0A1420` (Dark Blue)### Status Colors



#### Status Colors  - Used in: Text on primary color buttons (maintains contrast)- `lightSuccess` / `darkSuccess`: Positive actions, checkmarks

- **`darkSuccess`** - Success 400 (`#4ADE80`)

  - Used in: Brighter green for dark backgrounds- `lightWarning` / `darkWarning`: Errors, warnings, destructive actions

- **`darkWarning`** - Warning 500 (`#F36F47`)

  - Used in: Same as light mode#### Status Colors



#### Badge Colors- **`darkSuccess`** - `#22C55E` (Green)### Banner Colors

- **`darkHostingBadge`** - Primary 700 Dark (`#7AB8E8`)

  - Used in: "Hosting" badge (lighter blue for visibility)  - Same as light mode for consistency- `bannerGlobalLight/Dark`: Global notification banners

- **`darkAttendingBadge`** - Success 400 (`#4ADE80`)

  - Used in: "Attending" badge (brighter green)- **`darkWarning`** - `#F36F47` (Orange)- `bannerEventLight/Dark`: Event-specific banners

- **`darkWaitingBadge`** - Warning 600 Dark (`#F78A68`)

  - Used in: "Waiting List" badge (lighter orange)  - Same as light mode for consistency- `bannerMainPagesLight/Dark`: Main page banners

- **`darkBadgeIcon`** - Primary 50 Dark (`#0A1420`)

  - Used in: Dark icons on light badges- `bannerSubPagesLight/Dark`: Sub-page banners



### Banner Colors#### Badge Colors



#### Pool Status Banner- **`darkHostingBadge`** - `#CE93D8` (Light Purple)## Helper Methods

- **Normal State** (matches event cards for less intrusion):

  - Light Mode: Primary 200 (`#BDD7FC`)  - Lighter than light mode for visibility on dark backgrounds

  - Dark Mode: Primary 200 Dark (`#1E3449`)

- **Warning State** (stands out prominently):- **`darkAttendingBadge`** - `#22C55E` (Green)The color system includes helper methods for theme-aware colors:

  - Both Modes: Warning 500 (`#F36F47`) with white/light text

  - Same as light mode

#### Page Banners

- **`bannerGlobalLight/Dark`** - Primary 500 / Primary 700 Dark- **`darkWaitingBadge`** - `#F36F47` (Orange)```dart

  - Global notification banners

- **`bannerMainPagesLight/Dark`** - Primary 500 / Primary 700 Dark  - Same as light mode// Get primary color based on current theme

  - Main page headers

- **`bannerSubPagesLight/Dark`** - Primary 600 / Primary 600 Dark- **`darkBadgeIcon`** - `#0A1420` (Dark Blue)Color primaryColor = AppThemeColors.primary(context);

  - Sub-page headers

  - Dark icons on light badges for dark mode

#### Banner Text

- **`bannerTextLight`** - Primary 900 (`#183856`)// Get success color based on current theme

- **`bannerTextDark`** - Primary 50 Light (`#F0F6FF`)

- **`bannerGlobalTextLight`** - White (on Primary 500)### 3. Banner ColorsColor successColor = AppThemeColors.success(context);

- **`bannerGlobalTextDark`** - Primary 50 Dark (on Primary 700 Dark)

- **`bannerEventTextLight`** - Primary 900 (on light banners)

- **`bannerEventTextDark`** - Primary 50 Light (on dark banners)

#### Banner Backgrounds// Get warning color based on current theme

---

All banners use consistent colors across light/dark modes:Color warningColor = AppThemeColors.warning(context);

## 🔧 How to Change Colors

- **`bannerGlobalLight/Dark`** - `#458FCD` (Blue)

### Option 1: Adjust Individual Colors

1. Open `lib/src/theme_colors.dart`  - Used in: Global notification banners (admin announcements)// Get text color based on current theme

2. Find the color constant (e.g., `lightBackground`)

3. Change to a different shade from the palette above- **`bannerEventLight/Dark`** - `#458FCD` (Blue)Color textColor = AppThemeColors.text(context);

4. Restart the app

  - Used in: Event-specific notification banners```

### Option 2: Swap Complete Themes

To create a completely different color scheme:- **`bannerMainPagesLight/Dark`** - `#458FCD` (Blue)

1. Choose new base colors for Primary, Warning, Success

2. Update all related shades in `theme_colors.dart`  - Used in: Main page top bars## Best Practices

3. Maintain the hierarchy (50→100→200...→900)

4. Test both light and dark modes- **`bannerSubPagesLight/Dark`** - `#458FCD` (Blue)



---  - Used in: Sub-page top bars1. **Test Both Themes**: Always test color changes in both light and dark modes



## 📊 Color Hierarchy2. **Maintain Contrast**: Ensure sufficient contrast ratios for accessibility



### Light Mode#### Banner Text Colors3. **Use Consistent Colors**: Stick to the defined color palette rather than inline colors

```

Darkest → Lightest- **`bannerTextLight`** - `#0A1420` (Dark Blue)4. **Document Changes**: Update this document when adding new colors

Text (900)     #183856

Secondary (600) #2E75B8  - Used in: Page title text in light mode5. **Restart Required**: Theme changes require app restart to take effect

Primary (500)   #458FCD

Cards (200)     #BDD7FC- **`bannerTextDark`** - `#E0E1DD` (Light Grey)

Surface (200)   #BDD7FC

Background (100) #E0EDFE  - Used in: Page title text in dark mode## Adding New Colors

```

- **`bannerGlobalTextLight/Dark`** - `#0A1420` (Dark Blue)

### Dark Mode

```  - Used in: Text inside global notification bannersWhen adding new colors to the system:

Lightest → Darkest

Text (50 Light)      #F0F6FF- **`bannerEventTextLight/Dark`** - `#0A1420` (Dark Blue)

Primary (700 Dark)   #7AB8E8

Secondary (600 Dark) #5BA3E0  - Used in: Text inside event notification banners1. Add them to `theme_colors.dart` with both light and dark variants

Cards (200 Dark)     #1E3449

Surface (200 Dark)   #1E34492. Update the theme configuration in `app.dart` if needed

Background (100 Dark) #162638

```### 4. Special Purpose Colors3. Add documentation in this file



---4. Test across all screens and components



## ✅ Key Design Features- **`systemMessageColor`** - `#FFFFFF` (White)



1. **Inverted Buttons**: Light blue buttons in light mode, dark blue buttons in dark mode for visual interest  - Used in: System-generated messages in chats## Troubleshooting

2. **Blue Backgrounds**: More pronounced blue tint throughout the app

3. **Pool Banner Blending**: Normal state matches event cards (less intrusive)- **`transparent`** - Fully transparent

4. **Pool Banner Warning**: Orange stands out clearly when status is not normal

5. **Professional Shading**: Uses consistent 50-900 shade system  - Used in: Transparent overlays, spacers- **Colors not updating**: Restart the app (hot reload doesn't apply theme changes)

6. **High Contrast**: All text meets WCAG accessibility standards

7. **Theme Consistency**: Dark mode intelligently inverts light mode colors- **`shadow`** - `rgba(0,0,0,0.1)` (10% black)- **Inconsistent colors**: Check that you're using `AppThemeColors` constants instead of inline colors



---  - Used in: Drop shadows on cards, elevated elements- **Dark mode issues**: Ensure dark variants are properly defined and applied in the theme

- **`primaryOverlayLow`** - `rgba(69,143,205,0.08)` (8% primary)

## 🎯 Testing Checklist  - Used in: Subtle hover states, pressed states



After making color changes:## 🔧 How to Change Colors



- [ ] Test light mode appearance### Step 1: Open the Color File

- [ ] Test dark mode appearanceNavigate to: `lib/src/theme_colors.dart`

- [ ] Toggle between themes smoothly

- [ ] Check all button types (elevated, outlined, text)### Step 2: Find the Color You Want to Change

- [ ] Verify attendance badges (hosting/attending/waiting)Use the categories above to locate the specific color constant.

- [ ] Check pool status banner (normal and warning states)

- [ ] Verify text contrast on all backgrounds### Step 3: Update the Hex Value

- [ ] Test notification banners```dart

- [ ] Check page headers and navigation// Example: Change primary color from blue to green

- [ ] Verify card elevations are visiblestatic const Color lightPrimary = Color(0xFF22C55E); // Was: 0xFF458FCD

- [ ] Test input fields and formsstatic const Color darkPrimary = Color(0xFF22C55E);  // Keep consistent

- [ ] Check error and success states```



---### Step 4: Update Related Colors

If changing primary, consider updating:

**Color Theme System Version**: 3.0  - Secondary colors

**Last Updated**: October 11, 2025  - Banner colors

**Configuration File**: `lib/src/theme_colors.dart`  - Any colors that should match the primary

**Total Centralized Colors**: 40+ shades covering 100% of the app

### Step 5: Test Both Themes
- Restart the app (hot reload may not apply all theme changes)
- Toggle between light and dark mode
- Check all screens for proper contrast and consistency

## 📱 Where Every Color Appears

### Application-Wide (`lib/src/app.dart`)
Configured in the MaterialApp theme:
- **Scaffold Background**: Uses `lightBackground` / `darkBackground`
- **Card Color**: Uses `cardLight` / `cardDark`
- **Primary Color**: Uses `lightPrimary` / `darkPrimary`
- **Text Theme**: Uses `lightText` / `darkText`

### Button Themes
- **ElevatedButton**:
  - Background: `lightPrimary` / `darkPrimary`
  - Text: `lightText` / `darkText`
- **OutlinedButton**:
  - Border: `lightPrimary` / `darkPrimary`
  - Text: `lightText` / `darkText`
- **TextButton**:
  - Text: `lightPrimary` / `darkPrimary`

### AppBar Theme
- **Background**: `lightPrimary` / `darkSurface`
- **Text/Icons**: `lightText` / `darkText`

### Input Fields
- **Background**: `lightSurface` / `darkSurface`
- **Border**: Derived from theme
- **Text**: `lightText` / `darkText`

### List Tiles
- **Background**: `cardLight` / `cardDark`
- **Icon Color**: `lightText` / `darkText`
- **Text Color**: `lightText` / `darkText`

### Cards
- **Background**: `cardLight` / `cardDark`
- **Border Radius**: 8.0 (defined in CardTheme)

### Attendance Badges (`lib/src/widgets/attendance_badge.dart`)
Shows user's attendance status on event cards:
- **Hosting Badge**:
  - Circle: `lightHostingBadge` / `darkHostingBadge`
  - Icon (star): `lightBadgeIcon` / `darkBadgeIcon`
  - Label: "Hosting"
  
- **Attending Badge**:
  - Circle: `lightAttendingBadge` / `darkAttendingBadge`
  - Icon (checkmark): `lightBadgeIcon` / `darkBadgeIcon`
  - Label: "Attending"
  
- **Waiting List Badge**:
  - Circle: `lightWaitingBadge` / `darkWaitingBadge`
  - Icon (hourglass): `lightBadgeIcon` / `darkBadgeIcon`
  - Label: "On waiting list"

### Pool Status Banner (`lib/src/widgets/pool_status_banner.dart`)
Persistent banner at bottom showing Sundby Bad status:
- **Normal Status**: Uses `bannerEventLight/Dark` colors
- **Alert Status**: Uses `warning()` color
- **Text**: Uses `bannerEventTextLight/Dark`
- **Icons**: Match text color

### Notification Banners (`lib/src/widgets/notification_banner.dart`)
Top banners for announcements:
- **Global Banners**: `bannerGlobalLight/Dark` background
- **Event Banners**: `bannerEventLight/Dark` background
- **Text**: `bannerGlobalTextLight/Dark` or `bannerEventTextLight/Dark`

### Page Banners (`lib/src/widgets/banners.dart`)
Top navigation bars on each page:
- **Background**: Transparent (shows app background through)
- **Text**: Uses `text(context)` helper
- **Back Arrow**: Uses `text(context)` helper
- **Action Buttons**: Inherit from button themes

### Menu Icons (`lib/src/main_app_view.dart`)
Bottom navigation and side drawer:
- **Active Icons**: `lightPrimary` / `darkPrimary`
- **Inactive Icons**: `lightText` / `darkText` with opacity
- **Badge Counts**: `lightWarning` / `darkWarning`

### Swimmer Icons (`lib/src/widgets/swimmer_icon_picker.dart`)
User avatar icons for attendee lists:
- **Circle Background**: User-selected color
- **Icon**: `lightBadgeIcon` (white)
- **Shadow**: `shadow` color

### Error States (`lib/src/widgets/loading_widgets.dart`)
Error messages and empty states:
- **Icon Color**: `text(context)` with 50% opacity
- **Text Color**: `text(context)`
- **Retry Button**: Uses button theme

### Info Banners (`lib/src/widgets/widget_utils.dart`)
Informational messages:
- **Background**: `primary(context)` with 10% opacity
- **Border**: `primary(context)` with 30% opacity
- **Icon**: `primary(context)`
- **Text**: `primary(context)`

### Status Badges (`lib/src/widgets/widget_utils.dart`)
Small status indicators:
- **Background**: `lightSurface` / `darkSurface`
- **Text**: `text(context)`
- **Icon**: `text(context)`

## 🎯 Helper Methods for Dynamic Colors

Use these methods to automatically get the right color for the current theme:

```dart
// In any widget with BuildContext:

// Primary color
AppThemeColors.primary(context)

// Success/warning colors
AppThemeColors.success(context)
AppThemeColors.warning(context)

// Text color
AppThemeColors.text(context)

// Badge colors
AppThemeColors.hostingBadge(context)
AppThemeColors.attendingBadge(context)
AppThemeColors.waitingBadge(context)
AppThemeColors.badgeIcon(context)
```

## ✅ Complete Testing Checklist

After changing colors, test:

### Screens to Check
- [ ] Events list page
- [ ] Event details page
- [ ] Create/edit event pages
- [ ] Messages page
- [ ] User profile page
- [ ] Settings page
- [ ] Admin pages

### Components to Verify
- [ ] Attendance badges (hosting/attending/waiting)
- [ ] Pool status banner
- [ ] Notification banners
- [ ] Page headers/titles
- [ ] Navigation menu
- [ ] Bottom navigation bar
- [ ] Event cards
- [ ] User avatars (swimmer icons)
- [ ] Buttons (elevated, outlined, text)
- [ ] Input fields
- [ ] Error messages
- [ ] Success messages
- [ ] Loading indicators
- [ ] Dialogs/modals

### Theme Modes
- [ ] Light mode
- [ ] Dark mode
- [ ] Toggle between modes to verify smooth transition

### Accessibility
- [ ] Text is readable against all backgrounds
- [ ] Icons are visible
- [ ] Interactive elements are distinguishable
- [ ] Focus indicators are visible

## 🚨 Important Guidelines

### Contrast Requirements
- **Text on backgrounds**: Minimum 4.5:1 ratio
- **Large text (18pt+)**: Minimum 3:1 ratio
- **Icons**: Minimum 3:1 ratio

### Consistency Rules
1. Keep primary colors the same in light/dark mode for brand recognition
2. Adjust badge colors for dark mode to maintain visibility
3. Text colors should always contrast well with their backgrounds
4. Status colors (success/warning) should be consistent across themes

### Best Practices
- Test on both large screens (desktop) and mobile
- Check in bright and dim lighting conditions
- Verify color transitions when switching themes
- Ensure disabled states are still distinguishable
- Keep success green and warnings/errors red/orange for convention

## 📝 Current Color Summary

### Light Mode Palette
```
Backgrounds:
  Main:     #C5DFF7 (Light Blue)
  Surface:  #C5DFF7 (Light Blue)
  Card:     #C5DFF7 (Light Blue)

Text:
  Primary:  #0A1420 (Dark Blue)
  
Brand:
  Primary:  #458FCD (Blue)
  
Status:
  Success:  #22C55E (Green)
  Warning:  #F36F47 (Orange)
  
Badges:
  Hosting:  #9C27B0 (Purple)
  Attending: #22C55E (Green)
  Waiting:  #F36F47 (Orange)
  Icon:     #FFFFFF (White)
```

### Dark Mode Palette
```
Backgrounds:
  Main:     #0D1B2A (Very Dark Blue)
  Surface:  #1B263B (Dark Blue-Grey)
  Card:     #415A77 (Medium Blue-Grey)

Text:
  Primary:  #E0E1DD (Light Grey)
  
Brand:
  Primary:  #458FCD (Blue)
  
Status:
  Success:  #22C55E (Green)
  Warning:  #F36F47 (Orange)
  
Badges:
  Hosting:  #CE93D8 (Light Purple)
  Attending: #22C55E (Green)
  Waiting:  #F36F47 (Orange)
  Icon:     #0A1420 (Dark Blue)
```

---

**Color Theme System Version**: 2.0  
**Last Updated**: October 11, 2025  
**Configuration File**: `lib/src/theme_colors.dart`  
**Total Centralized Colors**: 40+ (covering 100% of the app)
