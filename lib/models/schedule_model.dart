import 'dart:ui';

class HourModel {
  final String name;
  final String group;
  final String classroom;
  final int hour;
  final int day;
  final Color color;

  HourModel(
      this.hour, this.day, this.name, this.color, this.group, this.classroom);

  HourModel.fromJson(Map<String, dynamic> json)
      : hour = json['hour'],
        day = json['day'],
        name = json['name'],
        color = Color(json['color']),
        group = json['group'],
        classroom = json['classroom'];

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'day': day,
        'name': name,
        'color': color.value,
        'group': group,
        'classroom': classroom,
      };
}

enum TransactionType { add, remove, programed }

class TransactionModel {
  final DateTime date;
  final TransactionType type;
  DateTime programedDate = DateTime.now();
  final int credits;

  TransactionModel(
    this.date,
    this.type,
    this.credits,
    this.programedDate,
  );

  TransactionModel.fromJson(Map<String, dynamic> json)
      : date = DateTime.parse(json['date']),
        type = TransactionType.values[json['type']],
        credits = json['credits'],
        programedDate = DateTime.parse(json['programedDate']);

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'type': type.index,
        'credits': credits,
        'programedDate': programedDate.toIso8601String(),
      };
}

class ScheduleModel {
  final String name;
  final DateTime starts;
  final DateTime ends;
  final int creditValue;
  int creditsCount;
  List<HourModel> hours = [];
  List<TransactionModel> transactions = [];

  ScheduleModel(
      this.name, this.starts, this.ends, this.creditValue, this.creditsCount,
      {required this.hours, this.transactions = const []});

  ScheduleModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        starts = DateTime.parse(json['starts']),
        ends = DateTime.parse(json['ends']),
        creditValue = json['creditValue'],
        creditsCount = json['creditsCount'],
        hours = (json['hours'] as List<dynamic>)
            .map((hour) => HourModel.fromJson(hour))
            .toList(),
        transactions = (json['transactions'] as List<dynamic>)
            .map((transaction) => TransactionModel.fromJson(transaction))
            .toList();

  Map<String, dynamic> toJson() => {
        'name': name,
        'starts': starts.toIso8601String(),
        'ends': ends.toIso8601String(),
        'creditValue': creditValue,
        'creditsCount': creditsCount,
        'hours': hours.map((hour) => hour.toJson()).toList(),
        'transactions':
            transactions.map((transaction) => transaction.toJson()).toList(),
      };
}
