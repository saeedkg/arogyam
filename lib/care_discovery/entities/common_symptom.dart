import 'package:flutter/material.dart';

class CommonSymptom {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final Color backgroundColor;
  final Color iconColor;
  final List<String> relatedSpecialties;

  CommonSymptom({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.backgroundColor,
    required this.iconColor,
    required this.relatedSpecialties,
  });

  factory CommonSymptom.fromJson(Map<String, dynamic> json) {
    return CommonSymptom(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconPath: json['icon_path'] ?? '',
      backgroundColor: json['background_color'] != null
          ? Color(int.parse(json['background_color'].toString().replaceFirst('#', '0xFF')))
          : Colors.grey,
      iconColor: json['icon_color'] != null
          ? Color(int.parse(json['icon_color'].toString().replaceFirst('#', '0xFF')))
          : Colors.black,
      relatedSpecialties: json['related_specialties'] != null
          ? List<String>.from(json['related_specialties'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_path': iconPath,
      'background_color': '#${backgroundColor.value.toRadixString(16).substring(2)}',
      'icon_color': '#${iconColor.value.toRadixString(16).substring(2)}',
      'related_specialties': relatedSpecialties,
    };
  }
}
