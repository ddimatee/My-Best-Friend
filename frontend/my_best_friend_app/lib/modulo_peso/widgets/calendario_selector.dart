import 'package:flutter/material.dart';

/// Dialogo de selección de fecha personalizado para el módulo de peso
/// que muestra las iniciales de los días como: L M M J V S D
Future<DateTime?> mostrarCalendarioPeso({
  required BuildContext context,
  required DateTime fechaInicial,
  DateTime? primeraFecha,
  DateTime? ultimaFecha,
}) async {
  primeraFecha ??= DateTime(2020, 1, 1);
  ultimaFecha ??= DateTime.now().add(const Duration(days: 365));

  DateTime mesVisible = DateTime(fechaInicial.year, fechaInicial.month);
  DateTime? seleccionTemporal = fechaInicial;

  return showDialog<DateTime>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final diasMes = DateUtils.getDaysInMonth(mesVisible.year, mesVisible.month);
          final primerDiaSemana = DateTime(mesVisible.year, mesVisible.month, 1).weekday; // 1=Lunes ... 7=Domingo
          final List<Widget> celdas = [];

            // Encabezados
          const encabezados = ['L','M','M','J','V','S','D'];
          celdas.addAll(encabezados.map((e) => Center(
            child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600)),
          )));

          // Espacios antes del primer día
          for (int i = 1; i < primerDiaSemana; i++) {
            celdas.add(const SizedBox());
          }

          // Días del mes
          for (int d = 1; d <= diasMes; d++) {
            final fechaIter = DateTime(mesVisible.year, mesVisible.month, d);
            final bool fueraRango = fechaIter.isBefore(primeraFecha!) || fechaIter.isAfter(ultimaFecha!);
      final bool seleccionado = seleccionTemporal != null &&
        seleccionTemporal!.year == fechaIter.year &&
        seleccionTemporal!.month == fechaIter.month &&
        seleccionTemporal!.day == fechaIter.day;
            celdas.add(GestureDetector(
              onTap: fueraRango ? null : () {
                setState(() => seleccionTemporal = fechaIter);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: seleccionado ? const Color(0xFF4CAF50) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$d',
                  style: TextStyle(
                    color: fueraRango
                        ? Colors.grey.shade400
                        : (seleccionado ? Colors.white : Colors.black87),
                    fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ));
          }

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título y navegación de mes
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20,20,20,8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formateaCabeceraMes(mesVisible),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              mesVisible = DateTime(mesVisible.year, mesVisible.month - 1);
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              mesVisible = DateTime(mesVisible.year, mesVisible.month + 1);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: celdas,
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('CANCELAR'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(seleccionTemporal),
                          child: const Text('ACEPTAR'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    }
  );
}

String _formateaCabeceraMes(DateTime fecha) {
  const meses = ['','enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
  return '${meses[fecha.month]} de ${fecha.year}';
}
