import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';

class Glass extends StatelessWidget {
  bool listening;
  final confidence;

  Glass({
    super.key,
    required this.listening,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicFlexContainer(
      borderRadius: 30,
      blur: 10,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      alignment: Alignment.bottomCenter,
      border: 1,
      linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.onBackground.withOpacity(0.05),
            Theme.of(context).colorScheme.onBackground.withOpacity(0.05),
          ],
          stops: const [
            0.1,
            1,
          ]),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.onBackground.withOpacity(0.05),
          Theme.of(context).colorScheme.onBackground.withOpacity(0.05),
        ],
      ),
      child: Center(
        child: Container(
          child: listening
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: SizedBox(
                    child: LoadingIndicator(
                      indicatorType: Indicator.lineScalePulseOutRapid,
                      colors: [
                        Color(0xffcabde4),
                        Colors.deepPurpleAccent,
                        Color(0xFFFF0005),
                      ],
                    ),
                  ),
                )
              : Text(
                  'Accuracy: ${(confidence * 100.0).toStringAsFixed(1)}%',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
        ),
      ),
    );
  }
}
