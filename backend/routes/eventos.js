const express = require('express');
const router = express.Router();
const Evento = require('../models/evento');
const protegerRuta = require('../middlewares/protegerRuta');

// Crear nuevo evento
router.post('/', protegerRuta, async (req, res) => {
  try {
    console.log('📝 POST /api/eventos recibido');
    console.log('   Headers:', req.headers);
    console.log('   Body:', req.body);
    console.log('   Usuario ID:', req.usuario?._id);
    
    const nuevoEvento = new Evento({
      ...req.body,
      usuario: req.usuario._id
    });
    
    console.log('   Evento a guardar:', nuevoEvento);
    
    await nuevoEvento.save();
    await nuevoEvento.populate('mascota', 'nombre raza');
    
    console.log('   ✅ Evento guardado exitosamente');
    
    res.status(201).json({ 
      mensaje: 'Evento creado correctamente', 
      evento: nuevoEvento 
    });
  } catch (error) {
    console.error('   ❌ Error al crear evento:', error.message);
    res.status(400).json({ error: error.message });
  }
});

// Obtener eventos del usuario
router.get('/', protegerRuta, async (req, res) => {
  try {
    const { fecha, mascota, tipo, completado } = req.query;
    let filtro = { usuario: req.usuario._id };
    
    if (fecha) {
      const fechaInicio = new Date(fecha);
      const fechaFin = new Date(fecha);
      fechaFin.setDate(fechaFin.getDate() + 1);
      filtro.fecha = { $gte: fechaInicio, $lt: fechaFin };
    }
    
    if (mascota) filtro.mascota = mascota;
    if (tipo) filtro.tipo = tipo;
    if (completado !== undefined) filtro.completado = completado === 'true';
    
    const eventos = await Evento.find(filtro)
      .populate('mascota', 'nombre raza fotoPerfil')
      .sort({ fecha: 1, hora: 1 });
    
    res.json(eventos);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener eventos' });
  }
});

// Obtener eventos por rango de fechas (para calendario)
router.get('/calendario', protegerRuta, async (req, res) => {
  try {
    const { fechaInicio, fechaFin } = req.query;
    
    if (!fechaInicio || !fechaFin) {
      return res.status(400).json({ error: 'Se requieren fechaInicio y fechaFin' });
    }
    
    const eventos = await Evento.find({
      usuario: req.usuario._id,
      fecha: {
        $gte: new Date(fechaInicio),
        $lte: new Date(fechaFin)
      }
    })
    .populate('mascota', 'nombre raza fotoPerfil')
    .sort({ fecha: 1, hora: 1 });
    
    res.json(eventos);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener eventos del calendario' });
  }
});

// Actualizar evento
router.put('/:id', protegerRuta, async (req, res) => {
  try {
    const evento = await Evento.findOneAndUpdate(
      { _id: req.params.id, usuario: req.usuario._id },
      req.body,
      { new: true, runValidators: true }
    ).populate('mascota', 'nombre raza fotoPerfil');
    
    if (!evento) {
      return res.status(404).json({ error: 'Evento no encontrado' });
    }
    
    res.json({ mensaje: 'Evento actualizado correctamente', evento });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Marcar evento como completado
router.patch('/:id/completar', protegerRuta, async (req, res) => {
  try {
    const evento = await Evento.findOneAndUpdate(
      { _id: req.params.id, usuario: req.usuario._id },
      { completado: !req.body.completado },
      { new: true }
    ).populate('mascota', 'nombre raza fotoPerfil');
    
    if (!evento) {
      return res.status(404).json({ error: 'Evento no encontrado' });
    }
    
    res.json({ 
      mensaje: `Evento ${evento.completado ? 'completado' : 'marcado como pendiente'}`, 
      evento 
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Eliminar evento
router.delete('/:id', protegerRuta, async (req, res) => {
  try {
    const evento = await Evento.findOneAndDelete({
      _id: req.params.id,
      usuario: req.usuario._id
    });
    
    if (!evento) {
      return res.status(404).json({ error: 'Evento no encontrado o no tienes permisos' });
    }
    
    res.json({ mensaje: 'Evento eliminado correctamente', success: true });
  } catch (error) {
    console.error('Error al eliminar evento:', error);
    res.status(500).json({ error: 'Error al eliminar evento: ' + error.message });
  }
});

// Obtener próximos eventos (para notificaciones)
router.get('/proximos', protegerRuta, async (req, res) => {
  try {
    const ahora = new Date();
    const enUnaHora = new Date(ahora.getTime() + 60 * 60 * 1000);
    
    const eventosProximos = await Evento.find({
      usuario: req.usuario._id,
      completado: false,
      fecha: {
        $gte: ahora,
        $lte: enUnaHora
      },
      'recordatorio.activo': true
    })
    .populate('mascota', 'nombre raza fotoPerfil')
    .sort({ fecha: 1 });
    
    res.json(eventosProximos);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener eventos próximos' });
  }
});

module.exports = router;