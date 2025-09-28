import 'package:flutter/material.dart';

class PreferenciasPantalla extends StatefulWidget {
  const PreferenciasPantalla({Key? key}) : super(key: key);

  @override
  State<PreferenciasPantalla> createState() => _PreferenciasPantallaState();
}

class _PreferenciasPantallaState extends State<PreferenciasPantalla> {
  bool _notificacionesActivadas = true;
  bool _recordatoriosVacunas = true;
  bool _recordatoriosPeso = false;
  bool _recordatoriosEventos = true;
  String _idioma = 'Español';
  // Eliminado selector de tema: la app usará un único tema por ahora.

  @override
  Widget build(BuildContext context) {
    final Color green = const Color(0xFF4CAF50);
    
    return Scaffold(
      backgroundColor: green,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Preferencias',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección Notificaciones
              const Text(
                'Notificaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSwitchTile(
                'Activar notificaciones',
                _notificacionesActivadas,
                (value) => setState(() => _notificacionesActivadas = value),
              ),
              
              _buildSwitchTile(
                'Recordatorios de vacunas',
                _recordatoriosVacunas,
                (value) => setState(() => _recordatoriosVacunas = value),
              ),
              
              _buildSwitchTile(
                'Recordatorios de peso',
                _recordatoriosPeso,
                (value) => setState(() => _recordatoriosPeso = value),
              ),
              
              _buildSwitchTile(
                'Recordatorios de eventos',
                _recordatoriosEventos,
                (value) => setState(() => _recordatoriosEventos = value),
              ),
              
              const SizedBox(height: 30),
              
              // Sección Aplicación
              const Text(
                'Aplicación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildDropdownTile(
                'Idioma',
                _idioma,
                ['Español', 'Inglés', 'Francés', 'Portugués'],
                (value) => setState(() => _idioma = value!),
              ),
              
              const Spacer(),
              
              // Botón Guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardarPreferencias,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar Preferencias',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String titulo, bool valor, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String titulo,
    String valorActual,
    List<String> opciones,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          DropdownButton<String>(
            value: valorActual,
            onChanged: onChanged,
            underline: Container(),
            items: opciones.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _guardarPreferencias() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferencias guardadas exitosamente'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
    Navigator.pop(context);
  }
}