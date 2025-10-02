const express = require('express');
const router = express.Router();
const Recordatorio = require('../models/recordatorio');
const protegerRuta = require('../middlewares/protegerRuta');

// Crear recordatorio
router.post('/', protegerRuta, async (req, res) => {
  try {
    console.log('[POST /api/recordatorios] body:', req.body, 'user:', req.usuario?._id);
    const data = { ...req.body, usuario: req.usuario._id };
    const rec = await Recordatorio.create(data);
    console.log('Recordatorio creado:', rec._id);
    res.status(201).json({ mensaje: 'Recordatorio creado', recordatorio: rec });
  } catch (e) {
    console.error('Error creando recordatorio:', e.message);
    res.status(400).json({ error: e.message });
  }
});

// Listar recordatorios del usuario (filtro opcional por rango de fechas)
router.get('/', protegerRuta, async (req, res) => {
  try {
    const { desde, hasta, activo } = req.query;
    const filtro = { usuario: req.usuario._id };
    if (desde || hasta) {
      filtro.fechaHora = {};
      if (desde) filtro.fechaHora.$gte = new Date(desde);
      if (hasta) filtro.fechaHora.$lte = new Date(hasta);
    }
    if (activo !== undefined) filtro.activo = activo === 'true';
    const lista = await Recordatorio.find(filtro).sort({ fechaHora: 1 });
    res.json(lista);
  } catch (e) {
    res.status(500).json({ error: 'Error obteniendo recordatorios' });
  }
});

// Actualizar
router.put('/:id', protegerRuta, async (req, res) => {
  try {
    const rec = await Recordatorio.findOneAndUpdate(
      { _id: req.params.id, usuario: req.usuario._id },
      req.body,
      { new: true, runValidators: true }
    );
    if (!rec) return res.status(404).json({ error: 'No encontrado' });
    res.json({ mensaje: 'Recordatorio actualizado', recordatorio: rec });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// Eliminar
router.delete('/:id', protegerRuta, async (req, res) => {
  try {
    const rec = await Recordatorio.findOneAndDelete({ _id: req.params.id, usuario: req.usuario._id });
    if (!rec) return res.status(404).json({ error: 'No encontrado' });
    res.json({ mensaje: 'Recordatorio eliminado' });
  } catch (e) {
    res.status(500).json({ error: 'Error eliminando' });
  }
});

module.exports = router;