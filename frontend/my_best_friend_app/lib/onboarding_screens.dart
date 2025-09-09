import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({Key? key}) : super(key: key);
  
  @override
  _OnboardingScreensState createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4CAF50), // Verde principal
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            children: [
              _buildScreen1(),
              _buildScreen2(),
              _buildScreen3(),
              _buildScreen4(),
              _buildScreen5(),
            ],
          ),
          // Indicadores de página (siempre bien visibles y separados de la flecha)
          Positioned(
            bottom: 24, // más abajo para que no choque con la flecha/botón
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: currentIndex == index ? 12 : 8,
                  height: currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == index
                        ? Colors.white
                        : Colors.white54,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen1() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 100),
          Text(
            'MY BEST\nFRIEND',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.0,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 20),
       
          Expanded(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 2.5,
                child: LayoutBuilder(
                  builder: (context, constraints) {
               
                    final double shiftX = constraints.maxWidth * 0.20;
                    return ClipRect(
                      child: Transform.translate(
                        offset: Offset(shiftX, 0),
                        child: Image.asset(
                          'assets/images/video_perro.gif',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          _buildNextButton(),
          SizedBox(height: 100), // más espacio para separar de los indicadores
        ],
      ),
    );
  }

  Widget _buildScreen2() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(flex: 1),
          Text(
            '¿Olvidas cuándo fue\nla última vacuna de\ntu perro?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: 30),
          Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // Sombra centrada bajo el perro (sin desplazamiento direccional)
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 18,
                      spreadRadius: 2,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/perro_vacuna.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Spacer(flex: 1),
          _buildNextButton(),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildScreen3() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(flex: 1),
          Text(
            '¿No sabes cuándo\ndesparasitarlo o\nbañarlo?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: 30),
          
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 102), // movimiento sutil hacia la derecha
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Tamaño responsivo: grande, pero sin desbordar
                  final maxW = constraints.maxWidth;
                  final double size = (maxW * 0.9).clamp(320.0, 560.0);

                  return SizedBox(
                    width: size,
                    height: size,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/perro_bano.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Spacer(flex: 1),
          _buildNextButton(),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildScreen4() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(flex: 2),
          Text(
            'Aquí te ayudamos a\nrecordarlo todo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              letterSpacing: 1.0,
            ),
          ),
          Spacer(flex: 2),
          _buildNextButton(),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildScreen5() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(flex: 1),
          Text(
            'Bienvenido a\n¡My Best Friend!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/perro_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          Text(
            '¡Te damos una cálida\nbienvenida!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          Spacer(flex: 1),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF4CAF50),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            child: Text(
              'Empezar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: () {
        if (currentIndex < 4) {
          _pageController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_forward,
          color: Color(0xFF4CAF50),
          size: 35,
        ),
      ),
    );
  }
}
