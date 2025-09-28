import 'package:flutter/material.dart';
import 'formularios/formulario_mascota.dart';
import 'menu_principal.dart';

/// Pantalla intermedia antes del formulario de creación de mascota
class CrearMascotaNuevaPantalla extends StatefulWidget {
  const CrearMascotaNuevaPantalla({super.key});

  @override
  State<CrearMascotaNuevaPantalla> createState() => _CrearMascotaNuevaPantallaState();
}

class _CrearMascotaNuevaPantallaState extends State<CrearMascotaNuevaPantalla> {
  int _tabIndex = 0; // Para mantener la coherencia con el menú

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50), // Verde de la aplicación
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal centrado
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Título
                  const Text(
                    'Crear una mascota nueva',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Subtítulo
                  const Text(
                    '¡Puedes crear muchas más\nmascotas!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  // Imagen del perro
                  Image.asset(
                    'assets/images/perro_crear.png',
                    width: 150,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback si no se encuentra la imagen
                      return Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 60,
                          color: Color(0xFF4CAF50),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 60),
                  // Botón "Crear"
                  Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Navegar al formulario de creación de mascota
                        final st = PetFormState();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MascotaPasoSituacionPantalla(estado: st)
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Crear',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Barra de navegación inferior usando el código del menú principal
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  height: 64,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BottomItem(
                        icon: Icons.pets,
                        selected: _tabIndex == 0,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      _BottomItem(
                        icon: Icons.calendar_month,
                        selected: _tabIndex == 1,
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, '/calendario');
                        },
                      ),
                      _BottomItem(
                        icon: Icons.settings,
                        selected: _tabIndex == 2,
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MenuPrincipal(initialTab: 2)
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 28,
          color: Colors.black,
        ),
      ),
    );
  }
}