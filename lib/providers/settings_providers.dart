import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cadence/data/app_settings.dart';
import 'package:cadence/data/isar_data_store.dart';

final settingsProvider = StreamProvider<AppSettings>((ref) {
  return IsarDataStore.watchSettings();
});

final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
  retry: (_, _) => null,
);

class SettingsService {
  static void setSleepEnabled(AppSettings current, bool enabled) =>
      IsarDataStore.saveSettings(current.copyWith(sleepEnabled: enabled));

  static void setBedtime(AppSettings current, int minutes) =>
      IsarDataStore.saveSettings(current.copyWith(bedtimeMinutes: minutes));

  static void setWakeUp(AppSettings current, int minutes) =>
      IsarDataStore.saveSettings(current.copyWith(wakeUpMinutes: minutes));
}
