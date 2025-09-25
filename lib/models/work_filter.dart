import 'package:equatable/equatable.dart';

class DateRangeFilter extends Equatable {
  const DateRangeFilter({this.start, this.end});

  final DateTime? start;
  final DateTime? end;

  bool get isActive => start != null || end != null;

  @override
  List<Object?> get props => [start, end];
}

class WorkFilter extends Equatable {
  const WorkFilter({
    this.workerName,
    this.dateRange = const DateRangeFilter(),
    this.searchTerm,
  });

  final String? workerName;
  final DateRangeFilter dateRange;
  final String? searchTerm;

  WorkFilter copyWith({
    String? workerName,
    DateTime? start,
    DateTime? end,
    DateRangeFilter? dateRange,
    String? searchTerm,
  }) {
    return WorkFilter(
      workerName: workerName ?? this.workerName,
      dateRange: dateRange ?? DateRangeFilter(
        start: start ?? this.dateRange.start,
        end: end ?? this.dateRange.end,
      ),
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  Map<String, dynamic> toQueryMap() {
    return {
      'workerName': workerName,
      'start': dateRange.start?.toIso8601String(),
      'end': dateRange.end?.toIso8601String(),
      'searchTerm': searchTerm,
    };
  }

  @override
  List<Object?> get props => [workerName, dateRange, searchTerm];
}
