import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'reading_plan.dart';
import 'module_screen.dart';
import 'custom_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  bool _hasJumped = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // This method loads the saved last module from SharedPreferences and returns the index of the group containing it.
  Future<int> _getTargetPageIndex(ReadingPlan readingPlan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastModule = prefs.getInt('lastModule');
    if (lastModule == null) return 0;

    // Iterate over moduleGroups to find which group contains the module with lastModule
    for (int i = 0; i < readingPlan.moduleGroups.length; i++) {
      final group = readingPlan.moduleGroups[i];
      bool found = group.modules.any((module) => module.module == lastModule);
      if (found) {
        return i;
      }
    }
    return 0;
  }

  Future<void> _animateToTargetPage(int targetIndex) async {
    int currentPage =
        _pageController.hasClients ? _pageController.page?.round() ?? 0 : 0;
    while (currentPage < targetIndex) {
      currentPage++;
      await _pageController.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: _buildAppBar(),
      body: Consumer<ReadingPlanProvider>(
        builder: (context, provider, child) {
          if (provider.readingPlan == null) {
            provider.loadReadingPlan();
            return Center(child: CircularProgressIndicator());
          }

          // Once the reading plan is loaded, animate sequentially to the saved module group if not already done
          if (!_hasJumped) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              int targetIndex =
                  await _getTargetPageIndex(provider.readingPlan!);
              await _animateToTargetPage(targetIndex);
              _hasJumped = true;
            });
          }

          return PageView.builder(
            controller: _pageController,
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

  void _navigateToModuleScreen(BuildContext context, ModuleGroup moduleGroup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleScreen(moduleGroup: moduleGroup),
      ),
    );
  }
}
