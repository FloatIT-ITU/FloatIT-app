# FloatIT App - Complete Color Theme Guide# FloatIT Color Theme System



This document explains the complete color theme system and how to customize EVERY color in the app.This document explains how to customize the color palette for both light and dark modes in the FloatIT app.



## 📍 Color Configuration File## Overview



**All colors are centralized in:** `lib/src/theme_colors.dart`The app uses a centralized color system defined in `lib/src/theme_colors.dart`. All colors are applied through the MaterialApp theme configuration in `lib/src/app.dart`, ensuring consistent application across the entire app.



## 🎨 Complete Color Inventory## Current Color Palette



### 1. Light Mode Colors### Light Mode

- **Primary/Main Color** (`#458fcd`): Used for menu items, event cards, buttons, sections, and highlights

#### Primary Brand Colors- **Background** (`#c5dff7`): Main app background and surface colors

- **`lightPrimary`** - `#458FCD` (Blue)- **Text/Buttons** (`#0a1420`): Primary text color and button text

  - Used in: Menu items, buttons, active states, highlights, links- **Success/Checkmarks** (`#22c55e`): Positive actions and confirmations

- **`lightSecondary`** - `#458FCD` (Blue)- **Warning/Errors** (`#f36f47`): Warnings and destructive actions

  - Used in: Secondary buttons, less prominent elements

### Dark Mode

#### Backgrounds- Maintains the same primary colors for consistency

- **`lightBackground`** - `#C5DFF7` (Light Blue)- Uses darker backgrounds (`#0d1b2a`, `#1b263b`) for proper contrast

  - Used in: Main app background color- Light text (`#e0e1dd`) for readability on dark backgrounds

- **`lightSurface`** - `#C5DFF7` (Light Blue)

  - Used in: Cards, dialogs, bottom sheets, input field backgrounds## How to Change Colors

- **`cardLight`** - `#C5DFF7` (Light Blue)

  - Used in: Event cards, user cards, list item backgrounds### Step 1: Update Color Definitions



#### Text ColorsEdit `lib/src/theme_colors.dart`:

- **`lightText`** - `#0A1420` (Dark Blue)

  - Used in: All body text, headings, labels```dart

- **`lightOnBackground`** - `#0A1420` (Dark Blue)class AppThemeColors {

  - Used in: Text displayed directly on background  // Light theme colors

- **`lightOnPrimary`** - `#0A1420` (Dark Blue)  static const Color lightPrimary = Color(0xFF458FCD);    // Change this hex code

  - Used in: Text on primary color buttons and surfaces  static const Color lightBackground = Color(0xFFC5DFF7); // Change this hex code

  static const Color lightText = Color(0xFF0A1420);       // Change this hex code

#### Status Colors  static const Color lightSuccess = Color(0xFF22C55E);    // Change this hex code

- **`lightSuccess`** - `#22C55E` (Green)  static const Color lightWarning = Color(0xFFF36F47);    // Change this hex code

  - Used in: Success messages, checkmarks, confirmation indicators

- **`lightWarning`** - `#F36F47` (Orange)  // Dark theme colors

  - Used in: Warnings, errors, destructive action alerts  static const Color darkPrimary = Color(0xFF458FCD);     // Change this hex code

  static const Color darkBackground = Color(0xFF0D1B2A);  // Change this hex code

#### Badge Colors (for attendance status)  static const Color darkText = Color(0xFFE0E1DD);        // Change this hex code

- **`lightHostingBadge`** - `#9C27B0` (Purple)  // ... etc

  - Used in: "Hosting" badge background when user is event host}

- **`lightAttendingBadge`** - `#22C55E` (Green)```

  - Used in: "Attending" badge background when user is attending

- **`lightWaitingBadge`** - `#F36F47` (Orange)### Step 2: Convert Hex to Flutter Color

  - Used in: "Waiting List" badge background when user is on waiting list

- **`lightBadgeIcon`** - `#FFFFFF` (White)To convert a hex color like `#458fcd` to Flutter format:

  - Used in: Icons inside all badge circles (star, check, hourglass)1. Remove the `#`

2. Add `0xFF` prefix

### 2. Dark Mode Colors3. Convert to uppercase: `Color(0xFF458FCD)`



#### Primary Brand Colors### Step 3: Restart the App

- **`darkPrimary`** - `#458FCD` (Blue)

  - Same uses as light mode, maintains brand consistencyAfter changing colors, restart the Flutter app to see the changes. Hot reload may not apply theme changes.

- **`darkSecondary`** - `#458FCD` (Blue)

  - Same uses as light mode## Color Usage Guide



#### Backgrounds### Primary Colors

- **`darkBackground`** - `#0D1B2A` (Very Dark Blue)- `lightPrimary` / `darkPrimary`: Main brand color

  - Used in: Main app background in dark mode  - Used for: Buttons, active states, highlights, menu items, event cards

- **`darkSurface`** - `#1B263B` (Dark Blue-Grey)

  - Used in: Cards, dialogs, input fields, elevated surfaces### Background Colors

- **`cardDark`** - `#415A77` (Medium Blue-Grey)- `lightBackground` / `darkBackground`: Main app background

  - Used in: Event cards, user cards, distinguishable from surface- `lightSurface` / `darkSurface`: Card backgrounds, elevated surfaces

