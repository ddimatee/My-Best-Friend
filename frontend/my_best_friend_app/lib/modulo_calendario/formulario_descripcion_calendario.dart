import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'seleccion_categoria_calendario.dart';

class FormularioDescripcionCalendario extends StatefulWidget {
  const FormularioDescripcionCalendario({Key? key}) : super(key: key);

  @override
  State<FormularioDescripcionCalendario> createState() => _FormularioDescripcionCalendarioState();
}

class _FormularioDescripcionCalendarioState extends State<FormularioDescripcionCalendario> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _focusNode = FocusNode();
  final Color _greenColor = const Color(0xFF4CAF50); // Verde consistente con la app
  final Color _grayColor = const Color(0xFFE5E5E5);
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
    
    _descripcionController.addListener(_validateForm);
    
    // Iniciar animaciones
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }
  
  void _validateForm() {
    setState(() {
      _isFormValid = _descripcionController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _descripcionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _continuar() {
    if (_formKey.currentState!.validate()) {
      // Haptic feedback
      HapticFeedback.lightImpact();
      
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            SeleccionCategoriaCalendario(descripcion: _descripcionController.text.trim()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenColor,
      appBar: AppBar(
        backgroundColor: _grayColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header mejorado con gradiente y sombra
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _grayColor,
                  _grayColor.withOpacity(0.9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: Column(
                children: [
                  // Icono decorativo animado
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _greenColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_calendar,
                        size: 32,
                        color: _greenColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Título principal con animación
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Agrega una descripción',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'para el horario',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtítulo descriptivo
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Describe brevemente lo que deseas recordar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Cuerpo principal con formulario mejorado
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _greenColor,
                        _greenColor.withOpacity(0.95),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Label mejorado con icono
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.description,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Descripción del recordatorio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Campo de texto mejorado
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _descripcionController,
                              focusNode: _focusNode,
                              maxLines: 4,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                height: 1.5,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Este texto aparecerá en la notificación y en el calendario...',
                                hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _greenColor,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(20),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Icon(
                                    Icons.edit,
                                    color: _greenColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa una descripción';
                                }
                                if (value.trim().length < 3) {
                                  return 'La descripción debe tener al menos 3 caracteres';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _validateForm();
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Contador de caracteres
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '${_descripcionController.text.length}/200 caracteres',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Botón mejorado con animaciones
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isFormValid ? _continuar : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFormValid 
                                    ? const Color(0xFFFFC107) 
                                    : Colors.grey.shade400,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: _isFormValid ? 8 : 2,
                                shadowColor: _isFormValid 
                                    ? const Color(0xFFFFC107).withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.2),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Continuar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedRotation(
                                    turns: _isFormValid ? 0 : -0.1,
                                    duration: const Duration(milliseconds: 300),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Navigation Bar mejorado
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BottomItem(
              icon: Icons.pets,
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            _BottomItem(
              icon: Icons.calendar_month,
              selected: false,
              onTap: () {},
            ),
            _BottomItem(
              icon: Icons.settings,
              selected: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _BottomItem({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4CAF50) : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: AnimatedScale(
          scale: selected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            icon, 
            size: 28, 
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}