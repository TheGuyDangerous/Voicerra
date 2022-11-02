import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:voicerra/Screens/notes_page.dart';
import 'package:voicerra/Screens/voice.dart';
import 'package:voicerra/Screens/transcribe_page.dart';
import 'package:voicerra/Screens/voice_recorder_page.dart';
import 'package:flutter/services.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:voicerra/theme/color_scheme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voicerra',
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        buttonTheme: const ButtonThemeData(
          colorScheme: ColorScheme.light(
            primary: Color(0xff006a53),
            secondary: Color(0xffd1ffeb),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF512DA8)),
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        listTileTheme: ListTileThemeData(
          dense: true,
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(width: 1.0, color: Color(0xFFF4F6F9)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFaea3c5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide.none,
            ),
          ),
        ),
        textTheme: TextTheme(
          headline1: GoogleFonts.getFont(
            'Raleway',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xa3ffffff),
          ),
          headline2: GoogleFonts.getFont(
            'Raleway',
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: const Color(0xC5000000),
          ),
          subtitle1: GoogleFonts.getFont(
            'Raleway',
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF777777),
          ),
          subtitle2: GoogleFonts.getFont(
            'Raleway',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF777777),
          ),
          bodyText1: GoogleFonts.getFont(
            'Raleway',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: const Color(0xffd1ffeb),
          ),
          bodyText2: GoogleFonts.getFont(
            'Raleway',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF23262F),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        buttonTheme: const ButtonThemeData(
          colorScheme: ColorScheme.light(
            primary: Color(0xff006a53),
            secondary: Color(0xffd1ffeb),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF512DA8)),
        popupMenuTheme: PopupMenuThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.getFont(
            'Raleway',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        listTileTheme: ListTileThemeData(
          dense: true,
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(width: 1.0, color: Color(0xFFF4F6F9)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff006a53),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide.none,
            ),
          ),
        ),
        textTheme: TextTheme(
          headline1: GoogleFonts.getFont(
            'Raleway',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xa3ffffff),
          ),
          headline2: GoogleFonts.getFont(
            'Raleway',
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: const Color(0xecffffff),
          ),
          subtitle1: GoogleFonts.getFont(
            'Raleway',
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF777777),
          ),
          subtitle2: GoogleFonts.getFont(
            'Raleway',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF777777),
          ),
          bodyText1: GoogleFonts.getFont(
            'Raleway',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: const Color(0xffd1ffeb),
          ),
          bodyText2: GoogleFonts.getFont(
            'Raleway',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF23262F),
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  final List<Widget> screens = [
    const VoiceApp(),
    const TranscribePage(
      title: 'Transcribe',
    ),
    const RecPage(),
    const NotesPage(),
  ];
  List<IconData> data = [
    Icons.home_outlined,
    FluentIcons.mic_16_regular,
    FluentIcons.record_12_regular,
    Iconsax.note,
  ];

  @override
  Widget build(BuildContext context) {
    final style = SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).colorScheme.onSecondary,
      systemNavigationBarDividerColor:
          Theme.of(context).colorScheme.onSecondary,
      systemNavigationBarIconBrightness: Brightness.dark,
    );
    SystemChrome.setSystemUIOverlayStyle(style);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.outline,
          child: SizedBox(
            height: 70,
            width: double.infinity,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: data.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = i;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 35,
                    decoration: BoxDecoration(
                      border: i == selectedIndex
                          ? const Border(
                              top: BorderSide(
                                  width: 3.0,
                                  color: Color(
                                      0xffffff))) //for animation in bottom navigation bar
                          : null,
                    ),
                    child: Icon(
                      data[i],
                      size: 35,
                      color: i == selectedIndex
                          ? Theme.of(context).colorScheme.onErrorContainer
                          : Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ),
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
    );
  }
}
