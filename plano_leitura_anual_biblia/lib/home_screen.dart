import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'reading_plan.dart';
import 'module_screen.dart';
import 'custom_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.lightBlue[50], // Define a cor de fundo para azul bebê
      appBar: _buildAppBar(),
      body: Consumer<ReadingPlanProvider>(
        builder: (context, provider, child) {
          if (provider.readingPlan == null) {
            provider.loadReadingPlan();
            return Center(child: CircularProgressIndicator());
          }

          return _buildPageView(provider);
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.lightBlue[50],
      title: Text('Plano Bíblico'),
    );
  }

  Widget _buildPageView(ReadingPlanProvider provider) {
    return PageView.builder(
      itemCount: provider.readingPlan!.moduleGroups.length,
      itemBuilder: (context, index) {
        final moduleGroup = provider.readingPlan!.moduleGroups[index];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomCard(
            moduleGroup: moduleGroup,
            imagePath: 'assets/imagens/modulo_${index + 1}.jpg',
            onTap: () {
              _navigateToModuleScreen(context, moduleGroup);
            },
          ),
        );
      },
    );
  }

  void _navigateToModuleScreen(BuildContext context, ModuleGroup moduleGroup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleScreen(moduleGroup: moduleGroup),
      ),
    );
  }
}
