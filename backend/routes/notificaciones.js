const express = require('express');
const router = express.Router();
const protegerRuta = require('../middlewares/protegerRuta');
const Usuario = require('../models/usuario');
const { enviarNotificacionFCM } = require('../services/fcmService');

// Registrar / actualizar token FCM del dispositivo
router.post('/token', protegerRuta, async (req, res) => {
  const { token } = req.body;
  if (!token) return res.status(400).json({ error: 'Token requerido' });
  try {
    await Usuario.updateOne({ _id: req.usuario._id }, { $addToSet: { deviceTokens: token } });
    res.json({ mensaje: 'Token registrado' });
  } catch (e) {
    res.status(500).json({ error: 'Error registrando token' });
  }
});

// Eliminar token (logout / uninstall)
router.delete('/token', protegerRuta, async (req, res) => {
  const { token } = req.body;
  if (!token) return res.status(400).json({ error: 'Token requerido' });
  try {
    await Usuario.updateOne({ _id: req.usuario._id }, { $pull: { deviceTokens: token } });
    res.json({ mensaje: 'Token eliminado' });
  } catch (e) {
    res.status(500).json({ error: 'Error eliminando token' });
  }
});

// Enviar notificación de prueba al primer token del usuario
router.post('/prueba', protegerRuta, async (req, res) => {
  try {
    const usuario = await Usuario.findById(req.usuario._id).select('deviceTokens nombre');
    if (!usuario || !usuario.deviceTokens || usuario.deviceTokens.length === 0) {
      return res.status(400).json({ error: 'Usuario sin tokens registrados' });
    }
    const token = usuario.deviceTokens[0];
    const resultado = await enviarNotificacionFCM({
      title: 'Notificación de prueba',
      body: `Hola ${usuario.nombre || ''}! Esto es una prueba de push`,
      token,
      data: { tipo: 'prueba' }
    });
    res.json({ mensaje: 'Intento de envío realizado', resultado });
  } catch (e) {
    res.status(500).json({ error: 'Error enviando prueba' });
  }
});

module.exports = router;
