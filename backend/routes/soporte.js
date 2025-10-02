const express = require('express');
const router = express.Router();
const Soporte = require('../models/soporte');
const protegerRuta = require('../middlewares/protegerRuta');

// Crear ticket de soporte
router.post('/', protegerRuta, async (req, res) => {
  try {
    const { tipo, mensaje, metadata } = req.body;
    if (!tipo || !mensaje) {
      return res.status(400).json({ error: 'Tipo y mensaje son requeridos' });
    }

    const soporte = await Soporte.create({
      usuario: req.usuario?._id,
      tipo,
      mensaje,
      metadata: metadata || {}
    });

    res.status(201).json({
      mensaje: 'Solicitud registrada correctamente',
      soporte
    });
  } catch (error) {
    console.error('Error creando soporte:', error);
    res.status(500).json({ error: 'Error al crear solicitud de soporte' });
  }
});

// Listar tickets del usuario autenticado
router.get('/', protegerRuta, async (req, res) => {
  try {
    const tickets = await Soporte.find({ usuario: req.usuario._id })
      .sort({ createdAt: -1 })
      .lean();
    res.json({ total: tickets.length, tickets });
  } catch (error) {
    console.error('Error listando soporte:', error);
    res.status(500).json({ error: 'Error al obtener tickets' });
  }
});

// Obtener un ticket específico
router.get('/:id', protegerRuta, async (req, res) => {
  try {
    const ticket = await Soporte.findOne({ _id: req.params.id, usuario: req.usuario._id });
    if (!ticket) return res.status(404).json({ error: 'No encontrado' });
    res.json(ticket);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener ticket' });
  }
});

module.exports = router;
