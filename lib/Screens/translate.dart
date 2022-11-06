import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:translator/translator.dart';
import '../widget/customappbar.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({Key? key}) : super(key: key);

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  String translated = 'Translate';
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Stack(
          children: [
            SafeArea(
              child: MyAppBar(
                title: 'Translation',
                onIconTap: _copy,
                iconName: Iconsax.copy,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 150, left: 12, right: 12),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    ' English ( US )',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: ' Enter text ',
                    ), // Input Decoration
                    onChanged: (text) async {
                      final translation = await text.translate(
                          from: 'auto', //Detect Language
                          to: 'en');
                      setState(() {
                        translated = translation.text;
                      });
                    },
                  ),
                  const Divider(
                    height: 32,
                  ),
                  Text(
                    translated,
                    style: TextStyle(
                      fontSize: 36,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ), // Card
      );

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: translated));
    Fluttertoast.showToast(
      msg: "✓   Copied to Clipboard",
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
