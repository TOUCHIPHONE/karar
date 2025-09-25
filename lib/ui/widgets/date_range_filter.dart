import 'package:flutter/material.dart';

class DateRangeFilter extends StatelessWidget {
  const DateRangeFilter({super.key, required this.onSelected});

  final ValueChanged<DateTimeRange?> onSelected;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      icon: const Icon(Icons.calendar_month),
      onPressed: () async {
        final now = DateTime.now();
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 1),
        );
        onSelected(range);
      },
    );
  }
}
