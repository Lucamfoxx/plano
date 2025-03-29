import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

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

  void _confirmReading() {
    setState(() {
      widget.module.isCompleted = true;
    });
    Provider.of<ReadingPlanProvider>(context, listen: false)
        .updateModuleCompletion(widget.moduleGroup, widget.module, true);
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
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
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
        padding: const EdgeInsets.all(16.0),
        child: texts == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: texts!.entries.map((entry) {
                    return _buildTextCard(entry);
                  }).toList(),
                ),
              ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _confirmReading,
            child: Text('Confirmar Leitura'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 11.0),
              textStyle: TextStyle(fontSize: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextCard(MapEntry<String, String> entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ExpansionTile(
          title: Text(
            entry.key,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                entry.value,
                style: TextStyle(fontSize: _fontSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
