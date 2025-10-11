# FloatIT Color Theme System

This document explains how to customize the color palette for both light and dark modes in the FloatIT app.

## Overview

The app uses a centralized color system defined in `lib/src/theme_colors.dart`. All colors are applied through the MaterialApp theme configuration in `lib/src/app.dart`, ensuring consistent application across the entire app.

## Current Color Palette

### Light Mode
- **Primary/Main Color** (`#458fcd`): Used for menu items, event cards, buttons, sections, and highlights
- **Background** (`#c5dff7`): Main app background and surface colors
- **Text/Buttons** (`#0a1420`): Primary text color and button text
- **Success/Checkmarks** (`#22c55e`): Positive actions and confirmations
- **Warning/Errors** (`#f36f47`): Warnings and destructive actions

### Dark Mode
- Maintains the same primary colors for consistency
- Uses darker backgrounds (`#0d1b2a`, `#1b263b`) for proper contrast
- Light text (`#e0e1dd`) for readability on dark backgrounds

## How to Change Colors

### Step 1: Update Color Definitions

Edit `lib/src/theme_colors.dart`:

```dart
class AppThemeColors {
  // Light theme colors
  static const Color lightPrimary = Color(0xFF458FCD);    // Change this hex code
  static const Color lightBackground = Color(0xFFC5DFF7); // Change this hex code
  static const Color lightText = Color(0xFF0A1420);       // Change this hex code
  static const Color lightSuccess = Color(0xFF22C55E);    // Change this hex code
  static const Color lightWarning = Color(0xFFF36F47);    // Change this hex code

  // Dark theme colors
  static const Color darkPrimary = Color(0xFF458FCD);     // Change this hex code
  static const Color darkBackground = Color(0xFF0D1B2A);  // Change this hex code
  static const Color darkText = Color(0xFFE0E1DD);        // Change this hex code
  // ... etc
}
```

### Step 2: Convert Hex to Flutter Color

To convert a hex color like `#458fcd` to Flutter format:
1. Remove the `#`
2. Add `0xFF` prefix
3. Convert to uppercase: `Color(0xFF458FCD)`

### Step 3: Restart the App

After changing colors, restart the Flutter app to see the changes. Hot reload may not apply theme changes.

## Color Usage Guide

### Primary Colors
- `lightPrimary` / `darkPrimary`: Main brand color
  - Used for: Buttons, active states, highlights, menu items, event cards

### Background Colors
- `lightBackground` / `darkBackground`: Main app background
- `lightSurface` / `darkSurface`: Card backgrounds, elevated surfaces
- `cardLight` / `cardDark`: Specific card background colors

### Text Colors
- `lightText` / `darkText`: Primary text color
  - Used for: Button text, list item text, general UI text

### Status Colors
- `lightSuccess` / `darkSuccess`: Positive actions, checkmarks
- `lightWarning` / `darkWarning`: Errors, warnings, destructive actions

### Banner Colors
- `bannerGlobalLight/Dark`: Global notification banners
- `bannerEventLight/Dark`: Event-specific banners
- `bannerMainPagesLight/Dark`: Main page banners
- `bannerSubPagesLight/Dark`: Sub-page banners

## Helper Methods

The color system includes helper methods for theme-aware colors:

```dart
// Get primary color based on current theme
Color primaryColor = AppThemeColors.primary(context);

// Get success color based on current theme
Color successColor = AppThemeColors.success(context);

// Get warning color based on current theme
Color warningColor = AppThemeColors.warning(context);

// Get text color based on current theme
Color textColor = AppThemeColors.text(context);
```

## Best Practices

1. **Test Both Themes**: Always test color changes in both light and dark modes
2. **Maintain Contrast**: Ensure sufficient contrast ratios for accessibility
3. **Use Consistent Colors**: Stick to the defined color palette rather than inline colors
4. **Document Changes**: Update this document when adding new colors
5. **Restart Required**: Theme changes require app restart to take effect

## Adding New Colors

When adding new colors to the system:

1. Add them to `theme_colors.dart` with both light and dark variants
2. Update the theme configuration in `app.dart` if needed
3. Add documentation in this file
4. Test across all screens and components

## Troubleshooting

- **Colors not updating**: Restart the app (hot reload doesn't apply theme changes)
- **Inconsistent colors**: Check that you're using `AppThemeColors` constants instead of inline colors
- **Dark mode issues**: Ensure dark variants are properly defined and applied in the theme