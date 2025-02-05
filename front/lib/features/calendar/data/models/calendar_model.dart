class CalendarModel {
  final int year;
  final int month;
  final List<CalendarRecord> records;

  CalendarModel({
    required this.year,
    required this.month,
    required this.records,
  });

  factory CalendarModel.fromJson(Map<String, dynamic> json) {
    return CalendarModel(
      year: json['year'] as int, // ✅ JSON에서 int로 변환
      month: json['month'] as int,
      records: (json['records'] as List)
          .map((e) => CalendarRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CalendarRecord {
  final int day;
  final bool hasRecord;
  final int totalCount;

  CalendarRecord({
    required this.day,
    required this.hasRecord,
    required this.totalCount,
  });

  factory CalendarRecord.fromJson(Map<String, dynamic> json) {
    return CalendarRecord(
      day: json['day'] as int, // ✅ 타입 명확히 지정
      hasRecord: json['hasRecord'] as bool,
      totalCount: json['totalCount'] as int,
    );
  }
}
