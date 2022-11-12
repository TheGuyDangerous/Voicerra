import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:async';
import 'dart:convert';
import 'package:sound_stream/sound_stream.dart';
import 'package:voicerra/widget/BarIndicator.dart';
import 'package:voicerra/widget/customappbar.dart';
import 'package:web_socket_channel/io.dart';
import 'package:permission_handler/permission_handler.dart';

const serverUrl =
    'wss://api.deepgram.com/v1/listen?encoding=linear16&sample_rate=16000&language=en-GB';
const apiKey = '//Add your api token';

class ContinuousVoiceApp extends StatefulWidget {
  const ContinuousVoiceApp({Key? key}) : super(key: key);

  @override
  State<ContinuousVoiceApp> createState() => _ContinuousVoiceAppState();
}

class _ContinuousVoiceAppState extends State<ContinuousVoiceApp> {
  String myText = "To start transcribing your voice, press start.";

  final RecorderStream _recorder = RecorderStream();

  late StreamSubscription _recorderStatus;
  late StreamSubscription _audioStream;

  late IOWebSocketChannel channel;

  bool _isServiceActive = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(onLayoutDone);
  }

  @override
  void dispose() {
    _recorderStatus.cancel();
    _audioStream.cancel();
    channel.sink.close();

    super.dispose();
  }

  Future<void> _initStream() async {
    channel = IOWebSocketChannel.connect(Uri.parse(serverUrl),
        headers: {'Authorization': 'Token $apiKey'});

    channel.stream.listen((event) async {
      final parsedJson = jsonDecode(event);

      updateText(parsedJson['channel']['alternatives'][0]['transcript']);
    });

    _audioStream = _recorder.audioStream.listen((data) {
      channel.sink.add(data);
    });

    _recorderStatus = _recorder.status.listen((status) {
      if (mounted) {
        setState(() {});
      }
    });

    await Future.wait([
      _recorder.initialize(),
    ]);
  }

  void _startRecord() async {
    resetText();
    _initStream();

    await _recorder.start();

    setState(() {});
  }

  void _stopRecord() async {
    await _recorder.stop();

    setState(() {});
  }

  void onLayoutDone(Duration timeStamp) async {
    await Permission.microphone.request();
    setState(() {});
  }

  void updateText(newText) {
    setState(() {
      myText = myText + ' ' + newText;
    });
  }

  void resetText() {
    setState(() {
      myText = '';
    });
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
              title: 'Continuous\n'
                  'Transcription',
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
                decoration: BoxDecoration(
                  // background color of panel
                  color: Theme.of(context).colorScheme.onSecondary,
                  // rounded corners of panel
                  borderRadius: BorderRadius.only(
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
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                          'Transcribed Text',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontFamily: 'Raleway',
                            color: Theme.of(context).colorScheme.onBackground,
                            fontWeight: FontWeight.w400,
                          ),
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
                            myText,
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
                  borderRadius: BorderRadius.only(
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
                          myText,
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
                      height:
                          150), // spacing between the recording timer and tab bar

                  const SizedBox(
                    height: 150,
                  ), // TODO space between countdown and animation
                  //auto spacing for the upcoming record button
                  Padding(
                    //record button starts
                    padding: const EdgeInsets.only(
                        bottom: 24.0, left: 24.0, right: 24.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isServiceActive) {
                          _stopRecord();
                          _isServiceActive = false;
                        } else {
                          updateText('');
                          _isServiceActive = true;
                          _startRecord();
                        }
                      },
                      child: Icon(_isServiceActive ? Icons.stop : Icons.mic,size: 40,),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(15),
                        backgroundColor: _isServiceActive
                            ? Colors.red
                            : Colors.green,
                      )
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: myText));
    Fluttertoast.showToast(
      msg: "✓   Copied to Clipboard",
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
