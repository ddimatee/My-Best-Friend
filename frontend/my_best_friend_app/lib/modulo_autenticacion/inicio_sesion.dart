import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'registro_1.dart';
import 'recuperar_contrasena_correo.dart';
import '../modulo_general/menu_principal.dart';
import '../modulo_general/componentes/avisos.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
	@override
	_LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
	final _formKey = GlobalKey<FormState>();
	final correoController = TextEditingController();
	final contrasenaController = TextEditingController();
	bool recordar = false;
	bool _isLoading = false;

	// Validación de email
	String? _validarEmail(String? value) {
		if (value == null || value.isEmpty) {
			return 'El correo es obligatorio';
		}
		// Regex para validar email
		final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
		if (!emailRegExp.hasMatch(value)) {
			return 'Ingresa un correo válido';
		}
		return null;
	}

	// Validación de contraseña
	String? _validarContrasena(String? value) {
		if (value == null || value.isEmpty) {
			return 'La contraseña es obligatoria';
		}
		if (value.length < 6) {
			return 'La contraseña debe tener al menos 6 caracteres';
		}
		// Validar que tenga mayúscula, minúscula y número
		final hasUpperCase = value.contains(RegExp(r'[A-Z]'));
		final hasLowerCase = value.contains(RegExp(r'[a-z]'));
		final hasDigits = value.contains(RegExp(r'[0-9]'));
		
		if (!hasUpperCase || !hasLowerCase || !hasDigits) {
			return 'Debe contener mayúscula, minúscula y número';
		}
		return null;
	}

	Future<void> iniciarSesion() async {
		// Validar formulario
		if (!_formKey.currentState!.validate()) {
			return;
		}

		setState(() {
			_isLoading = true;
		});

		try {
			final authProvider = Provider.of<AuthProvider>(context, listen: false);
			
			final exito = await authProvider.iniciarSesion(
				correo: correoController.text.trim(),
				password: contrasenaController.text,
			);

			if (exito) {
				// Login exitoso
				Navigator.pushReplacement(
					context,
					MaterialPageRoute(builder: (_) => const MenuPrincipal()),
				);
			} else {
				// Error en el login
				showErrorSnackBar(context, authProvider.errorMessage ?? 'Error al iniciar sesión');
			}
		} catch (e) {
			showErrorSnackBar(context, 'Error de conexión: $e');
		} finally {
			if (mounted) {
				setState(() {
					_isLoading = false;
				});
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		final size = MediaQuery.of(context).size;
    
		return Scaffold(
			backgroundColor: const Color(0xFF4CAF50),
			body: SafeArea(
				child: SingleChildScrollView(
					child: Form(
						key: _formKey,
						child: Container(
							height: size.height - MediaQuery.of(context).padding.top,
							padding: EdgeInsets.symmetric(
								horizontal: size.width * 0.08,
								vertical: size.height * 0.02,
							),
							child: Column(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									// Botón "¿Olvidaste tu contraseña?" en la parte superior derecha
									Align(
										alignment: Alignment.topRight,
										child: TextButton(
											onPressed: () {
												Navigator.push(
													context,
													MaterialPageRoute(builder: (_) => const RecoverPasswordEmailScreen()),
												);
											},
											child: const Text(
												'¿Olvidaste tu\ncontraseña?',
												style: TextStyle(
													color: Colors.white,
													fontSize: 14,
													fontWeight: FontWeight.w500,
													shadows: [
														Shadow(
															blurRadius: 1,
															color: Colors.black26,
															offset: Offset(0, 1),
														),
													],
												),
												textAlign: TextAlign.right,
											),
										),
									),
                
									// Contenido principal centrado
									Column(
										children: [
											// Título "Inicia sesión"
											Container(
												margin: EdgeInsets.only(bottom: size.height * 0.06),
												child: Text(
													'Inicia sesión',
													style: TextStyle(
														fontSize: 36,
														color: Colors.black,
														fontWeight: FontWeight.bold,
														letterSpacing: 1.2,
														shadows: [
															Shadow(
																blurRadius: 3,
																color: Colors.white30,
																offset: Offset(0, 2),
															),
														],
													),
												),
											),
                    
											// Campo "Correo Electrónico"
											Container(
												margin: EdgeInsets.only(bottom: size.height * 0.025),
												child: Container(
													width: double.infinity,
													decoration: BoxDecoration(
														color: Colors.white,
														borderRadius: BorderRadius.circular(30),
														boxShadow: [
															BoxShadow(
																color: Colors.black.withOpacity(0.1),
																spreadRadius: 0,
																blurRadius: 10,
																offset: Offset(0, 4),
															),
														],
													),
													child: TextFormField(
														controller: correoController,
														validator: _validarEmail,
														keyboardType: TextInputType.emailAddress,
														style: const TextStyle(fontSize: 16, color: Colors.black87),
														decoration: const InputDecoration(
															hintText: 'Correo Electrónico',
															hintStyle: TextStyle(
																color: Colors.grey,
																fontWeight: FontWeight.w400,
															),
															border: InputBorder.none,
															contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
															prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
															errorStyle: TextStyle(height: 0.8, fontSize: 12),
														),
													),
												),
											),
                    
											// Campo de contraseña
											Container(
												margin: EdgeInsets.only(bottom: size.height * 0.03),
												child: Container(
													width: double.infinity,
													decoration: BoxDecoration(
														color: Colors.white,
														borderRadius: BorderRadius.circular(30),
														boxShadow: [
															BoxShadow(
																color: Colors.black.withOpacity(0.1),
																spreadRadius: 0,
																blurRadius: 10,
																offset: Offset(0, 4),
															),
														],
													),
													child: TextFormField(
														controller: contrasenaController,
														validator: _validarContrasena,
														obscureText: true,
														style: const TextStyle(fontSize: 16, color: Colors.black87),
														decoration: const InputDecoration(
															hintText: 'Contraseña',
															hintStyle: TextStyle(
																color: Colors.grey,
																fontWeight: FontWeight.w400,
															),
															border: InputBorder.none,
															contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
															prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
															errorStyle: TextStyle(height: 0.8, fontSize: 12),
														),
													),
												),
											),
                    
											// Checkbox "Recordar"
											Container(
												margin: EdgeInsets.only(bottom: size.height * 0.04),
												child: Row(
													mainAxisAlignment: MainAxisAlignment.center,
													children: [
														Container(
															decoration: BoxDecoration(
																borderRadius: BorderRadius.circular(6),
																boxShadow: [
																	BoxShadow(
																		color: Colors.black.withOpacity(0.1),
																		spreadRadius: 0,
																		blurRadius: 4,
																		offset: Offset(0, 2),
																	),
																],
															),
															child: SizedBox(
																height: 24,
																width: 24,
																child: Checkbox(
																	value: recordar,
																	onChanged: (val) => setState(() => recordar = val ?? false),
																	fillColor: MaterialStateProperty.all(Colors.white),
																	checkColor: const Color(0xFF4CAF50),
																	shape: RoundedRectangleBorder(
																		borderRadius: BorderRadius.circular(6),
																	),
																),
															),
														),
														const SizedBox(width: 12),
														const Text(
															'Recordar',
															style: TextStyle(
																color: Colors.black,
																fontSize: 16,
																fontWeight: FontWeight.w600,
																shadows: [
																	Shadow(
																		blurRadius: 1,
																		color: Colors.white30,
																		offset: Offset(0, 1),
																	),
																],
															),
														),
													],
												),
											),
                    
											// Botón "Ingresar"
											Container(
												margin: EdgeInsets.only(bottom: size.height * 0.04),
												child: SizedBox(
													width: size.width * 0.7,
													height: 56,
													child: ElevatedButton(
														onPressed: _isLoading ? null : iniciarSesion,
														style: ElevatedButton.styleFrom(
															backgroundColor: Colors.white,
															foregroundColor: const Color(0xFF4CAF50),
															shape: RoundedRectangleBorder(
																borderRadius: BorderRadius.circular(30),
															),
															elevation: 8,
															shadowColor: Colors.black.withOpacity(0.3),
														),
														child: _isLoading 
															? const SizedBox(
																height: 20,
																width: 20,
																child: CircularProgressIndicator(
																	strokeWidth: 2,
																	valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
																),
															)
															: const Text(
																'Ingresar',
																style: TextStyle(
																	fontSize: 20,
																	fontWeight: FontWeight.bold,
																	letterSpacing: 0.5,
																),
															),
													),
												),
											),
										],
									),
                
									// Footer con imagen y enlaces
									Column(
										children: [
											// Imagen del perro
											Container(
												height: size.height * 0.18,
												margin: EdgeInsets.only(bottom: size.height * 0.02),
												child: Image.asset(
													'assets/images/perro.png',
													fit: BoxFit.contain,
												),
											),
                    
											// Texto "¿No tienes una cuenta?"
											Container(
												margin: EdgeInsets.only(bottom: 8),
												child: Text(
													'¿No tienes una cuenta?',
													style: TextStyle(
														color: Colors.white,
														fontSize: 16,
														fontWeight: FontWeight.w400,
														shadows: [
															Shadow(
																blurRadius: 1,
																color: Colors.black26,
																offset: Offset(0, 1),
															),
														],
													),
												),
											),
                    
											// Botón "Regístrate"
											TextButton(
												onPressed: () {
													Navigator.push(
														context,
														MaterialPageRoute(
															builder: (context) => RegisterScreen1(),
														),
													);
												},
												style: TextButton.styleFrom(
													padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
												),
												child: const Text(
													'Regístrate',
													style: TextStyle(
														color: Colors.white,
														fontSize: 18,
														fontWeight: FontWeight.bold,
														decoration: TextDecoration.underline,
														decorationColor: Colors.white,
														decorationThickness: 2,
														shadows: [
															Shadow(
																blurRadius: 1,
																color: Colors.black26,
																offset: Offset(0, 1),
															),
														],
													),
												),
											),
                    
											SizedBox(height: size.height * 0.02),
										],
									),
								],
							),
						),
					),
				),
			),
		);
	}
}