const express = require('express');
const router = express.Router();
const Usuario = require('../models/usuario');
const generarToken = require('../utils/generarToken');
const protegerRuta = require('../middlewares/protegerRuta');
const Mascota = require('../models/mascota');
const { validarRegistroUsuario, validarLoginUsuario, validarId } = require('../middlewares/validaciones');
const crypto = require('crypto');
const { enviarCodigoRecuperacion } = require('../services/emailService');
const { verificarConexion } = require('../services/emailService');

// Registro de usuario
router.post('/registro', validarRegistroUsuario, async (req, res) => {
  try {
    const nuevoUsuario = new Usuario(req.body);
    await nuevoUsuario.save();
    res.status(201).json({ mensaje: 'Usuario registrado correctamente' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Login de usuario
router.post('/login', validarLoginUsuario, async (req, res) => {
  const { correo, contraseña, recordar } = req.body;
  try {
    const usuario = await Usuario.findOne({ correo });
    if (!usuario) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    const esValida = await usuario.validarContraseña(contraseña);
    if (!esValida) {
      return res.status(401).json({ error: 'Contraseña incorrecta' });
    }

    const token = generarToken(usuario._id);
    let rememberToken;
    if (recordar) {
      rememberToken = crypto.randomBytes(24).toString('hex');
      usuario.rememberToken = rememberToken;
      await usuario.save();
    }
    res.json({ mensaje: 'Login exitoso', usuario, token, rememberToken });
  } catch (error) {
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// Solicitar código de recuperación
router.post('/password/solicitar', async (req, res) => {
  const { correo } = req.body;
  if (!correo) return res.status(400).json({ error: 'Correo requerido' });
  try {
    const usuario = await Usuario.findOne({ correo });
    if (!usuario) return res.status(404).json({ error: 'Usuario no encontrado' });
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    usuario.resetPasswordCode = code;
    usuario.resetPasswordExpira = new Date(Date.now() + 15 * 60 * 1000); // 15 minutos
    await usuario.save();
    // Log en consola para desarrollo
    if (process.env.NODE_ENV !== 'production') {
      console.log(`🔐 Código de recuperación para ${correo}: ${code}`);
    }
  const forceReturn = process.env.RETURN_RESET_CODE_ALWAYS === '1';
  const showDev = process.env.SHOW_DEV_RESET_CODE === '1';

    // Intentar envío de correo
    let envioCorreo = { enviado: false, motivo: 'no configurado' };
    try {
      envioCorreo = await enviarCodigoRecuperacion({ correo, codigo: code });
    } catch (err) {
      console.warn('⚠️  Falló el envío de correo:', err.message);
      envioCorreo = { enviado: false, motivo: 'error_envio', error: err.message };
    }
    res.json({
      mensaje: 'Código generado y enviado',
  code: (process.env.NODE_ENV !== 'production' && showDev) || forceReturn ? code : undefined,
      correoEnviado: envioCorreo.enviado,
      detalleCorreo: envioCorreo.enviado ? undefined : envioCorreo.motivo
    });
  } catch (e) {
    res.status(500).json({ error: 'Error generando código' });
  }
});

// Verificar código
router.post('/password/verificar', async (req, res) => {
  const { correo, code } = req.body;
  if (!correo || !code) return res.status(400).json({ error: 'Datos incompletos' });
  try {
    // IMPORTANTE: los campos resetPasswordCode y resetPasswordExpira tienen select:false en el schema,
    // por eso hay que incluirlos explícitamente o siempre parecerán "no definidos" y dará
    // el error "No hay código activo" aunque sí se haya generado.
    const usuario = await Usuario.findOne({ correo })
      .select('+resetPasswordCode +resetPasswordExpira');
    if (!usuario) return res.status(404).json({ error: 'Usuario no encontrado' });
    if (!usuario.resetPasswordCode || !usuario.resetPasswordExpira) {
      return res.status(400).json({ error: 'No hay código activo' });
    }
    if (usuario.resetPasswordExpira < new Date()) {
      return res.status(400).json({ error: 'Código expirado' });
    }
    if (usuario.resetPasswordCode !== code) {
      return res.status(401).json({ error: 'Código incorrecto' });
    }
    res.json({ mensaje: 'Código válido' });
  } catch (e) {
    res.status(500).json({ error: 'Error verificando código' });
  }
});

// Resetear contraseña
router.post('/password/reset', async (req, res) => {
  const { correo, code, nuevaContraseña } = req.body;
  if (!correo || !code || !nuevaContraseña) return res.status(400).json({ error: 'Datos incompletos' });
  try {
    const usuario = await Usuario.findOne({ correo })
      .select('+resetPasswordCode +resetPasswordExpira');
    if (!usuario) return res.status(404).json({ error: 'Usuario no encontrado' });
    if (!usuario.resetPasswordCode || usuario.resetPasswordCode !== code) {
      return res.status(401).json({ error: 'Código inválido' });
    }
    if (usuario.resetPasswordExpira < new Date()) {
      return res.status(400).json({ error: 'Código expirado' });
    }
    usuario.contraseña = nuevaContraseña; // se hashea en pre-save
    usuario.resetPasswordCode = undefined;
    usuario.resetPasswordExpira = undefined;
    await usuario.save();
    res.json({ mensaje: 'Contraseña actualizada' });
  } catch (e) {
    res.status(500).json({ error: 'Error al resetear contraseña' });
  }
});

// Obtener todos los usuarios (montado en /api/usuarios -> ruta final: /api/usuarios)
router.get('/', async (req, res) => {
  try {
    const usuarios = await Usuario.find().select('-contraseña');
    res.json(usuarios);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener usuarios' });
  }
});

// Actualizar usuario (sólo el propio usuario puede actualizar su perfil)
router.put('/:id', protegerRuta, async (req, res) => {
  try {
    const { id } = req.params;

    if (!id || !id.match(/^[0-9a-fA-F]{24}$/)) {
      return res.status(400).json({ error: 'Id inválido' });
    }

    if (req.usuario._id.toString() !== id) {
      return res.status(403).json({ error: 'No autorizado para actualizar este usuario' });
    }

    // Cargar usuario, asignar campos permitidos y guardar para activar pre-save (hash contraseña)
    const usuario = await Usuario.findById(id);
    if (!usuario) return res.status(404).json({ error: 'Usuario no encontrado' });

    // Campos permitidos para actualizar
    const allow = ['nombre', 'apellido', 'correo', 'celular', 'contraseña', 'fotoPerfil', 'preferencias'];
    for (const key of Object.keys(req.body)) {
      if (allow.includes(key)) {
        usuario[key] = req.body[key];
      }
    }

    await usuario.save();
    const usuarioSinPass = usuario.toObject();
    delete usuarioSinPass.contraseña;

    res.json({ mensaje: 'Usuario actualizado correctamente', usuario: usuarioSinPass });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Eliminar usuario (sólo el propio usuario puede eliminar su cuenta)
router.delete('/:id', protegerRuta, async (req, res) => {
  try {
    const { id } = req.params;

    if (!id || !id.match(/^[0-9a-fA-F]{24}$/)) {
      return res.status(400).json({ error: 'Id inválido' });
    }

    if (req.usuario._id.toString() !== id) {
      return res.status(403).json({ error: 'No autorizado para eliminar este usuario' });
    }

    // Eliminar mascotas asociadas al usuario
    await Mascota.deleteMany({ dueño: id });

    // Eliminar usuario
    await Usuario.findByIdAndDelete(id);

    res.json({ mensaje: 'Usuario y mascotas asociadas eliminadas correctamente' });
  } catch (error) {
    res.status(500).json({ error: 'Error al eliminar usuario' });
  }
});

// Endpoint de prueba para verificar configuración de correo
router.get('/password/test/email', async (req, res) => {
  const estado = await verificarConexion();
  res.json({ servicioCorreo: estado });
});

// Endpoint para forzar envío de prueba (no genera código de reset, solo email simple)
router.post('/password/test/send', async (req, res) => {
  const { correo } = req.body;
  if (!correo) return res.status(400).json({ error: 'Correo requerido' });
  try {
    const resultado = await enviarCodigoRecuperacion({ correo, codigo: '123456' });
    res.json({ envio: resultado });
  } catch (e) {
    res.status(500).json({ error: 'Fallo enviando correo', detalle: e.message });
  }
});

module.exports = router;
