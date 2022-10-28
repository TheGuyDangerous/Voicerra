import 'package:flutter/material.dart';

class OptionsCard extends StatelessWidget {
  final iconName;
  final cardTitle;
  final pageName;

  const OptionsCard({
    super.key,
    required this.iconName,
    required this.cardTitle,
    required this.pageName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pageName),
          );
        },
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            color: Color(0xcdcabde4),
          ),
          child: Row(
            children: [
              Icon(iconName),
              const SizedBox(width: 10),
              Text(cardTitle),
            ],
          ),
        ),
      ),
    );
  }
}
