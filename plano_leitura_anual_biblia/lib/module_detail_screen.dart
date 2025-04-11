import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'reading_plan.dart';
import 'main.dart';

class ModuleDetailScreen extends StatefulWidget {
  final Module module;
  final ModuleGroup moduleGroup;

  ModuleDetailScreen({required this.module, required this.moduleGroup});

  @override
  _ModuleDetailScreenState createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  Map<String, String>? texts;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadModuleTexts();
  }

  Future<void> _loadModuleTexts() async {
    try {
      final response = await rootBundle
          .loadString('assets/texts/dia_${widget.module.day}.json');
      final data = Map<String, String>.from(json.decode(response));
      setState(() {
        texts = data;
      });
    } catch (e) {
      setState(() {
        texts = {'Erro': 'Erro ao carregar os textos do módulo.'};
      });
    }
  }

  Future<void> _saveLastReadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastModule', widget.module.module);
    await prefs.setInt('lastDay', widget.module.day);
  }

  Future<void> _confirmReading() async {
    setState(() {
      widget.module.isCompleted = true;
    });
    Provider.of<ReadingPlanProvider>(context, listen: false)
        .updateModuleCompletion(widget.moduleGroup, widget.module, true);

    await _saveLastReadState();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ReadingPlanPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize += 2;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _fontSize -= 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth < 400 ? 8.0 : 16.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('Dia ${widget.module.day}'),
        actions: [
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: _increaseFontSize,
            tooltip: 'Aumentar Fonte',
          ),
          IconButton(
            icon: Icon(Icons.zoom_out),
            onPressed: _decreaseFontSize,
            tooltip: 'Diminuir Fonte',
          ),
        ],
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
        child: texts == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...texts!.entries.map((entry) {
                      return _buildTextCard(entry);
                    }).toList(),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirmReading,
                        child: Text('Confirmar Leitura'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor:
                              const Color.fromARGB(255, 203, 248, 253),
                          padding: EdgeInsets.symmetric(vertical: 11.0),
                          textStyle: TextStyle(fontSize: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 48),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextCard(MapEntry<String, String> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        shadowColor: Colors.black.withOpacity(0.25),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExpansionTile(
            title: Text(
              entry.key,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 400 ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text.rich(
                  TextSpan(
                    children: _formatText(entry.value),
                    style: TextStyle(fontSize: _fontSize, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _formatText(String rawText) {
    final lines = rawText.split('\n');
    return lines.map((line) {
      final match = RegExp(r'^(\\d+\\.)').firstMatch(line);
      if (match != null) {
        final verseNum = match.group(1)!;
        final content = line.substring(verseNum.length);
        return TextSpan(
          children: [
            TextSpan(
              text: '$verseNum ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: content),
            const TextSpan(text: '\n\n'),
          ],
        );
      }
      return TextSpan(text: '$line\n\n');
    }).toList();
  }
}
