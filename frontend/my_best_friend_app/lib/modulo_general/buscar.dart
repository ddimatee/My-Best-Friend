import 'package:flutter/material.dart';
import 'datos/mascota_model.dart';
import 'busqueda/buscador_global.dart';

// Wrapper en español para pantalla de búsqueda.
class BuscarPantalla extends StatefulWidget {
  const BuscarPantalla({Key? key}) : super(key: key);
  @override
  State<BuscarPantalla> createState() => _BuscarPantallaState();
}

class _BuscarPantallaState extends State<BuscarPantalla> {
  final TextEditingController _ctrl = TextEditingController();
  final MascotasRepo _repo = MascotasRepo();
  final BuscadorGlobal _buscador = BuscadorGlobal();
  String _query = '';
  bool _incluirOcultas = true; // incluir mascotas ocultas en resultados

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChange);
  }

  void _onRepoChange() => setState(() {});

  @override
  void dispose() {
    _repo.removeListener(_onRepoChange);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final resultados = _buscador.buscar(context, _query, incluirOcultasMascotas: _incluirOcultas);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF4CAF50),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _ctrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Buscar mascotas...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('Incluir ocultas', style: TextStyle(color: Colors.white)),
                Switch(
                  value: _incluirOcultas,
                  onChanged: (v) => setState(() => _incluirOcultas = v),
                  activeColor: Colors.white,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: resultados.isEmpty
                  ? const Center(child: Text('Sin resultados', style: TextStyle(fontSize: 16)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: resultados.length,
                      itemBuilder: (_, i) {
                        final r = resultados[i];
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF4CAF50).withOpacity(.12),
                              child: Icon(r.icono, color: const Color(0xFF4CAF50)),
                            ),
                            title: Text(r.titulo),
                            subtitle: Text(r.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
                            onTap: r.onTap,
                            trailing: r.id.startsWith('pet:')
                                ? IconButton(
                                    tooltip: 'Ocultar / Mostrar',
                                    icon: Icon(
                                      _repo.ocultas.any((m) => 'pet:${m.id}' == r.id)
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.black87,
                                    ),
                                    onPressed: () {
                                      final petId = r.id.substring(4);
                                      _repo.toggleOculto(petId);
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
