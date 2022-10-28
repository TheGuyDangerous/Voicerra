import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_speech/google_speech.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:io';
import 'dart:async';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:voicerra/widget/BarIndicator.dart';
import 'package:voicerra/widget/customappbar.dart';
import 'package:clipboard/clipboard.dart';

class TranscribePage extends StatefulWidget {
  final String title;

  const TranscribePage({super.key, required this.title});

  @override
  State<TranscribePage> createState() => _TranscribePageState();
}

class _TranscribePageState extends State<TranscribePage> {
  bool isTranscribing = false;
  String content = 'Select any audio from Storage';
  File? file;

  void transcribe() async {
    setState(() {
      isTranscribing = true;
    });
    final serviceAccount = ServiceAccount.fromString(
        (await rootBundle.loadString('assets/cloud.json')));
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);

    final config = RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        model: RecognitionModel.basic,
        enableAutomaticPunctuation: true,
        sampleRateHertz: 16000,
        languageCode: 'en-US');

    final audio = await _getAudioContent('temp.wav');
    await speechToText.recognize(config, audio).then((value) {
      setState(() {
        content = value.results
            .map((e) => e.alternatives.first.transcript)
            .join('\n');
      });
    }).whenComplete(() {
      setState(() {
        isTranscribing = false;
      });
    });
  }

  Future _getAudioContent(String name) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['wav'],
    );
    if (result == null) return;
    final path = result.files.single.path!;
    setState(() => file = File(path));
    return File(path).readAsBytesSync().toList();
  }

  @override
  void initState() {
    setPermissions();
    super.initState();
  }

  void setPermissions() async {
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
  }

  @override
  Widget build(BuildContext context) {
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.3;
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.7;
    return Scaffold(
      backgroundColor: const Color(0xff1c1c1e),
      body: SafeArea(
        child: Stack(
          children: [
            MyAppBar(
              title: 'Online Transcriber',
              onIconTap: _copy,
              iconName: Iconsax.copy,
            ),
            SlidingUpPanel(
              minHeight: panelHeightClosed,
              maxHeight: panelHeightOpen,
              backdropEnabled: true, //darken background if panel is open
              parallaxEnabled: true,
              color: Colors.transparent,
              panel: Container(
                decoration: const BoxDecoration(
                  // background color of panel
                  color: Color(0xFF212025),
                  // rounded corners of panel
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BarIndicator(),
                    const Text(
                      'Transcribed Text',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontFamily: 'Raleway',
                        color: Color(0xa3ffffff),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        content,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 24.0,
                          color: Color(0xd8ffffff),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              collapsed: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF212025),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                child: Column(
                  children: [
                    const BarIndicator(),
                    const Center(
                      child: Text(
                        "Swipe Up for more",
                        style: TextStyle(
                            color: Color(0xa3ffffff), fontFamily: 'Raleway'),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        content,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 24.0,
                          color: Color(0xd8ffffff),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  Container(
                    child: isTranscribing
                        ? const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 150, vertical: 70),
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
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: isTranscribing ? () {} : transcribe,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 25, horizontal: 15),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  color: const Color(0x1acabde4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      children: const [
                                        SizedBox(
                                          width: 35.0,
                                        ),
                                        Icon(
                                          Iconsax.folder,
                                          size: 30,
                                          color: Color(0xFF2D50A8),
                                        ),
                                        SizedBox(
                                          width: 25.0,
                                        ),
                                        Center(
                                          child: Text(
                                            'Pick an audio file',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Raleway',
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2D50A8),
                                              fontSize: 17.0,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copy() async {
    await FlutterClipboard.copy(content);
    Fluttertoast.showToast(
      msg: "✓   Copied to Clipboard",
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
