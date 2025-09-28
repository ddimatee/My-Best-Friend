import 'package:flutter/material.dart';

class OpcionConfiguracion extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final VoidCallback onTap;

  const OpcionConfiguracion({
    Key? key,
    required this.titulo,
    required this.icono,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icono de la opción
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: Icon(
                icono,
                size: 20,
                color: Colors.grey.shade700,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Título de la opción
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // Flecha indicadora
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}