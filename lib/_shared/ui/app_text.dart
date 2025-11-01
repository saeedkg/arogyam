import 'package:flutter/material.dart';

class AppText {
  static Text titleLarge(String text, {Color? color, int? maxLines, TextOverflow? overflow, bool? softWrap}) => Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: color,
        ),
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
      );

  static Text titleMedium(String text, {Color? color, int? maxLines, TextOverflow? overflow, bool? softWrap}) => Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
          color: color,
        ),
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
      );

  static Text label(String text, {Color? color, int? maxLines, TextOverflow? overflow, bool? softWrap}) => Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color ?? Colors.black87,
        ),
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
      );

  static Text bodySmall(String text, {Color? color, int? maxLines, TextOverflow? overflow, bool? softWrap}) => Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color ?? Colors.black54,
        ),
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
      );

  static Text labelMedium(
      String text, {
        Color? color,
        FontWeight? fontWeight,
        int? maxLines,
        TextAlign? textAlign,
      }) {
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        color: color ?? Colors.black87,
        fontWeight: fontWeight ?? FontWeight.w500,
      ),
    );
  }

}


