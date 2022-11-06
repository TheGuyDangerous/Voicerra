import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class BetaVoice extends StatefulWidget {
  const BetaVoice({Key? key}) : super(key: key);

  @override
  State<BetaVoice> createState() => _BetaVoiceState();
}

class _BetaVoiceState extends State<BetaVoice> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _speechAvailable = false;
  String _lastWords = '';
  String _currentWords = '';

  printLocales() async {
    var locales = await _speechToText.locales();
    for (var local in locales) {
      debugPrint(local.name);
    }
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void errorListener(SpeechRecognitionError error) {
    debugPrint(error.errorMsg.toString());
  }

  void statusListener(String status) async {
    debugPrint("status $status");
    if (status == "done" && _speechEnabled) {
      setState(() {
        _lastWords += " $_currentWords";
        _currentWords = "";
        _speechEnabled = false;
      });
      await _startListening();
    }
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechAvailable = await _speechToText.initialize(
        onError: errorListener, onStatus: statusListener);
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future _startListening() async {
    await _stopListening();
    await Future.delayed(const Duration(milliseconds: 50));
    await _speechToText.listen(
        onResult: _onSpeechResult,
        cancelOnError: true,
        partialResults: true,
        listenMode: ListenMode.dictation);
    setState(() {
      _speechEnabled = true;
    });
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future _stopListening() async {
    setState(() {
      _speechEnabled = false;
    });
    await _speechToText.stop();
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _currentWords = result.recognizedWords;
    });
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
        title: const Text('Transcription (Beta)',
            style: TextStyle(fontFamily: 'Raleway', fontSize: 24.0)),
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 10),
                  child: const Text(
                    '*Note: This is a highly experimental feature*',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 20.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _lastWords.isNotEmpty
                          ? '$_lastWords $_currentWords'
                          : _speechAvailable
                              ? 'Voicerra !'
                              : 'Speech not available',
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 24.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.black,
        onPressed:
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Tap to start Transcribing',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
