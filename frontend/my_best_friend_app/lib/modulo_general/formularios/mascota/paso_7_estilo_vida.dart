import 'package:flutter/material.dart';
import 'estado.dart';
import 'widgets_comunes.dart';
import 'paso_8_co_cuidado.dart';

class MascotaPasoEstiloVidaPantalla extends StatefulWidget {
  final PetFormState estado;
  const MascotaPasoEstiloVidaPantalla({super.key, required this.estado});
  @override
  State<MascotaPasoEstiloVidaPantalla> createState() => _MascotaPasoEstiloVidaPantallaState();
}

class _MascotaPasoEstiloVidaPantallaState extends State<MascotaPasoEstiloVidaPantalla> {
  static const opciones = [
    'Soy una persona de ciudad',
    'Me gusta recibir gente',
    'Tengo hijos',
    'Me estreso mucho',
    'Otro',
  ];
  bool get _puedeContinuar => widget.estado.lifestyle.isNotEmpty;
  void _toggle(String v) {
    setState(() {
      if (widget.estado.lifestyle.contains(v)) {
        widget.estado.lifestyle.remove(v);
      } else {
        widget.estado.lifestyle.add(v);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Text('¿Qué hay con tu estilo de vida?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          const Text('Selecciona todas las que correspondan', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: opciones.map((o) {
              final seleccionado = widget.estado.lifestyle.contains(o);
              return ChoiceChip(
                label: Text(o, style: TextStyle(fontWeight: FontWeight.w800, color: seleccionado ? Colors.white : Colors.black)),
                selected: seleccionado,
                onSelected: (_) => _toggle(o),
                selectedColor: const Color(0xFF4CAF50),
                backgroundColor: Colors.white,
                shape: const StadiumBorder(side: BorderSide(color: Colors.black87, width: 1)),
              );
            }).toList(),
          ),
          const Spacer(),
          BotonSiguiente(
            habilitado: _puedeContinuar,
            etiqueta: 'Continuar',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MascotaPasoCoCuidadoPantalla(estado: widget.estado)));
            },
          ),
        ]),
      ),
    );
  }
}
