import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class TestConexionScreen extends StatefulWidget {
  const TestConexionScreen({super.key});

  @override
  State<TestConexionScreen> createState() => _TestConexionScreenState();
}

class _TestConexionScreenState extends State<TestConexionScreen> {
  final ApiService _apiService = ApiService();
  String _mensaje = 'Presiona el botón para probar la conexión';
  bool _cargando = false;
  Color _colorMensaje = Colors.blue;

  Future<void> _probarConexion() async {
    setState(() {
      _cargando = true;
      _mensaje = 'Probando conexión...';
      _colorMensaje = Colors.blue;
    });

    try {
      final resultado = await _apiService.verificarConexion();
      
      setState(() {
        _cargando = false;
        if (resultado['success']) {
          _mensaje = '✅ Conexión exitosa!\n'
              'Servidor: ${resultado['data']['message'] ?? 'Conectado'}\n'
              'Base de datos: ${resultado['data']['database'] ?? 'Conectada'}';
          _colorMensaje = Colors.green;
        } else {
          _mensaje = '❌ Error de conexión:\n${resultado['message']}';
          _colorMensaje = Colors.red;
        }
      });
    } catch (e) {
      setState(() {
        _cargando = false;
        _mensaje = '❌ Error de red:\n$e';
        _colorMensaje = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Conexión'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_find,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Test de Conexión API',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: Text(
                _mensaje,
                style: TextStyle(
                  fontSize: 16,
                  color: _colorMensaje,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _cargando ? null : _probarConexion,
              icon: _cargando 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_cargando ? 'Probando...' : 'Probar Conexión'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Column(
                  children: [
                    const Text(
                      'Estado de Autenticación:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      authProvider.isAuthenticated 
                          ? '✅ Usuario autenticado'
                          : '❌ Usuario no autenticado',
                      style: TextStyle(
                        fontSize: 16,
                        color: authProvider.isAuthenticated 
                            ? Colors.green 
                            : Colors.orange,
                      ),
                    ),
                    if (authProvider.user != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Usuario: ${authProvider.user!['nombre'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Email: ${authProvider.user!['email'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}