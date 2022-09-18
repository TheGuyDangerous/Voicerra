import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:voicerra/utils/utils.dart';
import 'package:voicerra/widget/mini_player.dart';
import 'package:wakelock/wakelock.dart';

class RecPage extends StatefulWidget {
  const RecPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RecPageState createState() => _RecPageState();
}

typedef Fn = void Function();

class _RecPageState extends State<RecPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const List<Tab> tabs = <Tab>[
    Tab(text: 'Record'),
    Tab(text: 'Play'),
  ];

  FlutterSoundPlayer? audioPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  late TabController _tabController;
  final Codec _codec = Codec.pcm16WAV;
  final String _fileExtension = 'wav';
  Duration duration = const Duration();
  List<int> audiosPlaying = [];

  bool isPlaying(int index) => audiosPlaying.contains(index);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

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

    _tabController.dispose();
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
      TextEditingController recordingTitle = TextEditingController();
      String? selectedCategory;

      await showSlidingBottomSheet(
        context,
        builder: (BuildContext context) {
          return SlidingSheetDialog(
            elevation: 8,
            cornerRadius: 15,
            color: const Color(0xFFF2F2F2),
            builder: (context, state) {
              return Material(
                child: StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return Container(
                      color: const Color(0xFFF2F2F2),
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 30, bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              'Save Recording',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 20.0,
                                color: Color(0xFF23262F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                              labelText: 'Name the recording',
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
                color: const Color(0xFFF2F2F2),
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
                                backgroundColor: const Color(0xFFbbdefb),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide.none,
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 16.0,
                                  color: Color(0xFF969AA0),
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
                                'Save',
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
      String path = file.path;

      TextEditingController recordingTitle = TextEditingController();
      String? selectedCategory;

      await showSlidingBottomSheet(
        context,
        builder: (BuildContext context) {
          return SlidingSheetDialog(
            elevation: 8,
            cornerRadius: 15,
            color: const Color(0xFFF2F2F2),
            builder: (context, state) {
              return Material(
                child: StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return Container(
                      color: const Color(0xFFF2F2F2),
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 30, bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              'Rename',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(fontSize: 20),
                            ),
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
                              labelText: 'New Name',
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
                color: const Color(0xFFF2F2F2),
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
                                'Cancel',
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
                                'Save',
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
            elevation: 8,
            backgroundColor: const Color(0xFFF2F2F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              'Are you sure you want to delete this audio?',
              style: TextStyle(
                fontFamily: 'Raleway',
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
                      'No',
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
                      'Yes',
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2f2554),
        elevation: 0.0,
        actionsIconTheme: const IconThemeData(color: Color(0xFF323232)),
        centerTitle: true,
        toolbarHeight: 90,
        title: const Text('Record Notes',
            style: TextStyle(
                fontFamily: 'Raleway', fontSize: 24.0, color: Colors.white)),
        bottom: TabBar(
          tabs: const [Tab(text: 'Record'), Tab(text: 'Play')],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        controller: _tabController,
        children: [
          Column(
            children: [
              const SizedBox(height: 40),
              StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: 0,
                builder: (context, snap) {
                  final value = snap.data;
                  final displayTime = StopWatchTimer.getDisplayTime(value!);
                  return Text(
                    displayTime,
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 38),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Text(
                  'High Quality',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              const Spacer(),
              Container(
                  child: _mRecorder!.isRecording
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
                      : Container(
                          height: 170,
                          color: const Color(0xFFf2f2f2),
                        )),
              const Spacer(),
              Padding(
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
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: getRecorderFn(),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              _mRecorder!.isRecording
                                  ? const Color(0xFFFF5656)
                                  : Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                              side: const BorderSide(
                                  color: Color(0xFF2f2554), width: 8),
                            ),
                          ),
                        ),
                        child: _mRecorder!.isRecording
                            ? const Icon(Icons.pause)
                            : null,
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
                          icon: const Icon(Icons.check),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24.0, right: 24.0, top: 20.0, bottom: 15.0),
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
                            .listSync(recursive: true, followLinks: false)
                            .map((file) {
                          if (file.statSync().type ==
                              FileSystemEntityType.file) {
                            return file;
                          }
                        }).toList();

                        audiosFiles.removeWhere((element) => element == null);

                        if (audiosFiles.isEmpty) {
                          return Center(
                            child: Text(
                              'No recordings',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: audiosFiles.length,
                          itemBuilder: (BuildContext context, int index) {
                            File audioFile = File(audiosFiles[index]!.path);

                            DateFormat dayFormat = DateFormat.yMd();
                            DateFormat timeFormat = DateFormat.Hm();
                            String fileSize =
                                getFileSize(audioFile.lengthSync(), 1);
                            DateTime createdAt = audioFile.lastModifiedSync();
                            String createdAtFormatted = '';
                            String fileName = audioFile.name ?? 'Recording';

                            if (createdAt.isToday()) {
                              createdAtFormatted = timeFormat.format(createdAt);
                            } else {
                              createdAtFormatted = dayFormat.format(createdAt);
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: ListTile(
                                onTap: () {},
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: AutoSizeText(
                                        fileName,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                    ),
                                    Text(
                                      createdAtFormatted,
                                      style:
                                          Theme.of(context).textTheme.subtitle2,
                                    )
                                  ],
                                ),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (isPlaying(index))
                                      Text(
                                        durationFormat(duration),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                    Text(
                                      fileSize,
                                      style:
                                          Theme.of(context).textTheme.subtitle2,
                                    )
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'Share':
                                        Share.shareFiles([audioFile.path],
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
                                  itemBuilder: (BuildContext context) {
                                    return ['Share', 'Rename', 'Delete']
                                        .map((String choice) {
                                      return PopupMenuItem(
                                        value: choice,
                                        child: Text(choice),
                                      );
                                    }).toList();
                                  },
                                ),
                                leading: CircleAvatar(
                                  radius: 35,
                                  backgroundColor: const Color(0xFFEFEFEF),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      if ((audioPlayer!.isPlaying)) {
                                        pauseAudio();
                                        setState(() {});
                                      } else {
                                        playAudio(audioFile.path, index);
                                      }
                                    },
                                    icon: Icon(
                                      isPlaying(index)
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: const Color(0xFF323232),
                                    ),
                                    iconSize: 30,
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
      bottomNavigationBar: audioPlayer!.isPlaying ? const MiniPlayer() : null,
    );
  }
}
