import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingPlan {
  final List<ModuleGroup> moduleGroups;

  ReadingPlan({required this.moduleGroups});

  factory ReadingPlan.fromJson(List<dynamic> jsonList) {
    List<ModuleGroup> moduleGroups = [];
    for (var json in jsonList) {
      json.forEach((title, modulesJson) {
        List<Module> modules = (modulesJson as List)
            .map((moduleJson) => Module.fromJson(moduleJson))
            .toList();
        moduleGroups.add(ModuleGroup(title: title, modules: modules));
      });
    }
    return ReadingPlan(moduleGroups: moduleGroups);
  }
}

class ModuleGroup {
  final String title;
  final List<Module> modules;

  ModuleGroup({required this.title, required this.modules});
}

class Module {
  final int module;
  final int day;
  final String book;
  final String chapter;
  final String psalm;
  bool isCompleted;

  Module({
    required this.module,
    required this.day,
    required this.book,
    required this.chapter,
    required this.psalm,
    this.isCompleted = false,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      module: json['Módulo'],
      day: json['Dia'],
      book: json['Livro'],
      chapter: json['Capítulo'],
      psalm: json['Livro e Capítulo'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Módulo': module,
      'Dia': day,
      'Livro': book,
      'Capítulo': chapter,
      'Livro e Capítulo': psalm,
      'isCompleted': isCompleted,
    };
  }
}

class ReadingPlanProvider with ChangeNotifier {
  ReadingPlan? _readingPlan;

  ReadingPlan? get readingPlan => _readingPlan;

  Future<void> loadReadingPlan() async {
    List<dynamic> jsonList = [];
    for (int i = 1; i <= 23; i++) {
      final String response =
          await rootBundle.loadString('assets/modulos/modulo_$i.json');
      jsonList.add(json.decode(response));
    }
    _readingPlan = ReadingPlan.fromJson(jsonList);
    await _loadModuleCompletionStatus();
    notifyListeners();
  }

  Future<void> _loadModuleCompletionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _readingPlan?.moduleGroups.forEach((moduleGroup) {
      moduleGroup.modules.forEach((module) {
        module.isCompleted =
            prefs.getBool('module_${module.module}_day_${module.day}') ?? false;
      });
    });
  }

  Future<void> _saveModuleCompletionStatus(Module module) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'module_${module.module}_day_${module.day}', module.isCompleted);
  }

  Future<void> updateModuleCompletion(
      ModuleGroup moduleGroup, Module module, bool isCompleted) async {
    module.isCompleted = isCompleted;
    await _saveModuleCompletionStatus(module);
    if (isCompleted) {
      // Only update lastModule if all modules in the group are complete
      bool allCompleted = moduleGroup.modules.every((m) => m.isCompleted);
      if (allCompleted) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('lastModule', module.module + 1);
      }
    }
    notifyListeners();
  }

  double getProgress() {
    if (_readingPlan == null) return 0.0;

    int completedModules = _readingPlan!.moduleGroups
        .expand((group) => group.modules)
        .where((module) => module.isCompleted)
        .length;

    int totalModules =
        _readingPlan!.moduleGroups.expand((group) => group.modules).length;

    return completedModules / totalModules;
  }
}
