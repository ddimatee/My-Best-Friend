import 'package:flutter/material.dart';

class BotonVerdeLleno extends StatelessWidget {
  final String etiqueta;
  final VoidCallback onTap;
  const BotonVerdeLleno({super.key, required this.etiqueta, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 1,
        ),
        child: Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class BotonSiguiente extends StatelessWidget {
  final bool habilitado;
  final String etiqueta;
  final VoidCallback onTap;
  const BotonSiguiente({super.key, required this.habilitado, required this.etiqueta, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: habilitado ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: habilitado ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          foregroundColor: habilitado ? Colors.white : Colors.black54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: habilitado ? 1 : 0,
        ),
        child: Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class BotonSegmentoOutlined extends StatelessWidget {
  final String etiqueta;
  final VoidCallback onTap;
  const BotonSegmentoOutlined({super.key, required this.etiqueta, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black87, width: 1.2),
        shape: const StadiumBorder(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      child: Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class SelectorPildora<T> extends StatelessWidget {
  final List<T> items;
  final T value;
  final String Function(T) labelBuilder;
  final void Function(T) onChanged;
  final double width;
  const SelectorPildora({super.key, required this.items, required this.value, required this.labelBuilder, required this.onChanged, required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.expand_more, color: Colors.black),
          items: items
              .map((e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(labelBuilder(e), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
