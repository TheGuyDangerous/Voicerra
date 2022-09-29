import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({Key? key}) : super(key: key);

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  String translated = 'Translate';
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: const Color(0xFF2f2554),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Translation',
            style: TextStyle(
                fontFamily: 'Raleway', fontSize: 24.0, color: Colors.white),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.all(12),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(' English ( US )'),
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
                style: const TextStyle(
                  fontSize: 36,
                  fontFamily: 'Raleway',
                  color: Color(0xFF2f2554),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ), // Card
      );
}
