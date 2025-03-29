import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPageIndex = 0;
  PageController _pageController = PageController();

  List<Widget> _pages = [
    OnboardingPage(
      backgroundColor: Colors.blue,
      title: 'Plano anual de Leitura',
      subtitle: '''
Bem-vindo ao nosso aplicativo de leitura anual da Bíblia! Este aplicativo foi projetado para guiá-lo através de uma jornada espiritual profunda, onde você lerá a Bíblia inteira em 366 dias.''',
      imagePath: '',
    ),
    OnboardingPage(
      backgroundColor: Colors.blue,
      title: '''

Como Funciona?''',
      subtitle: '''Introdução

O plano de leitura é resultado de uma reflexão cuidadosa sobre como ler e assimilar a Bíblia de forma eficaz. 

Metodologia

A grande vantagem deste plano é a divisão da Bíblia em 12 períodos históricos, utilizando 14 livros narrativos principais (Gênesis, Êxodo, Números, Josué, Juízes, 1 e 2 Samuel, 1 e 2 Reis, Esdras, Neemias, 1 Macabeus, Lucas e Atos dos Apóstolos). Estes são intercalados com outras leituras para proporcionar uma compreensão mais completa.

Ao contrário de outros métodos, não há leituras paralelas que possam desviar a atenção da narrativa principal. No entanto, incluí uma terceira leitura diária de um livro sapiencial, como Salmos ou Provérbios, que complementa a leitura principal sem distrações.

Este plano de leitura foi criado para oferecer uma maneira estruturada e profunda de explorar a Bíblia em um ano, facilitando seu entendimento e meditação diária.

''',
      imagePath: '',
    ),
    OnboardingPage(
      backgroundColor: Colors.blue,
      title: 'Interface simples!',
      subtitle: '',
      imagePath: 'assets/imagens/splash3.png',
    ),
    OnboardingPage(
      backgroundColor: Colors.blue,
      title: 'Imagens ilustrativas dos principais acontecimentos!',
      subtitle: '',
      imagePath: 'assets/imagens/splash4.png',
    ),
    OnboardingPage(
      backgroundColor: Colors.blue,
      title: '10 minutos de Leitura por dia!',
      subtitle: '',
      imagePath: 'assets/imagens/splash5.png',
    ),
    OnboardingPage(
      backgroundColor: Colors.blue,
      title: 'Textos complementares que ajudam o entendimento!',
      subtitle: '',
      imagePath: 'assets/imagens/splash6.png',
    ),
    LastOnboardingPage(
      imagePath: 'assets/imagens/splash7.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),
          if (_currentPageIndex < _pages.length - 1)
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  '>',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final String imagePath;

  OnboardingPage({
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (imagePath.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: Image.asset(imagePath, height: 500, width: 500),
                ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LastOnboardingPage extends StatelessWidget {
  final String imagePath;

  LastOnboardingPage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (imagePath.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: Image.asset(imagePath, height: 500, width: 500),
                    ),
                  SizedBox(height: 10),
                  Text(
                    'Leitura Dinamica',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seen', true);
                Navigator.pushReplacementNamed(context, '/main');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                'Começar',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
