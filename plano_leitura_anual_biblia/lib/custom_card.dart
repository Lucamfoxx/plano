import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reading_plan.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'image_viewer_screen.dart';

class CustomCard extends StatefulWidget {
  final ModuleGroup moduleGroup;
  final VoidCallback onTap;
  final String imagePath;

  CustomCard({
    required this.moduleGroup,
    required this.onTap,
    required this.imagePath,
  });

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  Map<int, String?> moduleTexts = {};

  @override
  void initState() {
    super.initState();
    _loadModuleTexts();
  }

  Future<void> _loadModuleTexts() async {
    for (var module in widget.moduleGroup.modules) {
      final moduleText = await _loadModuleText(module.module);
      setState(() {
        moduleTexts[module.module] = moduleText;
      });
    }
  }

  Future<String> _loadModuleText(int moduleNumber) async {
    try {
      final response = await rootBundle
          .loadString('assets/modulos/modulo_$moduleNumber.txt');
      return response;
    } catch (e) {
      return 'Erro ao carregar o texto do módulo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    int completedModules =
        widget.moduleGroup.modules.where((module) => module.isCompleted).length;
    double progress = completedModules / widget.moduleGroup.modules.length;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImage(),
            _buildCardContent(progress),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(10),
            child: Stack(
              children: [
                InteractiveViewer(
                  child: Image.asset(widget.imagePath),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: Image.asset(
          widget.imagePath,
          fit: BoxFit.cover,
          height: 380,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildCardContent(double progress) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTitle(),
          SizedBox(height: 10),
          _buildProgressIndicator(progress),
          SizedBox(height: 20),
          _buildActionButton(),
          SizedBox(height: 20),
          _buildModuleText(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.moduleGroup.title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return LinearPercentIndicator(
      lineHeight: 25.0,
      percent: progress,
      backgroundColor: Colors.grey[300]!,
      progressColor: Color.fromARGB(255, 40, 168, 23),
      linearStrokeCap: LinearStrokeCap.roundAll,
      animation: true,
      animationDuration: 1000,
      barRadius: Radius.circular(12.5),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: widget.onTap,
      child: Text('Modulo'),
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        padding: EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildModuleText() {
    if (moduleTexts.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        moduleTexts[widget.moduleGroup.modules.first.module] ?? '',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.left,
      ),
    );
  }
}
