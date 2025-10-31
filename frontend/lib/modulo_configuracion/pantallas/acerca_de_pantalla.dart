import 'package:flutter/material.dart';

class AcercaDePantalla extends StatelessWidget {
  const AcercaDePantalla({Key? key}) : super(key: key);

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
          'Acerca de',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Logo de la app
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pets,
                  size: 60,
                  color: green,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Nombre de la app
              const Text(
                'My Best Friend',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Versión
              const Text(
                'Versión 1.0.0 (Build 1)',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Descripción
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: green, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Sobre la aplicación',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'My Best Friend es tu compañero perfecto para el cuidado de tus mascotas. '
                      'Gestiona vacunas, controla el peso, programa eventos importantes y mantén '
                      'un álbum de fotos de tus mejores amigos peludos.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Características
              _buildFeatureCard(
                icon: Icons.vaccines_outlined,
                title: 'Control de Vacunas',
                description: 'Lleva un registro completo del calendario de vacunación',
                color: green,
              ),
              
              const SizedBox(height: 12),
              
              _buildFeatureCard(
                icon: Icons.monitor_weight_outlined,
                title: 'Seguimiento de Peso',
                description: 'Monitorea el peso de tu mascota con gráficos detallados',
                color: green,
              ),
              
              const SizedBox(height: 12),
              
              _buildFeatureCard(
                icon: Icons.event_outlined,
                title: 'Calendario de Eventos',
                description: 'Programa y recibe recordatorios de citas importantes',
                color: green,
              ),
              
              const SizedBox(height: 12),
              
              _buildFeatureCard(
                icon: Icons.photo_library_outlined,
                title: 'Álbum de Fotos',
                description: 'Guarda los mejores momentos con tus mascotas',
                color: green,
              ),
              
              const SizedBox(height: 32),
              
              // Información adicional
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '© 2025 My Best Friend',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hecho con ❤️ para el cuidado de tus mascotas',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
