import 'package:flutter/material.dart';

class OptionsCard extends StatelessWidget {
  final iconName;
  final cardTitle;
  final pageName;
  Color darkGradientColor;
  Color lightGradientColor;
  Color iconColor;
  Color titleColor;

  OptionsCard({
    super.key,
    required this.iconName,
    required this.cardTitle,
    required this.pageName,
    required this.darkGradientColor,
    required this.lightGradientColor,
    required this.iconColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pageName),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: kElevationToShadow[1],
            gradient:
                LinearGradient(colors: [darkGradientColor, lightGradientColor]),
          ),
          child: Row(
            children: [
              Icon(
                iconName,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                cardTitle,
                style: TextStyle(
                  color: titleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
