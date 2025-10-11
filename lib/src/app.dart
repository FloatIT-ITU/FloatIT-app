import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'package:provider/provider.dart';
import 'user_profile_provider.dart';
import 'pending_requests_provider.dart';
import 'notification_provider.dart';
import 'pool_status_provider.dart';
import 'theme_provider.dart';
import 'theme_colors.dart';
import 'core/presentation/design_system/design_system.dart';
// Firebase Auth is used by AuthGate; no direct import required here.

class FloatITApp extends StatelessWidget {
  const FloatITApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Push notifications are disabled in the production branch.
    return MultiProvider(
      providers: [
        // Do not eagerly call loadUserProfile here; let AuthGate trigger profile loading
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        // PendingRequestsProvider should be refreshed after sign-in as well
        ChangeNotifierProvider(create: (_) => PendingRequestsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => PoolStatusProvider()),
        // ThemeProvider: load stored preference when created
        ChangeNotifierProvider(create: (_) {
          final tp = ThemeProvider();
          tp.load();
          return tp;
        }),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: 'FloatIT',
          themeMode: theme.mode,
          theme: ThemeData(
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(
                seedColor: AppThemeColors.lightPrimary),
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppThemeColors.lightBackground,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeColors.lightPrimary,
                foregroundColor: AppThemeColors.lightText, // Text on buttons
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppThemeColors.lightPrimary),
                foregroundColor: AppThemeColors.lightText, // Text on outlined buttons
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: AppThemeColors.lightPrimary),
            ),
            appBarTheme: AppBarTheme(
                backgroundColor: AppThemeColors.lightPrimary,
                foregroundColor: AppThemeColors.lightText), // Text/icons on app bar
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppThemeColors.lightSurface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            listTileTheme: ListTileThemeData(
              tileColor: AppThemeColors.cardLight,
              iconColor: AppThemeColors.lightText, // Icons in list tiles
              textColor: AppThemeColors.lightText, // Text in list tiles
            ),
            snackBarTheme: SnackBarThemeData(
                backgroundColor: AppThemeColors.lightPrimary,
                contentTextStyle:
                    TextStyle(color: AppThemeColors.lightText)), // Text in snackbars
            cardTheme: CardTheme(
              color: AppThemeColors.cardLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              clipBehavior: Clip.antiAlias,
            ),
          ),
          darkTheme: ThemeData(
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(
                seedColor: AppThemeColors.darkPrimary,
                brightness: Brightness.dark),
            useMaterial3: true,
            brightness: Brightness.dark,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeColors.darkPrimary,
                foregroundColor: AppThemeColors.darkText,
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppThemeColors.darkPrimary),
                foregroundColor: AppThemeColors.darkText,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: AppThemeColors.darkPrimary),
            ),
            appBarTheme: AppBarTheme(
                backgroundColor: AppThemeColors.darkSurface,
                foregroundColor: AppThemeColors.darkText),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppThemeColors.darkSurface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            listTileTheme: ListTileThemeData(
              tileColor: AppThemeColors.cardDark,
              iconColor: AppThemeColors.darkText,
              textColor: AppThemeColors.darkText,
            ),
            snackBarTheme: SnackBarThemeData(
                backgroundColor: AppThemeColors.darkSurface,
                contentTextStyle:
                    TextStyle(color: AppThemeColors.darkText)),
            cardTheme: CardTheme(
              color: AppThemeColors.cardDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              clipBehavior: Clip.antiAlias,
            ),
          ),
          home: FloatITErrorBoundary(
            onError: (error, stackTrace) {
              // Log error to analytics or crash reporting service
            },
            child: const AuthGate(),
          ),
        ),
      ),
    );
  }
}
