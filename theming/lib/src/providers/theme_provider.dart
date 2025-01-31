import 'package:flutter/material.dart';
import 'package:misc_utils/misc_utils.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:theming/src/models/theme.dart';

part 'theme_provider.g.dart';

/// Override this provider in your app with your default app color
@Riverpod(keepAlive: true)
Color defaultAppColor(Ref ref) => const Color(0xFFFF00FF);

@Riverpod(keepAlive: true)
class ThemeSettings extends _$ThemeSettings with Persistable {
  static const String storageKey = 'theme';

  @override
  FutureOr<AppTheme> build() async {
    final storedJSON = await loadFromStorage(storageKey);
    if (storedJSON != null) {
      return AppTheme.fromJson(storedJSON);
    }
    final defaultColor = ref.watch(defaultAppColorProvider);
    return AppTheme(primaryColor: defaultColor);
  }

  Future<void> setPrimaryColor(Color primaryColor) async {
    state = await AsyncValue.guard(() async {
      final AppTheme update = state.maybeWhen(
        data: (data) => data.copyWith(primaryColor: primaryColor),
        orElse: () => AppTheme(primaryColor: primaryColor),
      );
      await persistJSON(storageKey, update.toJson());
      return update;
    });
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = await AsyncValue.guard(() async {
      final defaultColor = ref.watch(defaultAppColorProvider);
      final AppTheme update = state.maybeWhen(
        data: (data) => data.copyWith(themeMode: themeMode),
        orElse: () =>
            AppTheme(themeMode: themeMode, primaryColor: defaultColor),
      );
      await persistJSON(storageKey, update.toJson());
      return update;
    });
  }

  Future<void> setLocale(String? locale) async {
    state = await AsyncValue.guard(() async {
      final defaultColor = ref.watch(defaultAppColorProvider);
      final AppTheme update = state.maybeWhen(
        data: (data) => data.copyWith(locale: locale),
        orElse: () => AppTheme(locale: locale, primaryColor: defaultColor),
      );
      await persistJSON(storageKey, update.toJson());
      return update;
    });
  }
}
