import 'package:flutter/material.dart';
import 'formularios/formulario_mascota.dart';
import '../modulo_general/widgets/bottom_nav_global.dart';

/// Pantalla intermedia antes del formulario de creación de mascota
class CrearMascotaNuevaPantalla extends StatefulWidget {
  const CrearMascotaNuevaPantalla({super.key});

  @override
  State<CrearMascotaNuevaPantalla> createState() => _CrearMascotaNuevaPantallaState();
}

class _CrearMascotaNuevaPantallaState extends State<CrearMascotaNuevaPantalla> {

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
            // Título independiente
            Positioned(
              top: 120, // Cambia este valor para mover el título verticalmente
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Crear una mascota nueva',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Subtítulo independiente
            Positioned(
              top: 180, // Cambia este valor para mover el subtítulo verticalmente
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '¡Puedes crear muchas más\nmascotas!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Imagen independiente
            Positioned(
              top: 250, // Cambia este valor para mover la imagen verticalmente
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/perro_crear.png',
                  width: 250, // Cambia este valor para hacer la imagen más ancha
                  height: 250, // Cambia este valor para hacer la imagen más alta
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
              ),
            ),
            // Botón independiente
            Positioned(
              top: 500, // Cambia este valor para mover el botón verticalmente
              left: 0,
              right: 0,
              child: Center(
                child: Container(
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
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavGlobal(selectedIndex: 0),
    );
  }
}
// Barra inferior reutiliza BottomNavGlobal (se eliminó la implementación local)