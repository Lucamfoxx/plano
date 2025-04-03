import 'package:flutter/material.dart';
import 'reading_plan.dart';
import 'module_detail_screen.dart';

class ModuleScreen extends StatefulWidget {
  final ModuleGroup moduleGroup;

  ModuleScreen({required this.moduleGroup});

  @override
  _ModuleScreenState createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _navigateToFirstUnreadModule();
    });
  }

  Future<void> _navigateToFirstUnreadModule() async {
    final firstUnreadIndex =
        widget.moduleGroup.modules.indexWhere((module) => !module.isCompleted);
    if (firstUnreadIndex != -1) {
      int currentPage =
          _pageController.hasClients ? _pageController.page?.round() ?? 0 : 0;
      while (currentPage < firstUnreadIndex) {
        currentPage++;
        await _pageController.animateToPage(
          currentPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        title: Text(widget.moduleGroup.title),
      ),
      backgroundColor: Colors.lightBlue[50],
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.moduleGroup.modules.length,
        itemBuilder: (context, index) {
          final module = widget.moduleGroup.modules[index];
          final imagePath = 'assets/dia/dia_${module.day}.jpg';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildModuleCard(context, module, imagePath),
          );
        },
      ),
    );
  }

  Widget _buildModuleCard(
      BuildContext context, Module module, String imagePath) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildImage(imagePath),
            _buildModuleDetails(module),
            _buildReadButton(context, module),
            _buildCompletionBadge(module.isCompleted),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
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
                  child: Image.asset(imagePath),
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
          imagePath,
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.width < 600 ? 380 : 500,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildModuleDetails(Module module) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Dia ${module.day}: ${module.book} ${module.chapter}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            module.psalm,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildReadButton(BuildContext context, Module module) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModuleDetailScreen(
                module: module, moduleGroup: widget.moduleGroup),
          ),
        );
      },
      child: Text('Ler'),
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

  Widget _buildCompletionBadge(bool isCompleted) {
    if (!isCompleted) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Chip(
        avatar: Icon(Icons.check_circle, color: Colors.white),
        label: Text('Concluído'),
        backgroundColor: Colors.green,
        labelStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
