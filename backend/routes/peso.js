const express = require('express');
const router = express.Router();
const RegistroPeso = require('../models/registroPeso');
const protegerRuta = require('../middlewares/protegerRuta');

// Registrar nuevo peso
router.post('/', protegerRuta, async (req, res) => {
  try {
    const nuevoRegistro = new RegistroPeso({
      ...req.body,
      usuario: req.usuario._id
    });
    await nuevoRegistro.save();
    await nuevoRegistro.populate('mascota', 'nombre raza');
    
    res.status(201).json({ 
      mensaje: 'Peso registrado correctamente', 
      registro: nuevoRegistro 
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Obtener registros de peso
router.get('/', protegerRuta, async (req, res) => {
  try {
    const { mascota, fechaInicio, fechaFin, limite } = req.query;
    let filtro = { usuario: req.usuario._id };
    
    if (mascota) filtro.mascota = mascota;
    
    if (fechaInicio && fechaFin) {
      filtro.fecha = {
        $gte: new Date(fechaInicio),
        $lte: new Date(fechaFin)
      };
    }
    
    let query = RegistroPeso.find(filtro)
      .populate('mascota', 'nombre raza fotoPerfil')
      .sort({ fecha: -1 });
    
    if (limite) {
      query = query.limit(parseInt(limite));
    }
    
    const registros = await query;
    res.json(registros);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener registros de peso' });
  }
});

// Obtener registros por mascota específica
router.get('/mascota/:mascotaId', protegerRuta, async (req, res) => {
  try {
    const { limite = 10 } = req.query;
    
    const registros = await RegistroPeso.find({
      mascota: req.params.mascotaId,
      usuario: req.usuario._id
    })
    .populate('mascota', 'nombre raza fotoPerfil')
    .sort({ fecha: -1 })
    .limit(parseInt(limite));
    
    res.json(registros);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener registros de la mascota' });
  }
});

// Obtener últimos registros para gráfico
router.get('/grafico/:mascotaId', protegerRuta, async (req, res) => {
  try {
    const { periodo = '6m' } = req.query; // 1m, 3m, 6m, 1a
    
    let fechaInicio = new Date();
    switch(periodo) {
      case '1m':
        fechaInicio.setMonth(fechaInicio.getMonth() - 1);
        break;
      case '3m':
        fechaInicio.setMonth(fechaInicio.getMonth() - 3);
        break;
      case '6m':
        fechaInicio.setMonth(fechaInicio.getMonth() - 6);
        break;
      case '1a':
        fechaInicio.setFullYear(fechaInicio.getFullYear() - 1);
        break;
    }
    
    const registros = await RegistroPeso.find({
      mascota: req.params.mascotaId,
      usuario: req.usuario._id,
      fecha: { $gte: fechaInicio }
    })
    .select('peso fecha observaciones tipoRegistro')
    .sort({ fecha: 1 });
    
    res.json(registros);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener datos para gráfico' });
  }
});

// Obtener estadísticas de peso
router.get('/estadisticas/:mascotaId', protegerRuta, async (req, res) => {
  try {
    const registros = await RegistroPeso.find({
      mascota: req.params.mascotaId,
      usuario: req.usuario._id
    }).sort({ fecha: 1 });
    
    if (registros.length === 0) {
      return res.json({ mensaje: 'No hay registros de peso disponibles' });
    }
    
    const pesos = registros.map(r => r.peso);
    const pesoActual = pesos[pesos.length - 1];
    const pesoAnterior = pesos.length > 1 ? pesos[pesos.length - 2] : pesoActual;
    const pesoMinimo = Math.min(...pesos);
    const pesoMaximo = Math.max(...pesos);
    const pesoPromedio = pesos.reduce((sum, peso) => sum + peso, 0) / pesos.length;
    
    const variacion = pesoActual - pesoAnterior;
    const tendencia = variacion > 0 ? 'aumento' : variacion < 0 ? 'disminución' : 'estable';
    
    const estadisticas = {
      pesoActual: parseFloat(pesoActual.toFixed(2)),
      pesoAnterior: parseFloat(pesoAnterior.toFixed(2)),
      variacion: parseFloat(variacion.toFixed(2)),
      tendencia,
      pesoMinimo: parseFloat(pesoMinimo.toFixed(2)),
      pesoMaximo: parseFloat(pesoMaximo.toFixed(2)),
      pesoPromedio: parseFloat(pesoPromedio.toFixed(2)),
      totalRegistros: registros.length,
      fechaUltimoRegistro: registros[registros.length - 1].fecha
    };
    
    res.json(estadisticas);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener estadísticas' });
  }
});

// Actualizar registro de peso
router.put('/:id', protegerRuta, async (req, res) => {
  try {
    const registro = await RegistroPeso.findOneAndUpdate(
      { _id: req.params.id, usuario: req.usuario._id },
      req.body,
      { new: true, runValidators: true }
    ).populate('mascota', 'nombre raza fotoPerfil');
    
    if (!registro) {
      return res.status(404).json({ error: 'Registro no encontrado' });
    }
    
    res.json({ mensaje: 'Registro actualizado correctamente', registro });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Eliminar registro de peso
router.delete('/:id', protegerRuta, async (req, res) => {
  try {
    const registro = await RegistroPeso.findOneAndDelete({
      _id: req.params.id,
      usuario: req.usuario._id
    });
    
    if (!registro) {
      return res.status(404).json({ error: 'Registro no encontrado' });
    }
    
    res.json({ mensaje: 'Registro eliminado correctamente' });
  } catch (error) {
    res.status(500).json({ error: 'Error al eliminar registro' });
  }
});

module.exports = router;