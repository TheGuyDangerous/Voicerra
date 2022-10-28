import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:voicerra/Screens/notes_page.dart';
import 'package:voicerra/Screens/voice.dart';
import 'package:voicerra/Screens/transcribe_page.dart';
import 'package:voicerra/Screens/voice_recorder_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

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
        buttonTheme: const ButtonThemeData(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF2f2554),
            secondary: Color(0xFFEFEFEF),
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
            color: const Color(0xFF23262F),
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
            backgroundColor: const Color(0xFFbbdefb),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide.none,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          labelStyle: GoogleFonts.getFont(
            'Raleway',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: const Color(0xFF969AA0),
          ),
          hintStyle: GoogleFonts.getFont(
            'Raleway',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: const Color(0xFF969AA0),
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelStyle: GoogleFonts.getFont(
            'Raleway',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF23262F),
          ),
          unselectedLabelStyle: GoogleFonts.getFont(
            'Raleway',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF23262F),
          ),
          labelColor: const Color(0xFFffffff),
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 4.0, color: Color(0xFFffffff)),
          ),
          unselectedLabelColor: const Color(0xFFe4e4e4),
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
            color: const Color(0xFF969AA0),
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

  final style = const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF212025),
    systemNavigationBarDividerColor: Color(0xFF212025),
    systemNavigationBarIconBrightness: Brightness.light,
  );

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(style);
    return Scaffold(
      backgroundColor: const Color(0xFF212025),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xff292933),
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
                                  width: 3.0, color: Color(0xffffff)))
                          : null,
                    ),
                    child: Icon(
                      data[i],
                      size: 35,
                      color: i == selectedIndex
                          ? const Color(0xdbffffff)
                          : const Color(0x67ffffff),
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
