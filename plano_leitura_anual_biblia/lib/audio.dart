import 'package:flutter_tts/flutter_tts.dart';

class AudioHelper {
  final FlutterTts flutterTts = FlutterTts();

  AudioHelper() {
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    // Verifica o motor de TTS ativo no Android
    if (await flutterTts.getDefaultEngine == "com.google.android.tts") {
      print("Google Text-to-Speech detectado. Selecionando melhor voz...");

      List<dynamic> voices = await flutterTts.getVoices;
      String bestVoice = voices.firstWhere(
          (voice) => voice["locale"] == "pt-BR",
          orElse: () => {"name": "pt-br-x0c"})["name"];

      await flutterTts.setVoice({"name": bestVoice, "locale": "pt-BR"});
      print("Voz selecionada: $bestVoice");
    } else {
      print("Google TTS não está configurado como padrão.");
    }
  }

  Future<void> speakText(
      String text, Function onStart, Function onComplete) async {
    try {
      await _initializeTTS();

      flutterTts.setCompletionHandler(() {
        print("Fala concluída.");
        onComplete();
      });

      onStart();
      await flutterTts.speak(text);
    } catch (e) {
      print('Erro ao converter texto em fala: $e');
    }
  }

  void stop() async {
    await flutterTts.stop();
    print("Fala interrompida.");
  }
}
