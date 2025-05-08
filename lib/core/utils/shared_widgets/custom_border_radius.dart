import 'package:flutter/material.dart';

OutlineInputBorder customBorderRadius() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.grey[400] ?? Colors.grey),
  );
}
