const express = require('express');
const router = express.Router();
const Vacuna = require('../models/vacuna');
const protegerRuta = require('../middlewares/protegerRuta');

// Registrar nueva vacuna
router.post('/', protegerRuta, async (req, res) => {
  try {
    const nuevaVacuna = new Vacuna({
      ...req.body,
      usuario: req.usuario._id
    });
    await nuevaVacuna.save();
    
    await nuevaVacuna.populate('mascota', 'nombre raza');
    
    res.status(201).json({ 
      mensaje: 'Vacuna registrada correctamente', 
      vacuna: nuevaVacuna 
    });
  } catch (error) {
    console.error('❌ Error:', error.message);
    res.status(400).json({ error: error.message });
  }
});

// Obtener vacunas de las mascotas del usuario
router.get('/', protegerRuta, async (req, res) => {
  try {
    const { mascota, estado } = req.query;
    let filtro = { usuario: req.usuario._id };
    
    if (mascota) filtro.mascota = mascota;
    if (estado) filtro.estado = estado;
    
    const vacunas = await Vacuna.find(filtro)
      .populate('mascota', 'nombre raza fotoPerfil')
      .sort({ fechaAplicacion: -1 });
    
    res.json(vacunas);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener vacunas' });
  }
});

// Obtener vacunas por mascota
router.get('/mascota/:mascotaId', protegerRuta, async (req, res) => {
  try {
    const vacunas = await Vacuna.find({
      mascota: req.params.mascotaId,
      usuario: req.usuario._id
    })
    .populate('mascota', 'nombre raza fotoPerfil')
    .sort({ fechaAplicacion: -1 });
    
    res.json(vacunas);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener vacunas de la mascota' });
  }
});

// Obtener vacunas próximas a vencer
router.get('/proximas-vencer', protegerRuta, async (req, res) => {
  try {
    const hoy = new Date();
    const en30Dias = new Date();
    en30Dias.setDate(hoy.getDate() + 30);
    
    const vacunasProximas = await Vacuna.find({
      usuario: req.usuario._id,
      fechaVencimiento: {
        $gte: hoy,
        $lte: en30Dias
      },
      estado: { $in: ['vigente', 'proxima_vencer'] }
    })
    .populate('mascota', 'nombre raza fotoPerfil')
    .sort({ fechaVencimiento: 1 });
    
    res.json(vacunasProximas);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener vacunas próximas a vencer' });
  }
});

// Obtener estadísticas de vacunación
router.get('/estadisticas', protegerRuta, async (req, res) => {
  try {
    const estadisticas = await Vacuna.aggregate([
      { $match: { usuario: req.usuario._id } },
      {
        $group: {
          _id: '$estado',
          cantidad: { $sum: 1 }
        }
      }
    ]);
    
    const resumen = {
      vigente: 0,
      vencida: 0,
      proxima_vencer: 0,
      total: 0
    };
    
    estadisticas.forEach(est => {
      resumen[est._id] = est.cantidad;
      resumen.total += est.cantidad;
    });
    
    res.json(resumen);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener estadísticas' });
  }
});

// Obtener recordatorios activos de vacunas para el calendario
router.get('/recordatorios', protegerRuta, async (req, res) => {
  try {
    const vacunasConRecordatorio = await Vacuna.find({
      usuario: req.usuario._id,
      'recordatorio.activo': true,
      'recordatorio.fechaRecordatorio': { $exists: true }
    })
      .populate('mascota', 'nombre raza fotoPerfil')
      .sort({ 'recordatorio.fechaRecordatorio': 1 });
    
    // Transformar las vacunas a un formato compatible con el calendario
    const recordatorios = vacunasConRecordatorio.map(vacuna => ({
      id: vacuna._id,
      titulo: `Recordatorio: ${vacuna.nombre}`,
      descripcion: vacuna.observaciones || `Vacuna para ${vacuna.mascota?.nombre || 'mascota'}`,
      categoria: 'Vacuna',
      fechaHora: vacuna.recordatorio.fechaRecordatorio,
      tipo: 'vacuna',
      mascota: vacuna.mascota,
      ubicacion: vacuna.ubicacion || ''
    }));
    
    res.json(recordatorios);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener recordatorios de vacunas' });
  }
});

// Actualizar vacuna
router.put('/:id', protegerRuta, async (req, res) => {
  try {
    const vacuna = await Vacuna.findOneAndUpdate(
      { _id: req.params.id, usuario: req.usuario._id },
      req.body,
      { new: true, runValidators: true }
    ).populate('mascota', 'nombre raza fotoPerfil');
    
    if (!vacuna) {
      return res.status(404).json({ error: 'Vacuna no encontrada' });
    }
    
    res.json({ mensaje: 'Vacuna actualizada correctamente', vacuna });
  } catch (error) {
    console.error('❌ Error:', error.message);
    res.status(400).json({ error: error.message });
  }
});

// Eliminar vacuna
router.delete('/:id', protegerRuta, async (req, res) => {
  try {
    const vacuna = await Vacuna.findOneAndDelete({
      _id: req.params.id,
      usuario: req.usuario._id
    });
    
    if (!vacuna) {
      return res.status(404).json({ error: 'Vacuna no encontrada' });
    }
    
    res.json({ mensaje: 'Vacuna eliminada correctamente' });
  } catch (error) {
    res.status(500).json({ error: 'Error al eliminar vacuna' });
  }
});

// Actualizar estados de vacunas (tarea programada)
router.post('/actualizar-estados', protegerRuta, async (req, res) => {
  try {
    const vacunas = await Vacuna.find({ usuario: req.usuario._id });
    const actualizadas = [];
    
    for (let vacuna of vacunas) {
      const estadoAnterior = vacuna.estado;
      await vacuna.save(); // Esto ejecuta el middleware pre('save')
      if (vacuna.estado !== estadoAnterior) {
        actualizadas.push(vacuna);
      }
    }
    
    res.json({ 
      mensaje: `Se actualizaron ${actualizadas.length} vacunas`,
      actualizadas 
    });
  } catch (error) {
    res.status(500).json({ error: 'Error al actualizar estados' });
  }
});

module.exports = router;