const express = require('express');
const router = express.Router();
const Usuario = require('../models/usuario');
const generarToken = require('../utils/generarToken');
const protegerRuta = require('../middlewares/protegerRuta');
const Mascota = require('../models/mascota');
const { validarRegistroUsuario, validarLoginUsuario, validarId } = require('../middlewares/validaciones');

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
  const { correo, contraseña } = req.body;
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
    res.json({ mensaje: 'Login exitoso', usuario, token });
  } catch (error) {
    res.status(500).json({ error: 'Error en el servidor' });
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

module.exports = router;
