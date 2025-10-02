// MODO OFFLINE: Implementación mock en memoria que reemplaza al ApiService original.
// Esta versión no realiza peticiones HTTP ni persiste en BD. Solo mantiene datos
// en estructuras locales mientras la app está viva. Las interfaces devuelven el
// mismo tipo de estructuras que el backend real para minimizar cambios en UI.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl => 'offline://api';

  ApiService(){
    _seed();
  }

  void _seed(){
    if(_usuarios.isNotEmpty) return; // evitar duplicar
    final userId = _genId('usr', _cUsuario++);
    final usuario = {
      '_id': userId,
      'nombre': 'Ana',
      'apellido': 'Offline',
      'correo': 'ana@example.com',
      'celular': '111111111',
      'fotoPerfil': null,
      'creado': DateTime.now().toIso8601String(),
    };
    _usuarios.add(usuario);
    // token automático para facilitar pruebas
    saveToken('token_$userId');

    final mascotaId = _genId('mas', _cMascota++);
    final mascota = {
      '_id': mascotaId,
      'dueno': userId,
      'nombre': 'Fido',
      'especie': 'Perro',
      'raza': 'Mestizo',
      'fechaNacimiento': DateTime.now().subtract(const Duration(days: 400)).toIso8601String(),
      'sexo': 'M',
      'descripcion': 'Compañero leal',
      'oculto': false,
      'fotoPerfil': null,
      'creado': DateTime.now().toIso8601String(),
    };
    _mascotas.add(mascota);

    // eventos iniciales
    for(int i=0;i<3;i++){
      final fecha = DateTime.now().add(Duration(days: i));
      final fechaStr='${fecha.year.toString().padLeft(4,'0')}-${fecha.month.toString().padLeft(2,'0')}-${fecha.day.toString().padLeft(2,'0')}';
      final evento = {
        '_id': _genId('evt', _cEvento++),
        'mascota': mascotaId,
        'titulo': 'Evento ${i+1}',
        'tipo': i==0? 'consulta':'rutina',
        'fecha': fechaStr,
        'hora': '09:00',
        'descripcion': 'Descripción del evento ${i+1}',
        'prioridad': 'media',
        'completado': false,
        'recordatorio': {'activo': true, 'tiempoAntes': 30},
      };
      _eventos.add(evento);
    }

    // vacuna ejemplo
    final vacuna = {
      '_id': _genId('vac', _cVacuna++),
      'mascota': mascotaId,
      'nombre': 'Rabia',
      'fechaAplicacion': DateTime.now().subtract(const Duration(days:30)).toIso8601String(),
      'recordatorio': {'activo': true},
    };
    _vacunas.add(vacuna);

    // peso inicial
    final peso = {
      '_id': _genId('peso', _cPeso++),
      'mascota': mascotaId,
      'peso': 12.4,
      'fecha': DateTime.now().subtract(const Duration(days:7)).toIso8601String(),
      'tipoRegistro': 'rutina',
    };
    _pesos.add(peso);
  }

  // ================== Estado en memoria ==================
  final List<Map<String,dynamic>> _usuarios = [];
  final List<Map<String,dynamic>> _mascotas = [];
  final List<Map<String,dynamic>> _eventos = [];
  final List<Map<String,dynamic>> _vacunas = [];
  final List<Map<String,dynamic>> _pesos = [];
  final List<Map<String,dynamic>> _fotos = [];
  final List<Map<String,dynamic>> _recordatorios = [];

  // Contadores simples para IDs simulados
  int _cUsuario = 1;
  int _cMascota = 1;
  int _cEvento = 1;
  int _cVacuna = 1;
  int _cPeso = 1;
  int _cFoto = 1;
  int _cRecordatorio = 1;

  // =============== Helpers internos ===============
  String _genId(String prefijo, int numero) => '${prefijo}_${numero.toString().padLeft(4,'0')}';
  // Map<String,dynamic> _wrapErr etc ya definidos arriba
  Map<String,dynamic> _wrapOk(dynamic data) => {
    'success': true,
    'data': data,
    'statusCode': 200,
  };
  Map<String,dynamic> _wrapErr(String msg,{int code=400}) => {
    'success': false,
    'message': msg,
    'code': code,
  };

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Usuario autenticado simulado mediante token sencillo "token_<id>"
  Map<String,dynamic>? _usuarioDesdeToken(String? token){
    if(token==null) return null;
    final parts = token.split('_');
    if(parts.length==2){
      return _usuarios.firstWhere((u)=> u['_id'].toString()==parts[1], orElse: ()=>{});
    }
    return null;
  }

  // ================== USUARIOS ==================
  Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
    required String apellido,
    required String correo,
    required String celular,
    required String password,
    String? comoLlegaste,
  }) async {
    if (_usuarios.any((u)=> u['correo']==correo)) {
      return _wrapErr('El correo ya está registrado');
    }
    final id = _genId('usr', _cUsuario++);
    final usuario = {
      '_id': id,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'celular': celular,
      'comoLlegaste': comoLlegaste,
      'fotoPerfil': null,
      'creado': DateTime.now().toIso8601String(),
    };
    _usuarios.add(usuario);
    final token = 'token_${id}';
    await saveToken(token);
    return _wrapOk({'mensaje':'Usuario creado','token':token,'usuario':usuario});
  }

  Future<Map<String, dynamic>> iniciarSesion({
    required String correo,
    required String password,
    bool recordar = false,
  }) async {
    final usuario = _usuarios.firstWhere(
      (u)=>u['correo']==correo,
      orElse: ()=>{}
    );
    if(usuario.isEmpty){
      return _wrapErr('El correo no está registrado', code: 404);
    }
    final token = 'token_${usuario['_id']}';
    await saveToken(token);
    return _wrapOk({'token':token,'usuario':usuario});
  }

  Future<Map<String,dynamic>> obtenerPerfil() async {
    final u = _usuarioDesdeToken(await getToken());
    if(u==null||u.isEmpty) return _wrapErr('No autenticado', code:401);
    return _wrapOk(u);
  }

  Future<Map<String,dynamic>> actualizarPerfil({
    required String id,
    String? nombre,
    String? apellido,
    String? correo,
    String? celular,
    String? fotoPerfil,
  }) async {
    final idx = _usuarios.indexWhere((u)=>u['_id']==id);
    if(idx==-1) return _wrapErr('No encontrado', code:404);
    final u = _usuarios[idx];
    if(correo!=null && correo!=u['correo'] && _usuarios.any((o)=>o['correo']==correo)){
      return _wrapErr('Correo ya usado');
    }
    if(nombre!=null) u['nombre']=nombre;
    if(apellido!=null) u['apellido']=apellido;
    if(correo!=null) u['correo']=correo;
    if(celular!=null) u['celular']=celular;
    if(fotoPerfil!=null) u['fotoPerfil']=fotoPerfil;
    return _wrapOk({'mensaje':'Perfil actualizado','usuario':u});
  }

  Future<Map<String,dynamic>> subirFotoPerfilUsuario({required String id, required List<int> bytes, required String filename, String? mimeType}) async {
    // Solo simulamos guardando una URL falsa
    return actualizarPerfil(id: id, fotoPerfil: 'offline://perfil/$filename');
  }

  Future<void> cerrarSesion() async { await removeToken(); }
  Future<Map<String,dynamic>> eliminarCuenta(String id) async {
    _usuarios.removeWhere((u)=>u['_id']==id);
    return _wrapOk({'mensaje':'Cuenta eliminada'});
  }
  Future<void> setMantenerSesion(bool value) async { final p=await SharedPreferences.getInstance(); await p.setBool('keep_session', value); }
  Future<bool> getMantenerSesion() async { final p=await SharedPreferences.getInstance(); return p.getBool('keep_session')??false; }
  Future<Map<String,dynamic>> guard(Future<Map<String,dynamic>> Function() call,{Future<void> Function()? onUnauthorized}) async {
    final r = await call(); if(r['code']==401 && onUnauthorized!=null) await onUnauthorized(); return r; }

  // ================== MASCOTAS ==================
  Future<Map<String,dynamic>> obtenerMascotas() async {
    final u = _usuarioDesdeToken(await getToken());
    if(u==null||u.isEmpty) return _wrapErr('No autenticado', code:401);
    final lista = _mascotas.where((m)=>m['dueno']==u['_id']).toList();
    return _wrapOk(lista);
  }

  Future<Map<String,dynamic>> crearMascota({
    required String nombre,
    required String especie,
    required String raza,
    required DateTime fechaNacimiento,
    required String sexo,
    String? descripcion,
  }) async {
    final u = _usuarioDesdeToken(await getToken());
    if(u==null||u.isEmpty) return _wrapErr('No autenticado', code:401);
    final id = _genId('mas', _cMascota++);
    final m = {
      '_id': id,
      'dueno': u['_id'],
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'sexo': sexo,
      'descripcion': descripcion,
      'oculto': false,
      'fotoPerfil': null,
      'creado': DateTime.now().toIso8601String(),
    };
    _mascotas.add(m);
    return _wrapOk({'mensaje':'Mascota creada','mascota':m});
  }

  Future<Map<String,dynamic>> actualizarMascota({required String id, required Map<String,dynamic> data}) async {
    final idx = _mascotas.indexWhere((m)=>m['_id']==id);
    if(idx==-1) return _wrapErr('Mascota no encontrada', code:404);
    final m = _mascotas[idx];
    data.forEach((k,v){ if(v!=null) m[k]=v; });
    return _wrapOk({'mensaje':'Mascota actualizada','mascota':m});
  }

  Future<Map<String,dynamic>> eliminarMascota(String id) async {
    _mascotas.removeWhere((m)=>m['_id']==id);
    _eventos.removeWhere((e)=>e['mascota']==id);
    _vacunas.removeWhere((v)=>v['mascota']==id);
    _pesos.removeWhere((p)=>p['mascota']==id);
    _fotos.removeWhere((f)=>f['mascota']==id);
    return _wrapOk({'mensaje':'Mascota eliminada'});
  }

  Future<Map<String,dynamic>> subirFotoMascota({required String id, required String filePath}) async {
    return actualizarMascota(id: id, data: {'fotoPerfil':'offline://mascotas/$id/foto'});
  }

  // ================== EVENTOS ==================
  Future<Map<String,dynamic>> obtenerEventos({String? fechaISO,String? mascotaId,String? tipo,bool? completado}) async {
    List<Map<String,dynamic>> lista = List.from(_eventos);
    if(mascotaId!=null) lista = lista.where((e)=>e['mascota']==mascotaId).toList();
    if(tipo!=null) lista = lista.where((e)=>e['tipo']==tipo).toList();
    if(completado!=null) lista = lista.where((e)=> (e['completado']??false)==completado).toList();
    if(fechaISO!=null) lista = lista.where((e)=> e['fecha']==fechaISO).toList();
    return _wrapOk(lista);
  }

  Future<Map<String,dynamic>> obtenerEventosCalendario({required DateTime inicio, required DateTime fin}) async {
    final lista = _eventos.where((e){
      final f = DateTime.tryParse(e['fechaCompleta'] ?? e['fecha']);
      if(f==null) return false;
      return (f.isAfter(inicio.subtract(const Duration(days:1))) && f.isBefore(fin.add(const Duration(days:1))));
    }).toList();
    return _wrapOk(lista);
  }

  Future<Map<String,dynamic>> crearEvento({
    required String mascotaId,
    required String titulo,
    required String tipo,
    required DateTime fecha,
    required String hora,
    String? descripcion,
    bool recordatorioActivo = true,
    int minutosAntes = 30,
    String prioridad = 'media',
  }) async {
    final id = _genId('evt', _cEvento++);
    final fechaStr = '${fecha.year.toString().padLeft(4,'0')}-${fecha.month.toString().padLeft(2,'0')}-${fecha.day.toString().padLeft(2,'0')}';
    final e = {
      '_id': id,
      'mascota': mascotaId,
      'titulo': titulo,
      'tipo': tipo,
      'fecha': fechaStr,
      'hora': hora,
      'descripcion': descripcion,
      'prioridad': prioridad,
      'completado': false,
      'recordatorio': {
        'activo': recordatorioActivo,
        'tiempoAntes': minutosAntes,
      },
    };
    _eventos.add(e);
    return _wrapOk({'mensaje':'Evento creado','evento':e});
  }

  Future<Map<String,dynamic>> actualizarEvento({
    required String eventoId,
    String? titulo,
    String? tipo,
    DateTime? fecha,
    String? hora,
    String? descripcion,
    String? prioridad,
    bool? completado,
    bool? recordatorioActivo,
    int? minutosAntes,
  }) async {
    final idx = _eventos.indexWhere((e)=>e['_id']==eventoId);
    if(idx==-1) return _wrapErr('Evento no encontrado', code:404);
    final e = _eventos[idx];
    if(titulo!=null) e['titulo']=titulo;
    if(tipo!=null) e['tipo']=tipo;
    if(fecha!=null) e['fecha']='${fecha.year.toString().padLeft(4,'0')}-${fecha.month.toString().padLeft(2,'0')}-${fecha.day.toString().padLeft(2,'0')}';
    if(hora!=null) e['hora']=hora;
    if(descripcion!=null) e['descripcion']=descripcion;
    if(prioridad!=null) e['prioridad']=prioridad;
    if(completado!=null) e['completado']=completado;
    if(recordatorioActivo!=null || minutosAntes!=null){
      final r = e['recordatorio'] ?? {}; r['activo']= recordatorioActivo ?? r['activo']; if(minutosAntes!=null) r['tiempoAntes']=minutosAntes; e['recordatorio']=r;
    }
    return _wrapOk({'mensaje':'Evento actualizado','evento':e});
  }

  Future<Map<String,dynamic>> eliminarEvento(String id) async {
    _eventos.removeWhere((e)=>e['_id']==id);
    return _wrapOk({'mensaje':'Evento eliminado'});
  }

  // ================== VACUNAS ==================
  Future<Map<String,dynamic>> obtenerVacunas({String? mascotaId,String? estado}) async {
    List<Map<String,dynamic>> lista = List.from(_vacunas);
    if(mascotaId!=null) lista = lista.where((v)=>v['mascota']==mascotaId).toList();
    return _wrapOk(lista);
  }

  Future<Map<String,dynamic>> crearVacuna({
    required String mascotaId,
    required String nombre,
    required DateTime fechaAplicacion,
    DateTime? fechaVencimiento,
    String? observaciones,
    String? ubicacion,
    String? lote,
    String? laboratorio,
    String? vetNombre,
    String? vetClinica,
    String? vetTelefono,
    bool? recordatorio,
    TimeOfDay? horaRecordatorio,
  }) async {
    final id=_genId('vac', _cVacuna++);
    DateTime? fechaRecordatorio;
    if(recordatorio==true){
      final h = horaRecordatorio ?? const TimeOfDay(hour:9, minute:0);
      fechaRecordatorio = DateTime(fechaAplicacion.year,fechaAplicacion.month,fechaAplicacion.day,h.hour,h.minute);
    }
    final v = {
      '_id': id,
      'mascota': mascotaId,
      'nombre': nombre,
      'fechaAplicacion': fechaAplicacion.toIso8601String(),
      if (fechaVencimiento!=null) 'fechaVencimiento': fechaVencimiento.toIso8601String(),
      if (observaciones!=null) 'observaciones': observaciones,
      if (ubicacion!=null) 'ubicacion': ubicacion,
      if (lote!=null) 'lote': lote,
      if (laboratorio!=null) 'laboratorio': laboratorio,
      if (recordatorio!=null) 'recordatorio': {
        'activo': recordatorio,
        if (fechaRecordatorio!=null) 'fechaRecordatorio': fechaRecordatorio.toIso8601String(),
      },
      if (vetNombre!=null || vetClinica!=null || vetTelefono!=null) 'veterinario': {
        if (vetNombre!=null) 'nombre': vetNombre,
        if (vetClinica!=null) 'clinica': vetClinica,
        if (vetTelefono!=null) 'telefono': vetTelefono,
      },
    };
    _vacunas.add(v);
    return _wrapOk({'mensaje':'Vacuna creada','vacuna':v});
  }

  Future<Map<String,dynamic>> actualizarVacuna({
    required String vacunaId,
    String? nombre,
    DateTime? fechaAplicacion,
    DateTime? fechaVencimiento,
    String? observaciones,
    String? ubicacion,
    String? lote,
    String? laboratorio,
    String? vetNombre,
    String? vetClinica,
    String? vetTelefono,
    bool? recordatorio,
    TimeOfDay? horaRecordatorio,
  }) async {
    final idx = _vacunas.indexWhere((v)=>v['_id']==vacunaId);
    if(idx==-1) return _wrapErr('Vacuna no encontrada', code:404);
    final v = _vacunas[idx];
    if(nombre!=null) v['nombre']=nombre;
    if(fechaAplicacion!=null) v['fechaAplicacion']=fechaAplicacion.toIso8601String();
    if(fechaVencimiento!=null) v['fechaVencimiento']=fechaVencimiento.toIso8601String();
    if(observaciones!=null) v['observaciones']=observaciones;
    if(ubicacion!=null) v['ubicacion']=ubicacion;
    if(lote!=null) v['lote']=lote;
    if(laboratorio!=null) v['laboratorio']=laboratorio;
    if(recordatorio!=null){
      if(recordatorio==true && horaRecordatorio!=null){
        final fBase = fechaAplicacion ?? DateTime.now();
        final fechaRec = DateTime(fBase.year,fBase.month,fBase.day,horaRecordatorio.hour,horaRecordatorio.minute);
        v['recordatorio']={'activo':true,'fechaRecordatorio':fechaRec.toIso8601String()};
      } else { v['recordatorio']={'activo':recordatorio}; }
    }
    if(vetNombre!=null || vetClinica!=null || vetTelefono!=null){
      v['veterinario']={
        if(vetNombre!=null) 'nombre':vetNombre,
        if(vetClinica!=null) 'clinica':vetClinica,
        if(vetTelefono!=null) 'telefono':vetTelefono,
      };
    }
    return _wrapOk({'mensaje':'Vacuna actualizada','vacuna':v});
  }

  Future<Map<String,dynamic>> eliminarVacuna(String vacunaId) async {
    _vacunas.removeWhere((v)=>v['_id']==vacunaId);
    return _wrapOk({'mensaje':'Vacuna eliminada'});
  }

  Future<Map<String,dynamic>> obtenerRecordatoriosVacunas() async {
    final lista = _vacunas.where((v){
      final r=v['recordatorio'];
      return r is Map && r['activo']==true;
    }).map((v)=>v).toList();
    return _wrapOk({'recordatorios':lista});
  }

  // ================== PESO ==================
  Future<Map<String,dynamic>> obtenerRegistrosPeso({String? mascotaId, DateTime? inicio, DateTime? fin, int? limite}) async {
    List<Map<String,dynamic>> lista = List.from(_pesos);
    if(mascotaId!=null) lista = lista.where((p)=>p['mascota']==mascotaId).toList();
    if(inicio!=null && fin!=null){ lista = lista.where((p){ final f=DateTime.tryParse(p['fecha']??''); return f!=null && f.isAfter(inicio.subtract(const Duration(days:1))) && f.isBefore(fin.add(const Duration(days:1))); }).toList(); }
    if(limite!=null && lista.length>limite) lista = lista.take(limite).toList();
    return _wrapOk(lista);
  }

  Future<Map<String,dynamic>> crearRegistroPeso({required String mascotaId, required double peso, DateTime? fecha, String? observaciones, String tipoRegistro='rutina'}) async {
    final id=_genId('peso', _cPeso++);
    final r = {
      '_id': id,
      'mascota': mascotaId,
      'peso': peso,
      'fecha': (fecha??DateTime.now()).toIso8601String(),
      'observaciones': observaciones,
      'tipoRegistro': tipoRegistro,
    };
    _pesos.add(r);
    return _wrapOk({'mensaje':'Registro de peso creado','registro':r});
  }

  Future<Map<String,dynamic>> actualizarRegistroPeso({required String registroId,double? peso,DateTime? fecha,String? observaciones,String? tipoRegistro}) async {
    final idx = _pesos.indexWhere((p)=>p['_id']==registroId);
    if(idx==-1) return _wrapErr('Registro no encontrado', code:404);
    final r = _pesos[idx];
    if(peso!=null) r['peso']=peso;
    if(fecha!=null) r['fecha']=fecha.toIso8601String();
    if(observaciones!=null) r['observaciones']=observaciones;
    if(tipoRegistro!=null) r['tipoRegistro']=tipoRegistro;
    return _wrapOk({'mensaje':'Registro actualizado','registro':r});
  }

  Future<Map<String,dynamic>> eliminarRegistroPeso(String registroId) async {
    _pesos.removeWhere((p)=>p['_id']==registroId);
    return _wrapOk({'mensaje':'Registro eliminado'});
  }

  // ================== ALBUM ==================
  Future<Map<String,dynamic>> obtenerFotos({String? mascotaId,String? etiqueta,bool? esPortada,int limite=20,int pagina=1}) async {
    List<Map<String,dynamic>> lista = List.from(_fotos);
    if(mascotaId!=null) lista = lista.where((f)=>f['mascota']==mascotaId).toList();
    if(etiqueta!=null) lista = lista.where((f)=> (f['etiquetas'] as List?)?.contains(etiqueta)==true).toList();
    if(esPortada!=null) lista = lista.where((f)=>f['esPortada']==esPortada).toList();
    final start = (pagina-1)*limite; final end = min(start+limite, lista.length);
    final page = start<lista.length ? lista.sublist(start,end) : <Map<String,dynamic>>[];
    return _wrapOk(page);
  }

  Future<Map<String,dynamic>> subirFoto({required String mascotaId, required String url, String? titulo,String? descripcion,String? ubicacion,List<String>? etiquetas,bool esPortada=false, DateTime? fecha}) async {
    final id=_genId('fot', _cFoto++);
    final f = {
      '_id': id,
      'mascota': mascotaId,
      'url': url,
      'titulo': titulo,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'etiquetas': etiquetas ?? [],
      'esPortada': esPortada,
      'fecha': (fecha??DateTime.now()).toIso8601String(),
    };
    _fotos.add(f);
    return _wrapOk({'mensaje':'Foto subida','foto':f});
  }

  Future<Map<String,dynamic>> actualizarFoto({required String fotoId,String? titulo,String? descripcion,String? ubicacion,List<String>? etiquetas,bool? esPortada}) async {
    final idx = _fotos.indexWhere((f)=>f['_id']==fotoId);
    if(idx==-1) return _wrapErr('Foto no encontrada', code:404);
    final f = _fotos[idx];
    if(titulo!=null) f['titulo']=titulo;
    if(descripcion!=null) f['descripcion']=descripcion;
    if(ubicacion!=null) f['ubicacion']=ubicacion;
    if(etiquetas!=null) f['etiquetas']=etiquetas;
    if(esPortada!=null) f['esPortada']=esPortada;
    return _wrapOk({'mensaje':'Foto actualizada','foto':f});
  }

  Future<Map<String,dynamic>> eliminarFoto(String fotoId) async {
    _fotos.removeWhere((f)=>f['_id']==fotoId);
    return _wrapOk({'mensaje':'Foto eliminada'});
  }

  // ================== RECORDATORIOS ==================
  Future<Map<String,dynamic>> crearRecordatorioBackend({
    required String titulo,
    required String descripcion,
    required String categoria,
    required DateTime fechaHora,
    required String tipoRecordatorio,
    required String frecuencia,
    required List<Map<String,dynamic>> avisos,
    bool activo = true,
  }) async {
    final id=_genId('rec', _cRecordatorio++);
    final r = {
      '_id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'fechaHora': fechaHora.toIso8601String(),
      'tipoRecordatorio': tipoRecordatorio,
      'frecuencia': frecuencia,
      'avisos': avisos,
      'activo': activo,
    };
    _recordatorios.add(r);
    return _wrapOk({'mensaje':'Recordatorio creado','recordatorio':r});
  }

  Future<Map<String,dynamic>> listarRecordatoriosBackend({DateTime? desde, DateTime? hasta, bool? activo}) async {
    List<Map<String,dynamic>> lista = List.from(_recordatorios);
    if(desde!=null && hasta!=null){ lista = lista.where((r){ final f=DateTime.tryParse(r['fechaHora']??''); return f!=null && f.isAfter(desde.subtract(const Duration(days:1))) && f.isBefore(hasta.add(const Duration(days:1))); }).toList(); }
    if(activo!=null) lista = lista.where((r)=>r['activo']==activo).toList();
    return _wrapOk(lista);
  }

  Future<Map<String,dynamic>> actualizarRecordatorioBackend({required String id, Map<String,dynamic>? cambios}) async {
    final idx = _recordatorios.indexWhere((r)=>r['_id']==id);
    if(idx==-1) return _wrapErr('Recordatorio no encontrado', code:404);
    final r = _recordatorios[idx];
    (cambios??{}).forEach((k,v){ r[k]=v; });
    return _wrapOk({'mensaje':'Recordatorio actualizado','recordatorio':r});
  }

  Future<Map<String,dynamic>> eliminarRecordatorioBackend(String id) async {
    _recordatorios.removeWhere((r)=>r['_id']==id);
    return _wrapOk({'mensaje':'Recordatorio eliminado'});
  }

  // ================== UTILIDADES ==================
  Future<Map<String,dynamic>> verificarConexion() async => _wrapOk({'modo':'offline','descripcion':'Sin backend'});

  // ================== DISPOSITIVOS ==================
  Future<Map<String,dynamic>> registrarDeviceToken(String token) async {
    return _wrapOk({'mensaje':'Token push registrado (offline)','token': token});
  }
  Future<Map<String,dynamic>> eliminarDeviceToken(String token) async {
    return _wrapOk({'mensaje':'Token push eliminado (offline)','token': token});
  }
}