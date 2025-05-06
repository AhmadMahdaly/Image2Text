import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.text,
    this.isActive = true,
    this.onTap,
    super.key,
  });

  final String text;
  final bool isActive;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return isActive
        ? InkWell(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 56,
            decoration: ShapeDecoration(
              color: Colors.brown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        )
        : InkWell(
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 56,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.grey[400] ?? Colors.grey,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[400] ?? Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
  }
}