- `cardLight` / `cardDark`: Specific card background colors

#### Text Colors

- **`darkText`** - `#E0E1DD` (Light Grey)### Text Colors

  - Used in: All body text, headings, labels in dark mode- `lightText` / `darkText`: Primary text color

- **`darkOnBackground`** - `#E0E1DD` (Light Grey)  - Used for: Button text, list item text, general UI text

  - Used in: Text displayed directly on dark background

- **`darkOnPrimary`** - `#0A1420` (Dark Blue)### Status Colors

  - Used in: Text on primary color buttons (maintains contrast)- `lightSuccess` / `darkSuccess`: Positive actions, checkmarks

- `lightWarning` / `darkWarning`: Errors, warnings, destructive actions

#### Status Colors

- **`darkSuccess`** - `#22C55E` (Green)### Banner Colors

  - Same as light mode for consistency- `bannerGlobalLight/Dark`: Global notification banners

- **`darkWarning`** - `#F36F47` (Orange)- `bannerEventLight/Dark`: Event-specific banners

  - Same as light mode for consistency- `bannerMainPagesLight/Dark`: Main page banners

- `bannerSubPagesLight/Dark`: Sub-page banners

#### Badge Colors

- **`darkHostingBadge`** - `#CE93D8` (Light Purple)## Helper Methods

  - Lighter than light mode for visibility on dark backgrounds

- **`darkAttendingBadge`** - `#22C55E` (Green)The color system includes helper methods for theme-aware colors:

  - Same as light mode

- **`darkWaitingBadge`** - `#F36F47` (Orange)```dart

  - Same as light mode// Get primary color based on current theme

- **`darkBadgeIcon`** - `#0A1420` (Dark Blue)Color primaryColor = AppThemeColors.primary(context);

  - Dark icons on light badges for dark mode

// Get success color based on current theme

### 3. Banner ColorsColor successColor = AppThemeColors.success(context);



#### Banner Backgrounds// Get warning color based on current theme

All banners use consistent colors across light/dark modes:Color warningColor = AppThemeColors.warning(context);

- **`bannerGlobalLight/Dark`** - `#458FCD` (Blue)

  - Used in: Global notification banners (admin announcements)// Get text color based on current theme

- **`bannerEventLight/Dark`** - `#458FCD` (Blue)Color textColor = AppThemeColors.text(context);

  - Used in: Event-specific notification banners```

- **`bannerMainPagesLight/Dark`** - `#458FCD` (Blue)

  - Used in: Main page top bars## Best Practices

- **`bannerSubPagesLight/Dark`** - `#458FCD` (Blue)

  - Used in: Sub-page top bars1. **Test Both Themes**: Always test color changes in both light and dark modes

2. **Maintain Contrast**: Ensure sufficient contrast ratios for accessibility

#### Banner Text Colors3. **Use Consistent Colors**: Stick to the defined color palette rather than inline colors

- **`bannerTextLight`** - `#0A1420` (Dark Blue)4. **Document Changes**: Update this document when adding new colors

  - Used in: Page title text in light mode5. **Restart Required**: Theme changes require app restart to take effect

- **`bannerTextDark`** - `#E0E1DD` (Light Grey)

  - Used in: Page title text in dark mode## Adding New Colors

- **`bannerGlobalTextLight/Dark`** - `#0A1420` (Dark Blue)

  - Used in: Text inside global notification bannersWhen adding new colors to the system:

- **`bannerEventTextLight/Dark`** - `#0A1420` (Dark Blue)

  - Used in: Text inside event notification banners1. Add them to `theme_colors.dart` with both light and dark variants

2. Update the theme configuration in `app.dart` if needed

### 4. Special Purpose Colors3. Add documentation in this file

4. Test across all screens and components

- **`systemMessageColor`** - `#FFFFFF` (White)

  - Used in: System-generated messages in chats## Troubleshooting

- **`transparent`** - Fully transparent

  - Used in: Transparent overlays, spacers- **Colors not updating**: Restart the app (hot reload doesn't apply theme changes)

- **`shadow`** - `rgba(0,0,0,0.1)` (10% black)- **Inconsistent colors**: Check that you're using `AppThemeColors` constants instead of inline colors

  - Used in: Drop shadows on cards, elevated elements- **Dark mode issues**: Ensure dark variants are properly defined and applied in the theme
- **`primaryOverlayLow`** - `rgba(69,143,205,0.08)` (8% primary)
  - Used in: Subtle hover states, pressed states

## 🔧 How to Change Colors

### Step 1: Open the Color File
Navigate to: `lib/src/theme_colors.dart`

### Step 2: Find the Color You Want to Change
Use the categories above to locate the specific color constant.

### Step 3: Update the Hex Value
```dart
// Example: Change primary color from blue to green
static const Color lightPrimary = Color(0xFF22C55E); // Was: 0xFF458FCD
static const Color darkPrimary = Color(0xFF22C55E);  // Keep consistent
```

### Step 4: Update Related Colors
If changing primary, consider updating:
- Secondary colors
- Banner colors
- Any colors that should match the primary

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
