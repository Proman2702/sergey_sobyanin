import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.width,
    required this.height,
    required this.color,
    this.fontSize = 20,
    this.textColor = Colors.white,
  });
  final GestureTapCallback onTap;
  final String text;
  final double width;
  final double height;
  final Color color;
  final double fontSize;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(15),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
              width: width,
              height: height,
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(fontSize: fontSize, color: textColor, fontWeight: FontWeight.w700),
              )),
        ),
      ),
    );
  }
}

class CustomButtonModified extends StatelessWidget {
  const CustomButtonModified(
      {super.key,
      required this.onTap,
      required this.width,
      required this.height,
      required this.color,
      required this.child});
  final GestureTapCallback onTap;
  final double width;
  final double height;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(15),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(width: width, height: height, alignment: Alignment.center, child: child),
        ),
      ),
    );
  }
}
