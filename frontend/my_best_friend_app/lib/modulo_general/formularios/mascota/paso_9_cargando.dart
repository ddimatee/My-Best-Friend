import 'package:flutter/material.dart';
import '../../menu_principal.dart';
import '../../datos/mascota_model.dart';
import 'estado.dart';

class MascotaPasoCargandoPantalla extends StatefulWidget {
  /// Recibe el estado del formulario para crear la mascota.
  final PetFormState? estado;
  const MascotaPasoCargandoPantalla({super.key, this.estado});
  @override
  State<MascotaPasoCargandoPantalla> createState() => _MascotaPasoCargandoPantallaState();
}

class _MascotaPasoCargandoPantallaState extends State<MascotaPasoCargandoPantalla> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      // Crear la mascota en el repositorio si hay estado.
      final repo = MascotasRepo();
      final st = widget.estado;
      if (st != null) {
        final nombre = st.name?.isNotEmpty == true ? st.name! : 'Mascota';
        repo.agregar(Mascota(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nombre: nombre,
          creado: DateTime.now(),
        ));
      }
      // Ir al menú principal y limpiar el historial para que no vuelva al formulario.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MenuPrincipal()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              height: 140,
              child: Image(image: AssetImage('assets/images/perro_logo.png')),
            ),
            SizedBox(height: 12),
            Text('Cargando tus datos\ningresados...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
