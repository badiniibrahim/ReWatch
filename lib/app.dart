import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:rewatch/generated/locales.g.dart';
import 'routes/app_pages.dart';
import 'core/di/initial_binding.dart';
import 'core/config/app_colors.dart';
import 'core/config/app_themes.dart';
import 'core/services/language_service.dart';
import 'core/services/platform_service.dart';

class App extends StatefulWidget {
  final String initialRoute;

  const App({super.key, required this.initialRoute});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Locale? _locale;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      InitialBinding().dependencies();
      await Future.delayed(const Duration(milliseconds: 100));
      final languageService = Get.find<LanguageService>();
      final locale = await languageService.getCurrentLocale();
      Get.updateLocale(locale);

      setState(() {
        _locale = locale;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locale = Get.deviceLocale ?? const Locale("fr");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Écran de chargement adaptatif
      if (PlatformService.isIOS) {
        return CupertinoApp(
          home: CupertinoPageScaffold(
            backgroundColor: AppColors.kSurface,
            child: Center(
              child: CupertinoActivityIndicator(color: AppColors.kPrimarySolid),
            ),
          ),
        );
      }
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.kPrimarySolid),
          ),
        ),
      );
    }

    return ScreenUtilInit(
      designSize: const Size(390, 844), // Design de base (iPhone)
      minTextAdapt: true,
      splitScreenMode: false,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        // Utiliser GetMaterialApp avec un builder qui adapte l'UI selon la plateforme
        // GetX ne supporte pas GetCupertinoApp, donc on utilise MaterialApp
        // mais avec des widgets Cupertino dans les vues sur iOS
        return GetMaterialApp(
          title: 'ReWatch',
          debugShowCheckedModeBanner: false,
          locale: _locale ?? Get.deviceLocale ?? const Locale("fr"),
          fallbackLocale: const Locale("fr"),
          // Utiliser le thème approprié selon la plateforme
          theme: PlatformService.isIOS
              ? AppThemes.lightTheme.copyWith(platform: TargetPlatform.iOS)
              : AppThemes.lightTheme,
          darkTheme: PlatformService.isIOS
              ? AppThemes.darkTheme.copyWith(platform: TargetPlatform.iOS)
              : AppThemes.darkTheme,
          themeMode: ThemeMode.system, // Le système décide (Light/Dark)
          initialRoute: widget.initialRoute,
          getPages: AppPages.routes,
          translationsKeys: AppTranslation.translations,
          initialBinding: InitialBinding(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
          builder: (context, child) {
            // Wrapper pour appliquer le thème Cupertino sur iOS
            if (PlatformService.isIOS) {
              return CupertinoTheme(
                data: AppThemes.cupertinoTheme,
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.0)),
                  child: child!,
                ),
              );
            }
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
    );
  }
}
