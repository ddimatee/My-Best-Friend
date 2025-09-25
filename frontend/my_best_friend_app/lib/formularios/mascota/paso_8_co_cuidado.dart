import 'package:flutter/material.dart';
import 'estado.dart';
import 'widgets_comunes.dart';
import 'paso_9_cargando.dart';

class MascotaPasoCoCuidadoPantalla extends StatelessWidget {
  final PetFormState estado;
  const MascotaPasoCoCuidadoPantalla({super.key, required this.estado});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¿Cuidas a tu perro junto con alguien?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: BotonSegmentoOutlined(
                etiqueta: 'Sí',
                onTap: () {
                  estado.coCare = true;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MascotaPasoCargandoPantalla()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BotonSegmentoOutlined(
                etiqueta: 'No',
                onTap: () {
                  estado.coCare = false;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MascotaPasoCargandoPantalla()),
                  );
                },
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
