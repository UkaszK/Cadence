import 'package:cadence/utils/sleep_time.dart';

/// Span of a single day in minutes after midnight, `start` inclusive.
typedef MinuteRange = ({int start, int end});

typedef _Segment = ({int start, int end, double pixelsPerMinute, double y});

/// Maps minutes of a day to vertical pixel offsets on the planner timeline.
///
/// [compressed] ranges (e.g. the night) are drawn at
/// [compressedPixelsPerMinute] so that empty hours don't dominate the view.
/// [expanded] ranges always use [normalPixelsPerMinute], which keeps planned
/// items inside a compressed range readable.
class PlannerTimeScale {
  PlannerTimeScale({
    List<MinuteRange> compressed = const [],
    List<MinuteRange> expanded = const [],
  }) : _compressed = List.unmodifiable(compressed),
       _expanded = List.unmodifiable(expanded),
       _segments = _buildSegments(compressed, expanded);

  static const double normalPixelsPerMinute = 1.0;
  static const double compressedPixelsPerMinute = 0.25;

  final List<MinuteRange> _compressed;
  final List<MinuteRange> _expanded;
  final List<_Segment> _segments;

  /// Copy of this scale with [ranges] additionally kept at normal scale.
  PlannerTimeScale withExpanded(List<MinuteRange> ranges) => PlannerTimeScale(
    compressed: _compressed,
    expanded: [..._expanded, ...ranges],
  );

  /// Consecutive ranges covering the whole day and whether each is drawn
  /// compressed.
  List<({int start, int end, bool compressed})> get segments => [
    for (final s in _segments)
      (
        start: s.start,
        end: s.end,
        compressed: s.pixelsPerMinute != normalPixelsPerMinute,
      ),
  ];

  double get height => yOf(minutesPerDay);

  bool isCompressedAt(num minute) =>
      _segmentForMinute(minute).pixelsPerMinute != normalPixelsPerMinute;

  double yOf(num minute) {
    final m = minute.clamp(0, minutesPerDay);
    final s = _segmentForMinute(m);
    return s.y + (m - s.start) * s.pixelsPerMinute;
  }

  double minuteAt(double y) {
    if (y <= 0) return 0;
    for (final s in _segments) {
      final segmentEndY = s.y + (s.end - s.start) * s.pixelsPerMinute;
      if (y <= segmentEndY) return s.start + (y - s.y) / s.pixelsPerMinute;
    }
    return minutesPerDay.toDouble();
  }

  _Segment _segmentForMinute(num minute) {
    for (final s in _segments) {
      if (minute < s.end) return s;
    }
    return _segments.last;
  }

  static List<_Segment> _buildSegments(
    List<MinuteRange> compressed,
    List<MinuteRange> expanded,
  ) {
    int clampMinute(int m) => m.clamp(0, minutesPerDay);
    final boundaries = <int>{
      0,
      minutesPerDay,
      for (final r in [...compressed, ...expanded]) ...[
        clampMinute(r.start),
        clampMinute(r.end),
      ],
    }.toList()..sort();

    bool covers(List<MinuteRange> ranges, double minute) =>
        ranges.any((r) => r.start <= minute && minute < r.end);

    final segments = <_Segment>[];
    var y = 0.0;
    for (var i = 0; i < boundaries.length - 1; i++) {
      final start = boundaries[i];
      final end = boundaries[i + 1];
      final mid = (start + end) / 2;
      final ppm = covers(compressed, mid) && !covers(expanded, mid)
          ? compressedPixelsPerMinute
          : normalPixelsPerMinute;

      if (segments.isNotEmpty && segments.last.pixelsPerMinute == ppm) {
        final last = segments.removeLast();
        segments.add((
          start: last.start,
          end: end,
          pixelsPerMinute: ppm,
          y: last.y,
        ));
      } else {
        segments.add((start: start, end: end, pixelsPerMinute: ppm, y: y));
      }
      y += (end - start) * ppm;
    }
    return segments;
  }
}
