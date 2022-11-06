import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:voicerra/utils/utils.dart';
import 'package:voicerra/widget/BarIndicator.dart';
import 'package:wakelock/wakelock.dart';

class RecPage extends StatefulWidget {
  const RecPage({super.key});

  @override
  State<RecPage> createState() => _RecPageState();
}

typedef Fn = void Function();

class _RecPageState extends State<RecPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  FlutterSoundPlayer? audioPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  final Codec _codec = Codec.pcm16WAV;
  final String _fileExtension = 'wav';
  Duration duration = const Duration();
  List<int> audiosPlaying = [];

  bool isPlaying(int index) => audiosPlaying.contains(index);

  @override
  void initState() {
    super.initState();

    openTheRecorder();
    audioPlayer!.openPlayer();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    audioPlayer!.closePlayer();
    audioPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;

    super.dispose();
  }

  Future<void> openTheRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission denied');
    }

    await _mRecorder?.setLogLevel(Level.nothing);
    await _mRecorder!.openRecorder();
  }

  void record() async {
    Directory? applicationDirectory = await getDirectory();
    bool canVibrate = await Vibrate.canVibrate;
    stopAudio();

    _mRecorder!
        .startRecorder(
      toFile: '${applicationDirectory.path}/temp.$_fileExtension',
      codec: _codec,
    )
        .then((_) async {
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      await Wakelock.enable();
      if (canVibrate) {
        Vibrate.feedback(FeedbackType.success);
      }
      setState(() {});
    });
  }

  void stopRecorder(String newTitle) async {
    await _mRecorder!.stopRecorder().then((value) async {
      bool canVibrate = await Vibrate.canVibrate;
      if (canVibrate) {
        Vibrate.feedback(FeedbackType.success);
      }
      setState(() {
        _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
      });

      Directory? applicationDirectory = await getDirectory();
      File audioFile =
          File('${applicationDirectory.path}/temp.$_fileExtension');

      await audioFile
          .rename('${applicationDirectory.path}/$newTitle.$_fileExtension');
      await Wakelock.disable();
    });
  }

  void pauseRecorder() async {
    await _mRecorder!.pauseRecorder().then((_) async {
      bool canVibrate = await Vibrate.canVibrate;
      if (canVibrate) {
        Vibrate.feedback(FeedbackType.success);
      }
      setState(() {
        _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      });
      await Wakelock.disable();
    });
  }

  void resumeRecorder() async {
    await _mRecorder!.resumeRecorder().then((_) async {
      bool canVibrate = await Vibrate.canVibrate;
      if (canVibrate) {
        Vibrate.feedback(FeedbackType.success);
      }
      setState(() {
        _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      });
      await Wakelock.enable();
    });
  }

  void cancelRecord() async {
    Directory? applicationDirectory = await getDirectory();
    bool canVibrate = await Vibrate.canVibrate;

    await _mRecorder!.stopRecorder().then((value) async {
      if (canVibrate) {
        Vibrate.feedback(FeedbackType.success);
      }
      setState(() {
        _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
        _mRecorder!.deleteRecord(
            fileName: '${applicationDirectory.path}/temp.$_fileExtension');
      });
      await Wakelock.disable();
    });
  }

  Fn? getRecorderFn() {
    if (!audioPlayer!.isStopped) {
      return null;
    }

    if (_mRecorder!.isRecording) {
      return pauseRecorder;
    }

    if (_mRecorder!.isPaused) {
      return resumeRecorder;
    }

    return record;
  }

  void stopAudio() async {
    await audioPlayer!.stopPlayer();
    audiosPlaying.clear();
  }

  void pauseAudio() async {
    await audioPlayer!.pausePlayer();
    audiosPlaying.clear();
  }

  void playAudio(String path, int index) async {
    duration = (await audioPlayer!.startPlayer(
      fromURI: path,
      whenFinished: () {
        setState(() {
          audiosPlaying.clear();
        });
      },
    ))!;
    setState(() {
      audiosPlaying.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    void saveAudioBottomSheet() async {
      //TO SAVE AUDIO USING BOTTOM SHEET
      TextEditingController recordingTitle = TextEditingController();
      String? selectedCategory;

      await showSlidingBottomSheet(
        context,
        builder: (BuildContext context) {
          //record bottom sheet builder
          return SlidingSheetDialog(
            elevation: 8,
            cornerRadius: 15,
            color: Theme.of(context).colorScheme.onSecondary,
            builder: (context, state) {
              return Material(
                child: StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return Container(
                      color: Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 30, bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              'Save Recording', //record bottom sheet title
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 20.0,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: recordingTitle,
                            style: const TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 16.0,
                              color: Color(0xFF777777),
                              fontWeight: FontWeight.w300,
                            ),
                            maxLength: 30,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[\p{L}\p{N} ]+$', unicode: true))
                            ],
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText:
                                  'Name the recording', //record bottom sheet hint text
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
            footerBuilder: (context, state) {
              //SAVE OR CANCEL BOTTOM SHEET BUTTONS
              return Container(
                color: Theme.of(context).colorScheme.onSecondary,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24.0, right: 24.0, bottom: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff006a53),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide.none,
                                ),
                              ),
                              child: Text(
                                'Cancel', //cancel button of record bottom sheet
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 16.0,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                String now =
                                    DateFormat('h_mm a - EEE, d MMM, yyyy')
                                        .format(DateTime.now());
                                String title =
                                    recordingTitle.text.trim().isEmpty
                                        ? 'Recording_$now'
                                        : recordingTitle.text.trim();

                                if (selectedCategory != null &&
                                    selectedCategory.isNotEmpty) {
                                  title = '$selectedCategory/$title';
                                }

                                stopRecorder(title);
                                Navigator.pop(context);
                              },
                              style: Theme.of(context)
                                  .elevatedButtonTheme
                                  .style!
                                  .copyWith(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .buttonTheme
                                                  .colorScheme
                                                  ?.primary)),
                              child: Text(
                                'Save', //save button of record bottom sheet
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .buttonTheme
                                            .colorScheme
                                            ?.secondary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    void rename(File file) async {
      //rename function
      String path = file.path;

      TextEditingController recordingTitle = TextEditingController();
      String? selectedCategory;

      await showSlidingBottomSheet(
        //rename bottom sheet builder
        context,
        builder: (BuildContext context) {
          return SlidingSheetDialog(
            elevation: 8,
            cornerRadius: 15,
            color: Colors.transparent, //rename bottom sheet color
            builder: (context, state) {
              return Material(
                child: StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return Container(
                      color: Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 30, bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              'Rename', //rename bottom sheet title
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextField(
                            controller: recordingTitle,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(fontSize: 16),
                            maxLength: 30,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[\p{L}\p{N} ]+$', unicode: true))
                            ],
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText:
                                  'New Name', //rename bottom sheet hint text
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
            footerBuilder: (context, state) {
              return Container(
                //bottom Save or Cancel buttons of record bottom sheet
                color: Theme.of(context).colorScheme.onSecondary,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24.0, right: 24.0, bottom: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: Theme.of(context)
                                  .elevatedButtonTheme
                                  .style!
                                  .copyWith(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .buttonTheme
                                                  .colorScheme
                                                  ?.secondary)),
                              child: Text(
                                'Cancel', //cancel button of rename bottom sheet
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              //save button for rename
                              onPressed: () async {
                                String now =
                                    DateFormat.yMMMMd().format(DateTime.now());
                                String title =
                                    recordingTitle.text.trim().isEmpty
                                        ? 'Recording_$now'
                                        : recordingTitle.text.trim();
                                int lastSeparator =
                                    path.lastIndexOf(Platform.pathSeparator);

                                if (selectedCategory != null &&
                                    selectedCategory.isNotEmpty) {
                                  title = '$selectedCategory/$title';
                                }

                                String newPath =
                                    path.substring(0, lastSeparator + 1) +
                                        title +
                                        _fileExtension;

                                await file.rename(newPath);
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              },
                              style: Theme.of(context)
                                  .elevatedButtonTheme
                                  .style!
                                  .copyWith(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .buttonTheme
                                                  .colorScheme
                                                  ?.primary)),
                              child: Text(
                                'Save', //save of rename bottom sheet
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .buttonTheme
                                            .colorScheme
                                            ?.secondary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    void delete(File file) async {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //popup dialogue fo delete option
            elevation: 8,
            backgroundColor: Theme.of(context).colorScheme.onTertiary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Center(
              child: const Text(
                'Are you sure bro ?',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: Theme.of(context)
                        .elevatedButtonTheme
                        .style!
                        .copyWith(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context)
                                    .buttonTheme
                                    .colorScheme
                                    ?.secondary)),
                    child: Text(
                      'No', //No button for delete popup dialogue
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      await file.delete();
                      setState(() {});
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    style: Theme.of(context)
                        .elevatedButtonTheme
                        .style!
                        .copyWith(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context)
                                    .buttonTheme
                                    .colorScheme
                                    ?.primary)),
                    child: Text(
                      'Yes', // yes button for delete popup dialogue
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontSize: 16,
                          color: Theme.of(context)
                              .buttonTheme
                              .colorScheme
                              ?.secondary),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    final panelHeightClosed = MediaQuery.of(context).size.height * 0.3;
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.7;
    return Scaffold(
      //scaffold of the recording page
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Recorder',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 52,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 62,
                    width: 62,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0x28ffffff)),
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    child: Container(
                        child: _mRecorder!.isRecording
                            ? const LoadingIndicator(
                                indicatorType: Indicator.lineScalePulseOutRapid,
                                colors: [
                                  Color(0xffcabde4),
                                  Colors.deepPurpleAccent,
                                  Color(0xFFFF0005),
                                ],
                              )
                            : Icon(
                                FluentIcons.record_12_regular,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                size: 36,
                              )),
                  ),
                ],
              ),
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
                      Text(
                        'Recordings',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontFamily: 'Raleway',
                          color: Theme.of(context).colorScheme.onBackground,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 10.0, bottom: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder(
                                future: getDirectory(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<dynamic> snapshot) {
                                  if (snapshot.hasData) {
                                    Directory dir = snapshot.data;
                                    List<FileSystemEntity?> audiosFiles = dir
                                        .listSync(
                                            recursive: true, followLinks: false)
                                        .map((file) {
                                      if (file.statSync().type ==
                                          FileSystemEntityType.file) {
                                        return file;
                                      }
                                    }).toList();

                                    audiosFiles.removeWhere(
                                        (element) => element == null);

                                    if (audiosFiles.isEmpty) {
                                      return Center(
                                        child: Text(
                                          'No recordings', // show when there are no recordings saved
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      );
                                    }

                                    return ListView.builder(
                                      //builds for sliding panel is open
                                      //list view to display the recordings in a list
                                      shrinkWrap: true,
                                      physics:
                                          const BouncingScrollPhysics(), //bouncing physics
                                      itemCount: audiosFiles.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        File audioFile =
                                            File(audiosFiles[index]!.path);

                                        DateFormat dayFormat = DateFormat.yMd();
                                        DateFormat timeFormat = DateFormat.Hm();
                                        String fileSize = getFileSize(
                                            audioFile.lengthSync(), 1);
                                        DateTime createdAt =
                                            audioFile.lastModifiedSync();
                                        String createdAtFormatted = '';
                                        String fileName = audioFile.name ??
                                            'Recording'; //checks if file name starts with recording

                                        if (createdAt.isToday()) {
                                          createdAtFormatted =
                                              timeFormat.format(createdAt);
                                        } else {
                                          createdAtFormatted =
                                              dayFormat.format(createdAt);
                                        }

                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(15)),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onTertiary,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 5, top: 5),
                                              child: ListTile(
                                                onTap: () {},
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        fileName, //name of the file formatting inside the list of recordings
                                                        maxLines: 1,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline2,
                                                      ),
                                                    ),
                                                    Text(
                                                      createdAtFormatted,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2,
                                                    )
                                                  ],
                                                ),
                                                subtitle: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    if (isPlaying(index))
                                                      Text(
                                                        //duration of the recording
                                                        durationFormat(
                                                            duration),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle2,
                                                      ),
                                                    Text(
                                                      fileSize, //file size of the recording as a subtitle in the list widget of the recorder
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2,
                                                    )
                                                  ],
                                                ),
                                                trailing: PopupMenuButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSecondary,

                                                  //rename share delete buttons inside a popup menu
                                                  onSelected: (value) {
                                                    switch (value) {
                                                      case 'Share':
                                                        Share.shareFiles(
                                                            [audioFile.path],
                                                            text: fileName);
                                                        break;
                                                      case 'Rename':
                                                        rename(audioFile);
                                                        break;
                                                      case 'Delete':
                                                        delete(audioFile);
                                                        break;
                                                    }
                                                  },
                                                  itemBuilder:
                                                      (BuildContext context) {
                                                    //item builder of the popup button
                                                    return [
                                                      'Share',
                                                      'Rename',
                                                      'Delete'
                                                    ].map((String choice) {
                                                      return PopupMenuItem(
                                                        value: choice,
                                                        child: Text(
                                                          choice,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onBackground,
                                                              fontFamily:
                                                                  'Raleway',
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      );
                                                    }).toList();
                                                  },
                                                ),
                                                leading: CircleAvatar(
                                                  //play pause circle avatar for leading icon
                                                  radius: 35,
                                                  backgroundColor: Colors.green,
                                                  child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    onPressed: () async {
                                                      if ((audioPlayer!
                                                          .isPlaying)) {
                                                        pauseAudio();
                                                        setState(() {});
                                                      } else {
                                                        playAudio(
                                                            audioFile.path,
                                                            index);
                                                      }
                                                    },
                                                    icon: Icon(
                                                      isPlaying(index)
                                                          ? Icons.pause
                                                          : Icons.play_arrow,
                                                      color: const Color(
                                                          0xFFffffff),
                                                    ),
                                                    iconSize: 30,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }

                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              )
                            ],
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
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder(
                              //list builder for when sliding up panel is closed
                              future: getDirectory(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.hasData) {
                                  Directory dir = snapshot.data;
                                  List<FileSystemEntity?> audiosFiles = dir
                                      .listSync(
                                          recursive: true, followLinks: false)
                                      .map((file) {
                                    if (file.statSync().type ==
                                        FileSystemEntityType.file) {
                                      return file;
                                    }
                                  }).toList();

                                  audiosFiles.removeWhere(
                                      (element) => element == null);

                                  if (audiosFiles.isEmpty) {
                                    return Center(
                                      child: Text(
                                        'No recordings', // show when there are no recordings saved
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    //for closed sliding up panel
                                    //list view to display the recordings in a list
                                    shrinkWrap: true,
                                    physics:
                                        const BouncingScrollPhysics(), //bouncing physics
                                    itemCount: audiosFiles.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      File audioFile =
                                          File(audiosFiles[index]!.path);

                                      DateFormat dayFormat = DateFormat.yMd();
                                      DateFormat timeFormat = DateFormat.Hm();
                                      String fileSize = getFileSize(
                                          audioFile.lengthSync(), 1);
                                      DateTime createdAt =
                                          audioFile.lastModifiedSync();
                                      String createdAtFormatted = '';
                                      String fileName = audioFile.name ??
                                          'Recording'; //checks if file name starts with recording

                                      if (createdAt.isToday()) {
                                        createdAtFormatted =
                                            timeFormat.format(createdAt);
                                      } else {
                                        createdAtFormatted =
                                            dayFormat.format(createdAt);
                                      }

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(15)),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5, top: 5),
                                            child: ListTile(
                                              onTap: () {},
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: AutoSizeText(
                                                      fileName, //name of the file formatting inside the list of recordings
                                                      maxLines: 1,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline2,
                                                    ),
                                                  ),
                                                  Text(
                                                    createdAtFormatted,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2,
                                                  )
                                                ],
                                              ),
                                              subtitle: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  if (isPlaying(index))
                                                    Text(
                                                      //duration of the recording
                                                      durationFormat(duration),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2,
                                                    ),
                                                  Text(
                                                    fileSize, //file size of the recording as a subtitle in the list widget of the recorder
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2,
                                                  )
                                                ],
                                              ),
                                              trailing: PopupMenuButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondary,
                                                //rename share delete buttons inside a popup menu
                                                onSelected: (value) {
                                                  switch (value) {
                                                    case 'Share':
                                                      Share.shareFiles(
                                                          [audioFile.path],
                                                          text: fileName);
                                                      break;
                                                    case 'Rename':
                                                      rename(audioFile);
                                                      break;
                                                    case 'Delete':
                                                      delete(audioFile);
                                                      break;
                                                  }
                                                },
                                                itemBuilder:
                                                    (BuildContext context) {
                                                  //item builder of the popup button
                                                  return [
                                                    'Share',
                                                    'Rename',
                                                    'Delete'
                                                  ].map((String choice) {
                                                    return PopupMenuItem(
                                                      value: choice,
                                                      child: Text(
                                                        choice,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onBackground,
                                                            fontFamily:
                                                                'Raleway',
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    );
                                                  }).toList();
                                                },
                                              ),
                                              leading: CircleAvatar(
                                                //play pause circle avatar for leading icon
                                                radius: 35,
                                                backgroundColor: Colors.green,
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () async {
                                                    if ((audioPlayer!
                                                        .isPlaying)) {
                                                      pauseAudio();
                                                      setState(() {});
                                                    } else {
                                                      playAudio(audioFile.path,
                                                          index);
                                                    }
                                                  },
                                                  icon: Icon(
                                                    isPlaying(index)
                                                        ? Icons.pause
                                                        : Icons.play_arrow,
                                                    color:
                                                        const Color(0xFFffffff),
                                                  ),
                                                  iconSize: 30,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }

                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            )
                          ],
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
                  StreamBuilder<int>(
                    stream: _stopWatchTimer.rawTime,
                    initialData: 0,
                    builder: (context, snap) {
                      final value = snap.data;
                      final displayTime = StopWatchTimer.getDisplayTime(value!);
                      return Text(
                        displayTime,
                        style: Theme.of(context).textTheme.headline1!.copyWith(
                              fontSize: 38,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Text(
                      'High Quality', //Text below the timer in record tab
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ), // TODO space between countdown and animation
                  //auto spacing for the upcoming record button
                  Padding(
                    //record button starts
                    padding: const EdgeInsets.only(
                        bottom: 24.0, left: 24.0, right: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Visibility(
                          visible: _mRecorder!.isPaused ? true : false,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: IconButton(
                            onPressed: () => cancelRecord(),
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.onBackground,
                            ), //x button to cancel the recording to be saved
                          ),
                        ),
                        SizedBox(
                          width: 76,
                          height: 76,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(_mRecorder!.isRecording
                                ? 0xfffc0202
                                : 0xff4caf50),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: getRecorderFn(),
                              icon: Icon(
                                _mRecorder!.isRecording
                                    ? Icons.pause
                                    : Icons.fiber_manual_record,
                                color: const Color(0xFFffffff),
                              ),
                              iconSize: 30,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _mRecorder!.isPaused ? true : false,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              onPressed: () => saveAudioBottomSheet(),
                              icon: Icon(
                                Icons.check,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ), //tick button to proceed to save the recording to storage
                            ),
                          ),
                        ),
                      ],
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
}
