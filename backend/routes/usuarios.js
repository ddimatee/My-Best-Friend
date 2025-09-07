const express = require('express');
const router = express.Router();
const Usuario = require('../models/usuario');
const generarToken = require('../utils/generarToken');
const protegerRuta = require('../middlewares/protegerRuta');

// Registro de usuario
router.post('/registro', async (req, res) => {
  try {
    const nuevoUsuario = new Usuario(req.body);
    await nuevoUsuario.save();
    res.status(201).json({ mensaje: 'Usuario registrado correctamente' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Login de usuario
router.post('/login', async (req, res) => {
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

module.exports = router;