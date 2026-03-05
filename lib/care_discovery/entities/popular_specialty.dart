import 'package:flutter/material.dart';

class PopularSpecialty {
  final String id;
  final String name;
  final String iconPath;
  final Color backgroundColor;
  final String? svgIcon;

  PopularSpecialty({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.backgroundColor,
    this.svgIcon,
  });

  factory PopularSpecialty.fromJson(Map<String, dynamic> json) {
    return PopularSpecialty(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      iconPath: json['icon_path'] ?? '',
      backgroundColor: json['background_color'] != null
          ? Color(int.parse(json['background_color'].toString().replaceFirst('#', '0xFF')))
          : Colors.grey,
      svgIcon: json['svg_icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_path': iconPath,
      'background_color': '#${backgroundColor.value.toRadixString(16).substring(2)}',
      'svg_icon': svgIcon,
    };
  }
}
