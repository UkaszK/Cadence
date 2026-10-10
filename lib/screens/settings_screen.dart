import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/app_settings.dart';
import 'package:cadence/providers/settings_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/get_duration_hours_and_minutes.dart';
import 'package:cadence/utils/sleep_time.dart';
import 'package:cadence/widgets/reusables/cadence_new_screen_container.dart';
import 'package:cadence/widgets/reusables/cadence_section_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return CadenceNewScreenContainer(
      children: [
        Text(
          'SETTINGS',
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.accent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(height: 32),
        settingsAsync.when(
          data: (settings) => _SleepSettings(settings: settings),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Error loading settings: $error'),
        ),
        const SizedBox(height: 48),
        const _VersionText(),
      ],
    );
  }
}

class _SleepSettings extends StatelessWidget {
  const _SleepSettings({required this.settings});

  final AppSettings settings;

  Future<void> _pickTime(
    BuildContext context, {
    required String title,
    required int currentMinutes,
    required void Function(int) onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      helpText: title,
      initialTime: TimeOfDay(
        hour: currentMinutes ~/ 60,
        minute: currentMinutes % 60,
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: CadenceColors.accent,
              onPrimary: CadenceColors.black,
              surface: CadenceColors.surface,
              onSurface: CadenceColors.textPrimary,
            ),
          ),
          child: child!,
        ),
      ),
    );
    if (picked != null) onPicked(picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = settings.sleepEnabled;
    final (hours, minutes) = getDurationHoursAndMinutes(
      sleepDurationMinutes(settings.bedtimeMinutes, settings.wakeUpMinutes),
    );
    final sameTime = settings.bedtimeMinutes == settings.wakeUpMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CadenceSectionHeader(
          title: 'PLANNED SLEEP',
          icon: Icons.bedtime_outlined,
          iconColor: CadenceColors.info,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    'Show in Planner',
                    style: GoogleFonts.jetBrainsMono(
                      color: CadenceColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Displays your sleep time as a band on the timeline.',
                    style: GoogleFonts.jetBrainsMono(
                      color: CadenceColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              activeThumbColor: CadenceColors.black,
              activeTrackColor: CadenceColors.accent,
              onChanged: (value) =>
                  SettingsService.setSleepEnabled(settings, value),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _TimeRow(
          label: 'Bedtime',
          icon: Icons.bedtime_outlined,
          minutes: settings.bedtimeMinutes,
          enabled: enabled,
          onTap: () => _pickTime(
            context,
            title: 'BEDTIME',
            currentMinutes: settings.bedtimeMinutes,
            onPicked: (value) => SettingsService.setBedtime(settings, value),
          ),
        ),
        _TimeRow(
          label: 'Wake-up',
          icon: Icons.wb_sunny_outlined,
          minutes: settings.wakeUpMinutes,
          enabled: enabled,
          onTap: () => _pickTime(
            context,
            title: 'WAKE-UP',
            currentMinutes: settings.wakeUpMinutes,
            onPicked: (value) => SettingsService.setWakeUp(settings, value),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          sameTime
              ? 'Bedtime and wake-up are the same, so no sleep is shown.'
              : '${hours}h ${minutes.toString().padLeft(2, '0')}m of planned sleep',
          style: GoogleFonts.jetBrainsMono(
            color: sameTime
                ? CadenceColors.warning
                : CadenceColors.textSecondary.withValues(
                    alpha: enabled ? 0.7 : 0.35,
                  ),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.icon,
    required this.minutes,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int minutes;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? CadenceColors.textPrimary
        : CadenceColors.textSecondary.withValues(alpha: 0.35);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          spacing: 12,
          children: [
            Icon(icon, size: 18, color: color),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.jetBrainsMono(color: color, fontSize: 13),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: enabled
                      ? CadenceColors.accent
                      : CadenceColors.textSecondary.withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                formatMinutesOfDay(minutes),
                style: GoogleFonts.jetBrainsMono(
                  color: enabled ? CadenceColors.accent : color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionText extends ConsumerWidget {
  const _VersionText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = GoogleFonts.jetBrainsMono(
      color: CadenceColors.textSecondary,
      fontSize: 11,
    );

    return ref.watch(packageInfoProvider).when(
      data: (info) {
        return Center(
          child: Text('CADENCE v${info.version}', style: style),
        );
      },
      loading: () => Center(
        child: Text('Loading Cadence version...', style: style),
      ),
      error: (error, _) => Column(
        children: [
          Text(
            error is MissingPluginException
                ? 'Cadence version unavailable. Rebuild and restart the app '
                      'to load the version plugin.'
                : 'Could not load Cadence version: $error',
            textAlign: TextAlign.center,
            style: style,
          ),
          TextButton(
            onPressed: () => ref.invalidate(packageInfoProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
