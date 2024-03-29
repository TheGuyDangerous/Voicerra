import 'package:flutter/material.dart';
import 'package:voicerra/Screens/about_page.dart';
import 'package:voicerra/Screens/continuous.dart';
import 'package:voicerra/Screens/translate.dart';
import 'package:voicerra/widget/BarIndicator.dart';
import 'package:voicerra/widget/customappbar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:voicerra/widget/glass.dart';
import 'package:voicerra/widget/more_options_card_widget.dart';

class VoiceApp extends StatefulWidget {
  const VoiceApp({Key? key}) : super(key: key);

  @override
  State<VoiceApp> createState() => _VoiceAppState();
}

class _VoiceAppState extends State<VoiceApp> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the mic icon to start';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.3;
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.7;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            MyAppBar(
              title: 'Voicerra',
              onIconTap: _listen,
              iconName: Iconsax.microphone,
            ),
            SlidingUpPanel(
              minHeight: panelHeightClosed,
              maxHeight: panelHeightOpen,
              backdropEnabled: true, //darken background if panel is open
              parallaxEnabled: true,
              color: Colors.transparent,
              panel: Container(
                decoration: BoxDecoration(
                  // background color of panel
                  color: Theme.of(context).colorScheme.onSecondary,
                  // rounded corners of panel
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BarIndicator(),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                ),
                                Text(
                                  'Transcribed Text',
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    fontFamily: 'Raleway',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: _copy,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0x28ffffff)),
                                  borderRadius: BorderRadius.circular(16),
                                  color: const Color(0xff272727),
                                ),
                                child: const Icon(
                                  Iconsax.copy,
                                  size: 20,
                                  color: Color(0xa1ffffff),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextSelectionTheme(
                          data: const TextSelectionThemeData(
                              selectionColor: Colors.black,
                              selectionHandleColor: Colors.black),
                          child: SelectableText(
                            textAlign: TextAlign.center,
                            _text,
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 24.0,
                              color: Theme.of(context).colorScheme.onBackground,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              collapsed: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSecondary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                child: Column(
                  children: [
                    const BarIndicator(),
                    Center(
                      child: Text(
                        "Swipe Up for more",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontFamily: 'Raleway'),
                      ),
                    ),
                    const SizedBox(
                      height: 44,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextSelectionTheme(
                        data: const TextSelectionThemeData(
                            selectionColor: Colors.black,
                            selectionHandleColor: Colors.black),
                        child: SelectableText(
                          textAlign: TextAlign.center,
                          _text,
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 24.0,
                            color: Theme.of(context).colorScheme.onBackground,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  const SizedBox(
                    height: 130,
                  ),
                  SizedBox(
                    height: 60,
                    child: ListView(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children: [
                        OptionsCard(
                          cardTitle: 'Nonstop Mode',
                          iconName: Iconsax.microphone,
                          pageName: const ContinuousVoiceApp(),
                          iconColor: const Color(0xff006a53),
                          darkGradientColor: const Color(0xffd1ffeb),
                          titleColor: const Color(0xff006a53),
                          lightGradientColor: const Color(0xffd1ffeb),
                        ),
                        OptionsCard(
                          cardTitle: 'Translate',
                          iconName: Icons.translate,
                          pageName: const TranslatePage(),
                          iconColor: const Color(0xff006a53),
                          darkGradientColor: const Color(0xffd1ffeb),
                          titleColor: const Color(0xff006a53),
                          lightGradientColor: const Color(0xffd1ffeb),
                        ),
                        OptionsCard(
                          cardTitle: 'Settings',
                          iconName: Icons.person_outline_sharp,
                          pageName: const AboutPage(),
                          iconColor: const Color(0xff006a53),
                          darkGradientColor: const Color(0xffd1ffeb),
                          titleColor: const Color(0xff006a53),
                          lightGradientColor: const Color(0xffd1ffeb),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Glass(listening: _isListening, confidence: _confidence),
                  const Spacer(
                    flex: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        // ignore: avoid_print
        onStatus: (val) => print('onStatus: $val'),
        // ignore: avoid_print
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: _text));
    Fluttertoast.showToast(
      msg: "✓   Copied to Clipboard",
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
