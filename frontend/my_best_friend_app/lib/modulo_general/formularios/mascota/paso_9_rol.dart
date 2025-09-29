import 'package:flutter/material.dart';
import 'estado.dart';
import 'paso_10_cargando.dart';
import 'widgets_comunes.dart';

class MascotaPasoRolPantalla extends StatelessWidget {
  final PetFormState estado;
  const MascotaPasoRolPantalla({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '¿Cuál es tu rol?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: BotonVerdeLleno(
                    etiqueta: 'Dueño',
                    onTap: () {
                      estado.role = 'Dueño';
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MascotaPasoCargandoPantalla(estado: estado),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BotonVerdeLleno(
                    etiqueta: 'Cuidador',
                    onTap: () {
                      estado.role = 'Cuidador';
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MascotaPasoCargandoPantalla(estado: estado),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}