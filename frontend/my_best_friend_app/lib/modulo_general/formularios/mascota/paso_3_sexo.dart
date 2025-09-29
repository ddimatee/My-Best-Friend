import 'package:flutter/material.dart';
import 'estado.dart';
import 'paso_4_cumple.dart';
import 'widgets_comunes.dart';

class MascotaPasoSexoPantalla extends StatelessWidget {
  final PetFormState estado;
  const MascotaPasoSexoPantalla({super.key, required this.estado});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Text('¿Tú mascota es un?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: BotonVerdeLleno(
                etiqueta: 'Macho',
                onTap: () {
                  estado.sex = 'Macho';
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MascotaPasoCumplePantalla(estado: estado)));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BotonVerdeLleno(
                etiqueta: 'Hembra',
                onTap: () {
                  estado.sex = 'Hembra';
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MascotaPasoCumplePantalla(estado: estado)));
                },
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
