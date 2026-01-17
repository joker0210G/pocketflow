import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 1)
class AppSettings {
  @HiveField(0)
  final String
      themeMode; // Stored as string 'Subject' to keep it simple or enum index

  @HiveField(1)
  final bool isFixedIncome;

  @HiveField(2)
  final double monthlyBills;

  @HiveField(3)
  final DateTime? nextPayDate;

  @HiveField(4)
  final int? customTermDays;

  @HiveField(5)
  final DateTime? termStartDate;

  const AppSettings({
    this.themeMode = 'ThemeMode.system',
    this.isFixedIncome = true,
    this.monthlyBills = 0.0,
    this.nextPayDate,
    this.customTermDays,
    this.termStartDate,
  });

  ThemeMode get themeModeEnum {
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == themeMode,
      orElse: () => ThemeMode.system,
    );
  }

  AppSettings copyWith({
    String? themeMode,
    bool? isFixedIncome,
    double? monthlyBills,
    DateTime? nextPayDate,
    int? customTermDays,
    DateTime? termStartDate,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      isFixedIncome: isFixedIncome ?? this.isFixedIncome,
      monthlyBills: monthlyBills ?? this.monthlyBills,
      nextPayDate: nextPayDate ?? this.nextPayDate,
      customTermDays: customTermDays ?? this.customTermDays,
      termStartDate: termStartDate ?? this.termStartDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'isFixedIncome': isFixedIncome,
      'monthlyBills': monthlyBills,
      'nextPayDate': nextPayDate?.toIso8601String(),
      'customTermDays': customTermDays,
      'termStartDate': termStartDate?.toIso8601String(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['themeMode'] as String? ?? 'ThemeMode.system',
      isFixedIncome: json['isFixedIncome'] as bool? ?? true,
      monthlyBills: (json['monthlyBills'] as num?)?.toDouble() ?? 0.0,
      nextPayDate: json['nextPayDate'] != null
          ? DateTime.parse(json['nextPayDate'] as String)
          : null,
      customTermDays: json['customTermDays'] as int?,
      termStartDate: json['termStartDate'] != null
          ? DateTime.parse(json['termStartDate'] as String)
          : null,
    );
  }
}
