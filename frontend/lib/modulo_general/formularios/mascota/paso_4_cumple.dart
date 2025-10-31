import 'package:flutter/material.dart';
import 'estado.dart';
import 'paso_5_raza.dart';
import 'widgets_comunes.dart';

class MascotaPasoCumplePantalla extends StatefulWidget {
  final PetFormState estado;
  const MascotaPasoCumplePantalla({super.key, required this.estado});
  @override
  State<MascotaPasoCumplePantalla> createState() => _MascotaPasoCumplePantallaState();
}

class _MascotaPasoCumplePantallaState extends State<MascotaPasoCumplePantalla> {
  int dia = DateTime.now().day;
  int mes = DateTime.now().month;
  int anio = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final meses = const [
      'Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'
    ];
    final ultimoDia = DateTime(anio, mes + 1, 0).day;
    if (dia > ultimoDia) dia = ultimoDia;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Text('¿En qué año nació tu\nperro?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 14,
                children: [
                  SelectorPildora<int>(
                    width: 120,
                    items: List.generate(ultimoDia, (i) => i + 1),
                    value: dia,
                    labelBuilder: (v) => '$v',
                    onChanged: (v) => setState(() => dia = v),
                  ),
                  SelectorPildora<int>(
                    width: 180,
                    items: List.generate(12, (i) => i + 1),
                    value: mes,
                    labelBuilder: (v) => meses[v - 1],
                    onChanged: (v) => setState(() => mes = v),
                  ),
                  SelectorPildora<int>(
                    width: 120,
                    items: List.generate(40, (i) => DateTime.now().year - i),
                    value: anio,
                    labelBuilder: (v) => '$v',
                    onChanged: (v) => setState(() => anio = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              height: 160,
              child: Image.asset('assets/images/perro_logo.png', fit: BoxFit.contain),
            ),
          ),
          const Spacer(),
          Center(
            child: TextButton(
              onPressed: () {
                widget.estado.birthday = null;
                Navigator.push(context, MaterialPageRoute(builder: (_) => MascotaPasoRazaPantalla(estado: widget.estado)));
              },
              child: const Text('No lo sé', style: TextStyle(color: Colors.black87)),
            ),
          ),
          const SizedBox(height: 8),
          BotonSiguiente(
            habilitado: true,
            etiqueta: 'Siguiente',
            onTap: () {
              widget.estado.birthday = DateTime(anio, mes, dia);
              Navigator.push(context, MaterialPageRoute(builder: (_) => MascotaPasoRazaPantalla(estado: widget.estado)));
            },
          ),
        ]),
      ),
    );
  }
}
