import 'package:flutter/material.dart';
import 'package:voicerra/Screens/notes_page.dart';
import 'package:voicerra/Screens/voice.dart';
import 'package:iconsax/iconsax.dart';
import 'package:voicerra/Screens/transcribe_page.dart';
import 'package:voicerra/Screens/voice_recorder_page.dart';
import 'package:google_fonts/google_fonts.dart';

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
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                style: BorderStyle.solid, width: 1.0, color: Color(0xFFEFEFEF)),
          ),
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
            color: const Color(0xFF23262F),
          ),
          headline2: GoogleFonts.getFont(
            'Raleway',
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF23262F),
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
  int index = 0;
  final List<Widget> screens = [
    const VoiceApp(),
    const TranscribePage(
      title: 'Transcribe',
    ),
    const NotesPage(),
    const RecPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.blue.shade100,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        child: NavigationBar(
          height: 60,
          backgroundColor: const Color(0xFFf6edfd),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() => this.index = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Iconsax.microphone),
              label: 'liveaudio',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.book_saved),
              label: 'Transcribe',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.note_1),
              label: 'Notes',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.record_circle),
              label: 'Recorder',
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFD1C4E9),
      body: IndexedStack(
        index: index,
        children: screens,
      ),
    );
  }
}
