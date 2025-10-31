import 'package:flutter/material.dart';
import 'estado.dart';
import 'widgets_comunes.dart';
import 'paso_7_estilo_vida.dart';

class MascotaPasoSeguimientoPantalla extends StatelessWidget {
  final PetFormState estado;
  const MascotaPasoSeguimientoPantalla({super.key, required this.estado});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Text('¿Quieres hacer un seguimiento de comidas, vacunas y todo lo relacionado con tu perro?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: BotonSegmentoOutlined(
                etiqueta: 'Sí',
                onTap: () {
                  estado.tracking = true;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MascotaPasoEstiloVidaPantalla(estado: estado)));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BotonSegmentoOutlined(
                etiqueta: 'No',
                onTap: () {
                  estado.tracking = false;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MascotaPasoEstiloVidaPantalla(estado: estado)));
                },
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
