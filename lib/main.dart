import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:stash/pages/auth_gatekeeper.dart';
import 'package:stash/providers/theme_providers.dart';
import 'package:stash/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettingsAsync = ref.watch(themeSettingsProvider);

    return themeSettingsAsync.when(
      data: (themeSettings) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            // Determine which color scheme to use
            final bool useSystemColors = themeSettings.colorScheme == 'system';

            final ThemeData lightTheme = useSystemColors
                ? AppTheme.lightThemeFromColorScheme(lightDynamic)
                : AppTheme.stashLightTheme;

            final ThemeData darkTheme = useSystemColors
                ? AppTheme.darkThemeFromColorScheme(darkDynamic)
                : AppTheme.stashDarkTheme;

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeSettings.themeModeEnum,
              home: AuthGatekeeper(),
            );
          },
        );
      },
      error: (err, stackTrace) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.stashLightTheme,
        home: const AuthGatekeeper(),
      ),
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    );
  }
}
