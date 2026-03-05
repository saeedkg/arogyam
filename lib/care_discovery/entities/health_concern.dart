import 'package:flutter/material.dart';

class HealthConcern {
  final String id;
  final String name;
  final String subtitle;
  final String iconPath;
  final Color primaryColor;
  final String relatedSpecialty;

  HealthConcern({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.iconPath,
    required this.primaryColor,
    required this.relatedSpecialty,
  });

  factory HealthConcern.fromJson(Map<String, dynamic> json) {
    return HealthConcern(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      subtitle: json['subtitle'] ?? '',
      iconPath: json['icon_path'] ?? '',
      primaryColor: json['primary_color'] != null
          ? Color(int.parse(json['primary_color'].toString().replaceFirst('#', '0xFF')))
          : Colors.grey,
      relatedSpecialty: json['related_specialty'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'icon_path': iconPath,
      'primary_color': '#${primaryColor.value.toRadixString(16).substring(2)}',
      'related_specialty': relatedSpecialty,
    };
  }
}
