import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'edit_note_page.dart';

void main() {
  runApp(const VoiceApp());
}

class VoiceApp extends StatelessWidget {
  const VoiceApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voicerra',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  elevation: 12,
                  minimumSize: const Size.square(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )))),
      home: const SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final Map<String, HighlightedWord> _highlights = {
    'project': HighlightedWord(
      // ignore: avoid_print
      onTap: () => print('project'),
      textStyle: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontFamily: 'Raleway',
          fontSize: 24.0),
    ),
    'exhibition': HighlightedWord(
      // ignore: avoid_print
      onTap: () => print('exhibition'),
      textStyle: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontFamily: 'Raleway',
          fontSize: 24.0),
    ),
    'group': HighlightedWord(
      // ignore: avoid_print
      onTap: () => print('group'),
      textStyle: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontFamily: 'Raleway',
          fontSize: 24.0),
    ),
  };

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Voicerra!';
  double _confidence = 1.0;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF2f2554),
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: const Color(0xFF2f2554),
          elevation: 0,
          centerTitle: true,
          title: Text(
              'Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%',
              style: const TextStyle(fontFamily: 'Raleway', fontSize: 24.0)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue.shade100),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                    overlayColor: getColor(
                      const Color(0xFFf6edfd),
                      const Color(0xFF2f2554),
                    )),
                onPressed: _listen,
                child: Icon(_isListening ? Icons.mic : Icons.mic_none),
              ),
              Expanded(child: Container()),
              FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.blue.shade100,
                foregroundColor: Colors.black,
                onPressed: () async {
                  setState(() => _isCopied = true);
                  await FlutterClipboard.copy(_text);
                  Fluttertoast.showToast(
                    msg: "✓   Copied to Clipboard",
                    toastLength: Toast.LENGTH_SHORT,
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddEditNotePage()));
                },
                child: const Icon(Iconsax.copy),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(50),
                topLeft: Radius.circular(50),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
              child: TextHighlight(
                text: _text,
                words: _highlights,
                textStyle: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 24.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ));
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

  getColor(Color color, Color colorPressed) {
    getColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        return colorPressed;
      } else {
        return color;
      }
    }

    return MaterialStateProperty.resolveWith(getColor);
  }
}
