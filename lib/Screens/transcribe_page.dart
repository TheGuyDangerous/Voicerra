import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:io';
import 'dart:async';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';

class TranscribePage extends StatefulWidget {
  final String title;

  const TranscribePage({super.key, required this.title});

  @override
  State<TranscribePage> createState() => _TranscribePageState();
}

class _TranscribePageState extends State<TranscribePage> {
  bool isTranscribing = false;
  String content = '';
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
    return Scaffold(
      backgroundColor: const Color(0xFF2f2554),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF2f2554),
        elevation: 0,
        centerTitle: true,
        title: const Text('Transcribe Your Audio',
            style: TextStyle(
                fontFamily: 'Raleway', fontSize: 24.0, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Color(0xFFf2f2f2),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(50),
              topLeft: Radius.circular(50),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 50,
                ),
                Container(
                  height: 200,
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: content == ''
                      ? const Center(
                          child: Text(
                            'Your text will appear here',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Center(
                          child: Text(
                            content,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                ),
                const SizedBox(
                  height: 10,
                ),
                //Transcribe button
                Container(
                  child: isTranscribing
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 150, vertical: 70),
                          child: SizedBox(
                            child: LoadingIndicator(
                              indicatorType: Indicator.lineScalePulseOutRapid,
                              colors: [
                                Colors.red,
                                Color(0xFF2f2554),
                                Color(0xFFD1C4E9),
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
                                color: const Color(0xFFD1C4E9),
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
                                        color: Color(0xFF512DA8),
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
                                            color: Color(0xFF512DA8),
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
        ),
      ),
    );
  }
}
