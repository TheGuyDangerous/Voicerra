import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:voicerra/db/notes_database.dart';
import 'package:voicerra/model/note.dart';
import 'package:voicerra/Screens/edit_note_page.dart';

class NoteDetailPage extends StatefulWidget {
  final int noteId;

  const NoteDetailPage({
    Key? key,
    required this.noteId,
  }) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late Note note;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNote();
  }

  Future refreshNote() async {
    setState(() => isLoading = true);

    note = await NotesDatabase.instance.readNote(widget.noteId);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.shadow,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.shadow,
          centerTitle: true,
          actions: [editButton(), deleteButton()],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12),
                child: SafeArea(
                  minimum: const EdgeInsets.only(left: 10),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      Text(
                        note.title,
                        style: const TextStyle(
                          color: Color(0xff808080),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        DateFormat.yMMMd().format(note.createdTime),
                        style: const TextStyle(
                            color: Color(0x81808080), fontSize: 15),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        note.description,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 20),
                      )
                    ],
                  ),
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: const Icon(Iconsax.edit),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditNotePage(note: note),
        ));

        refreshNote();
      });

  Widget deleteButton() => Padding(
        padding: const EdgeInsets.only(right: 15.0, left: 5.0),
        child: IconButton(
          icon: const Icon(Iconsax.trash),
          onPressed: () async {
            final navigator = Navigator.of(context);
            await NotesDatabase.instance.delete(widget.noteId);

            navigator.pop();
          },
        ),
      );
}
