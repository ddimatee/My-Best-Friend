import 'package:flutter/material.dart';
import 'opcion_configuracion.dart';

class SeccionConfiguracion extends StatelessWidget {
  final String titulo;
  final List<OpcionConfiguracion> opciones;

  const SeccionConfiguracion({
    Key? key,
    required this.titulo,
    required this.opciones,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        
        // Lista de opciones
        ...opciones.map((opcion) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: opcion,
        )).toList(),
      ],
    );
  }
}