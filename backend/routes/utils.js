const express = require('express');
const router = express.Router();
const DatabaseService = require('../services/databaseService');
const Usuario = require('../models/usuario');
const Mascota = require('../models/mascota');
const Evento = require('../models/evento');
const Vacuna = require('../models/vacuna');
const RegistroPeso = require('../models/registroPeso');
const Foto = require('../models/foto');
const protegerRuta = require('../middlewares/protegerRuta');

// Estado de la base de datos
router.get('/db/estado', (req, res) => {
  const estado = DatabaseService.obtenerEstadoConexion();
  res.json(estado);
});

// Estadísticas generales de la base de datos
router.get('/db/estadisticas', async (req, res) => {
  try {
    const stats = await DatabaseService.obtenerEstadisticas();
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener estadísticas de la DB' });
  }
});

// Dashboard del usuario
router.get('/dashboard', protegerRuta, async (req, res) => {
  try {
    const usuarioId = req.usuario._id;
    
    // Obtener estadísticas en paralelo
    const [
      totalMascotas,
      eventosHoy,
      eventosProximos,
      vacunasVencidas,
      ultimosPesos,
      totalFotos
    ] = await Promise.all([
      Mascota.countDocuments({ dueño: usuarioId }),
      
      Evento.countDocuments({
        usuario: usuarioId,
        fecha: {
          $gte: new Date().setHours(0, 0, 0, 0),
          $lt: new Date().setHours(23, 59, 59, 999)
        }
      }),
      
      Evento.countDocuments({
        usuario: usuarioId,
        fecha: { $gt: new Date() },
        completado: false
      }),
      
      Vacuna.countDocuments({
        usuario: usuarioId,
        estado: 'vencida'
      }),
      
      RegistroPeso.find({ usuario: usuarioId })
        .populate('mascota', 'nombre')
        .sort({ fecha: -1 })
        .limit(3),
      
      Foto.countDocuments({ usuario: usuarioId })
    ]);

    const dashboard = {
      mascotas: {
        total: totalMascotas
      },
      eventos: {
        hoy: eventosHoy,
        proximos: eventosProximos
      },
      vacunas: {
        vencidas: vacunasVencidas
      },
      peso: {
        ultimosRegistros: ultimosPesos
      },
      album: {
        totalFotos
      },
      fechaActualizacion: new Date()
    };

    res.json(dashboard);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener dashboard' });
  }
});

// Resumen por mascota
router.get('/mascota/:mascotaId/resumen', protegerRuta, async (req, res) => {
  try {
    const { mascotaId } = req.params;
    const usuarioId = req.usuario._id;

    // Verificar que la mascota pertenece al usuario
    const mascota = await Mascota.findOne({
      _id: mascotaId,
      dueño: usuarioId
    });

    if (!mascota) {
      return res.status(404).json({ error: 'Mascota no encontrada' });
    }

    // Obtener datos en paralelo
    const [
      proximosEventos,
      vacunasVigentes,
      ultimoPeso,
      totalFotos
    ] = await Promise.all([
      Evento.find({
        mascota: mascotaId,
        usuario: usuarioId,
        fecha: { $gte: new Date() },
        completado: false
      })
      .sort({ fecha: 1 })
      .limit(3),

      Vacuna.find({
        mascota: mascotaId,
        usuario: usuarioId,
        estado: 'vigente'
      })
      .sort({ fechaVencimiento: 1 }),

      RegistroPeso.findOne({
        mascota: mascotaId,
        usuario: usuarioId
      })
      .sort({ fecha: -1 }),

      Foto.countDocuments({
        mascota: mascotaId,
        usuario: usuarioId
      })
    ]);

    const edad = mascota.fecha_nac ? 
      Math.floor((new Date() - new Date(mascota.fecha_nac)) / (1000 * 60 * 60 * 24 * 365.25)) : 
      null;

    const resumen = {
      mascota: {
        ...mascota.toJSON(),
        edad: edad ? `${edad} año${edad !== 1 ? 's' : ''}` : 'No especificada'
      },
      eventos: {
        proximos: proximosEventos
      },
      vacunas: {
        vigentes: vacunasVigentes.length,
        proximaVencer: vacunasVigentes.find(v => {
          const diasParaVencer = Math.ceil(
            (new Date(v.fechaVencimiento) - new Date()) / (1000 * 60 * 60 * 24)
          );
          return diasParaVencer <= 30;
        })
      },
      peso: {
        actual: ultimoPeso?.peso || null,
        fechaUltimo: ultimoPeso?.fecha || null
      },
      album: {
        totalFotos
      }
    };

    res.json(resumen);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener resumen de mascota' });
  }
});

// Busqueda global
router.get('/buscar', protegerRuta, async (req, res) => {
  try {
    const { termino } = req.query;
    const usuarioId = req.usuario._id;

    if (!termino || termino.trim() === '') {
      return res.status(400).json({ error: 'Término de búsqueda requerido' });
    }

    const terminoRegex = new RegExp(termino, 'i');

    // Buscar en paralelo en todas las colecciones
    const [mascotas, eventos, vacunas, fotos] = await Promise.all([
      Mascota.find({
        dueño: usuarioId,
        $or: [
          { nombre: terminoRegex },
          { raza: terminoRegex }
        ]
      }).limit(5),

      Evento.find({
        usuario: usuarioId,
        $or: [
          { titulo: terminoRegex },
          { descripcion: terminoRegex }
        ]
      })
      .populate('mascota', 'nombre')
      .limit(5),

      Vacuna.find({
        usuario: usuarioId,
        $or: [
          { nombre: terminoRegex },
          { laboratorio: terminoRegex },
          { 'veterinario.nombre': terminoRegex }
        ]
      })
      .populate('mascota', 'nombre')
      .limit(5),

      Foto.find({
        usuario: usuarioId,
        $or: [
          { titulo: terminoRegex },
          { descripcion: terminoRegex },
          { etiquetas: { $in: [terminoRegex] } }
        ]
      })
      .populate('mascota', 'nombre')
      .limit(5)
    ]);

    const resultados = {
      mascotas,
      eventos,
      vacunas,
      fotos,
      total: mascotas.length + eventos.length + vacunas.length + fotos.length
    };

    res.json(resultados);
  } catch (error) {
    res.status(500).json({ error: 'Error en la búsqueda' });
  }
});

// Crear respaldo de datos del usuario
router.post('/respaldo', protegerRuta, async (req, res) => {
  try {
    const usuarioId = req.usuario._id;
    const respaldo = await DatabaseService.crearRespaldoUsuario(usuarioId);
    
    res.json({
      mensaje: 'Respaldo creado correctamente',
      respaldo
    });
  } catch (error) {
    res.status(500).json({ error: 'Error al crear respaldo' });
  }
});

// Información de la API
router.get('/info', (req, res) => {
  res.json({
    nombre: 'My Best Friend API',
    version: '1.0.0',
    descripcion: 'API REST para la aplicación My Best Friend',
    endpoints: {
      usuarios: '/api/usuarios',
      mascotas: '/api/mascotas',
      eventos: '/api/eventos',
      vacunas: '/api/vacunas',
      peso: '/api/peso',
      album: '/api/album',
      soporte: '/api/soporte',
      utilidades: '/api/utils'
    },
    documentacion: 'En desarrollo',
    autor: 'My Best Friend Team'
  });
});

module.exports = router;