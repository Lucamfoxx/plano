import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reading_plan.dart';
import 'home_screen.dart';
import 'info_page.dart';
import 'onboarding_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Para fontes personalizadas
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Para ícones FontAwesome

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loadSeenStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MainApp(seen: snapshot.data ?? false);
      },
    );
  }

  Future<bool> _loadSeenStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seen') ?? false;
  }
}

class MainApp extends StatefulWidget {
  final bool seen;
  const MainApp({required this.seen});

  static _MainAppState of(BuildContext context) {
    return context.findAncestorStateOfType<_MainAppState>()!;
  }

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void changeThemeMode(ThemeMode newMode) {
    setState(() {
      _themeMode = newMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReadingPlanProvider()..loadReadingPlan(),
      child: MaterialApp(
        title: 'Plano Anual de Leitura',
        themeMode: _themeMode,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Colors.teal,
          ),
          textTheme: GoogleFonts.latoTextTheme().copyWith(
            displayLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(fontSize: 16),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.indigo,
          colorScheme: ColorScheme.dark().copyWith(
            secondary: Colors.teal[300],
          ),
          scaffoldBackgroundColor: Colors.grey[900],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.indigo[800],
            foregroundColor: Colors.white,
          ),
          textTheme: GoogleFonts.latoTextTheme(
            ThemeData.dark().textTheme,
          ).copyWith(
            displayLarge: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          cardColor: Colors.grey[850],
          cardTheme: CardTheme(
            color: Colors.grey[850],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 18.0),
              elevation: 6,
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: widget.seen ? ReadingPlanPage() : OnboardingScreen(),
        routes: {
          '/main': (context) => ReadingPlanPage(),
          '/info': (context) => InfoPage(),
          '/home_screen': (context) => HomeScreen(),
          '/onboarding': (context) => OnboardingScreen(),
        },
      ),
    );
  }
}

class ReadingPlanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
        child: Column(
          children: [
            ProgressCard(),
            SizedBox(height: 40),
            StartButton(),
            SizedBox(height: 40),
            InfoCard(),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 20);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.indigo[600],
      title: Text(
        'Plano Anual de Leitura',
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
      ),
      centerTitle: true,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: CircleAvatar(
            backgroundColor: Colors.white24,
            child: IconButton(
              icon: Icon(
                isDark ? Icons.wb_sunny : Icons.nightlight_round,
                color: Colors.white,
              ),
              onPressed: () {
                final newBrightness = isDark ? ThemeMode.light : ThemeMode.dark;
                MainApp.of(context).changeThemeMode(newBrightness);
              },
            ),
          ),
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.infoCircle, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/info');
          },
        ),
      ],
    );
  }
}

class ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            Text(
              'Seu Progresso',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            SizedBox(height: 25),
            Consumer<ReadingPlanProvider>(
              builder: (context, provider, child) {
                double progress = provider.getProgress();
                return AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOutCubic,
                  child: CustomPaint(
                    foregroundPainter:
                        ProgressPainter(progress: progress, context: context),
                    child: Container(
                      width: 260,
                      height: 260,
                      alignment: Alignment.center,
                      child: Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 39,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.limeAccent
                              : Colors.indigo[700],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 25),
            Text(
              'Continue assim!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressPainter extends CustomPainter {
  final double progress;
  final BuildContext context;

  ProgressPainter({required this.progress, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 15.0;
    final radius = (size.width / 2) - (strokeWidth / 2);
    final center = Offset(size.width / 2, size.height / 2);

    // Círculo de fundo
    final backgroundPaint = Paint()
      ..color = Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[700]!
          : const Color.fromARGB(255, 238, 238, 238)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Arco de progresso com gradiente
    final foregroundPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -1.5708, // -90 graus em radianos
        endAngle: 4.71239, // 270 graus em radianos
        colors: Theme.of(context).brightness == Brightness.dark
            ? [Colors.limeAccent.shade100, Colors.lime]
            : [Colors.teal[400]!, Colors.indigo[700]!],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    double angle = 2 * 3.141592653589793 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // Inicia no topo
      angle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class StartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Botão ocupando toda a largura
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/home_screen');
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 18.0),
          elevation: 6,
          backgroundColor: Colors.teal[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Começar Leitura',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 28.0, horizontal: 24.0),
        child: Column(
          children: [
            Text(
              'Sobre o Plano',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            SizedBox(height: 20),
            Text(
              'Este plano de leitura anual oferece uma maneira estruturada e profunda de ler a Bíblia. Cada dia inclui passagens dos Evangelhos, Salmos e outros livros.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Divider(color: Colors.grey[300]),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(FontAwesomeIcons.calendarAlt, '1 Ano'),
                _buildDetailItem(FontAwesomeIcons.clock, '15 min/dia'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.teal[100],
          radius: 30,
          child: FaIcon(icon, color: Colors.teal[700], size: 30),
        ),
        SizedBox(height: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.teal[700],
          ),
        ),
      ],
    );
  }
}
