import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyAppBar extends StatelessWidget {
  final String title;
  VoidCallback onIconTap;
  // ignore: prefer_typing_uninitialized_variables
  final iconName;

  MyAppBar({
    Key? key,
    required this.onIconTap,
    required this.title,
    required this.iconName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                title,
                style: GoogleFonts.bebasNeue(
                  fontSize: 42,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onIconTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0x28ffffff)),
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              child: Icon(
                iconName,
                size: 36,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
