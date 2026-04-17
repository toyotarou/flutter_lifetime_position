class PositionModel {
  PositionModel({
    required this.year,
    required this.month,
    required this.day,
    required this.time,
    required this.userId,
    required this.latitude,
    required this.longitude,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      year: json['year'].toString(),
      month: json['month'].toString(),
      day: json['day'].toString(),
      time: json['time'] as String,
      userId: json['user_id'] is int ? json['user_id'] as int : int.parse(json['user_id'].toString()),
      latitude: json['latitude'].toString(),
      longitude: json['longitude'].toString(),
    );
  }

  final String year;
  final String month;
  final String day;
  final String time;
  final int userId;
  final String latitude;
  final String longitude;

  String get dateLabel => '$year/${month.padLeft(2, '0')}/${day.padLeft(2, '0')}';
}
