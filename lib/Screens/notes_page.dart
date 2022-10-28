import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:voicerra/db/notes_database.dart';
import 'package:voicerra/model/note.dart';
import 'package:voicerra/Screens/edit_note_page.dart';
import 'package:voicerra/Screens/note_detail_page.dart';
import 'package:voicerra/widget/customappbar.dart';
import 'package:voicerra/widget/note_card_widget.dart';
import 'package:iconsax/iconsax.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  Widget buildNotes() => StaggeredGridView.countBuilder(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
        itemCount: notes.length,
        staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final note = notes[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NoteDetailPage(noteId: note.id!),
              ));

              refreshNotes();
            },
            child: NoteCardWidget(note: note, index: index),
          );
        },
      );

  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNotes();
  }

  @override
  void dispose() {
    NotesDatabase.instance.close();

    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    notes = await NotesDatabase.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  _add() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEditNotePage()),
    );

    refreshNotes();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF212025),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : notes.isEmpty
                        ? Container(
                            height:
                                MediaQuery.of(context).copyWith().size.height,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Iconsax.note_1,
                                  color: Color(0x67ffffff),
                                  size: 120,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'empty!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 22,
                                      color: Color(0x67ffffff)),
                                ),
                              ],
                            ),
                          )
                        : SafeArea(
                            minimum: const EdgeInsets.only(top: 150),
                            child: Container(
                                height: MediaQuery.of(context)
                                    .copyWith()
                                    .size
                                    .height,
                                alignment: Alignment.topCenter,
                                child: buildNotes()),
                          ),
              ),
            ),
            SafeArea(
              child: MyAppBar(
                title: 'Notes',
                onIconTap: _add,
                iconName: Iconsax.add,
              ),
            ),
          ],
        ),
      );
}
