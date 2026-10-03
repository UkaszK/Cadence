enum Day {
  monday(label: 'Monday', shortLabel: 'Mon'),
  tuesday(label: 'Tuesday', shortLabel: 'Tue'),
  wednesday(label: 'Wednesday', shortLabel: 'Wed'),
  thursday(label: 'Thursday', shortLabel: 'Thu'),
  friday(label: 'Friday', shortLabel: 'Fri'),
  saturday(label: 'Saturday', shortLabel: 'Sat'),
  sunday(label: 'Sunday', shortLabel: 'Sun');

  const Day({required this.label, required this.shortLabel});

  final String label;
  final String shortLabel;

  static Day fromDateTime(DateTime date) => Day.values[date.weekday - 1];
}
