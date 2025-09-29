import 'package:flutter/material.dart';
import 'estado.dart';
import 'paso_2_nombre.dart';
import 'widgets_comunes.dart';

class MascotaPasoSituacionPantalla extends StatelessWidget {
  final PetFormState estado;
  const MascotaPasoSituacionPantalla({super.key, required this.estado});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 12),
          const Text('¿Qué es lo más se\nacomoda a tú\nsituación actual?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          const SizedBox(height: 28),
          BotonVerdeLleno(
            etiqueta: 'Acabo de tener un perro',
            onTap: () {
              estado.situation = 'Acabo de tener un perro';
              Navigator.push(context, MaterialPageRoute(builder: (_) => MascotaPasoNombrePantalla(estado: estado)));
            },
          ),
          const SizedBox(height: 12),
          BotonVerdeLleno(
            etiqueta: 'Ya conozco bien a mi perro',
            onTap: () {
              estado.situation = 'Ya conozco bien a mi perro';
              Navigator.push(context, MaterialPageRoute(builder: (_) => MascotaPasoNombrePantalla(estado: estado)));
            },
          ),
        ]),
      ),
    );
  }
}
