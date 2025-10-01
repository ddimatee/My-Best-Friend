const express = require('express');
const router = express.Router();
const Foto = require('../models/foto');
const protegerRuta = require('../middlewares/protegerRuta');

// Subir nueva foto
router.post('/', protegerRuta, async (req, res) => {
  try {
    const datosNuevaFoto = {
      ...req.body,
      usuario: req.usuario._id
    };
    
    // Si se envía una fecha desde el frontend, usarla; si no, usar la fecha actual
    if (!datosNuevaFoto.fecha) {
      datosNuevaFoto.fecha = new Date();
    }
    
    const nuevaFoto = new Foto(datosNuevaFoto);
    await nuevaFoto.save();
    await nuevaFoto.populate('mascota', 'nombre raza');
    
    res.status(201).json({ 
      mensaje: 'Foto subida correctamente', 
      foto: nuevaFoto 
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Obtener fotos del álbum
router.get('/', protegerRuta, async (req, res) => {
  try {
    const { mascota, etiqueta, esPortada, limite, pagina } = req.query;
    let filtro = { usuario: req.usuario._id };
    
    if (mascota) filtro.mascota = mascota;
    if (etiqueta) filtro.etiquetas = { $in: [etiqueta] };
    if (esPortada !== undefined) filtro.esPortada = esPortada === 'true';
    
    const limitePagina = parseInt(limite) || 20;
    const paginaActual = parseInt(pagina) || 1;
    const saltar = (paginaActual - 1) * limitePagina;
    
    const fotos = await Foto.find(filtro)
      .populate('mascota', 'nombre raza fotoPerfil')
      .sort({ fecha: -1 })
      .limit(limitePagina)
      .skip(saltar);
    
    const total = await Foto.countDocuments(filtro);
    
    res.json({
      fotos,
      paginacion: {
        paginaActual,
        totalPaginas: Math.ceil(total / limitePagina),
        totalFotos: total,
        limite: limitePagina
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener fotos' });
  }
});

// Obtener fotos por mascota
router.get('/mascota/:mascotaId', protegerRuta, async (req, res) => {
  try {
    const { limite = 20, pagina = 1 } = req.query;
    
    const limitePagina = parseInt(limite);
    const paginaActual = parseInt(pagina);
    const saltar = (paginaActual - 1) * limitePagina;
    
    const fotos = await Foto.find({
      mascota: req.params.mascotaId,
      usuario: req.usuario._id
    })
    .populate('mascota', 'nombre raza fotoPerfil')
    .sort({ fecha: -1 })
    .limit(limitePagina)
    .skip(saltar);
    
    const total = await Foto.countDocuments({
      mascota: req.params.mascotaId,
      usuario: req.usuario._id
    });
    
    res.json({
      fotos,
      paginacion: {
        paginaActual,
        totalPaginas: Math.ceil(total / limitePagina),
        totalFotos: total,
        limite: limitePagina
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener fotos de la mascota' });
  }
});

// Obtener fotos de portada
router.get('/portadas', protegerRuta, async (req, res) => {
  try {
    const fotosPortada = await Foto.find({
      usuario: req.usuario._id,
      esPortada: true
    })
    .populate('mascota', 'nombre raza fotoPerfil')
    .sort({ fecha: -1 });
    
    res.json(fotosPortada);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener fotos de portada' });
  }
});

// Buscar fotos por etiquetas
router.get('/buscar', protegerRuta, async (req, res) => {
  try {
    const { termino } = req.query;
    
    if (!termino) {
      return res.status(400).json({ error: 'Se requiere un término de búsqueda' });
    }
    
    const fotos = await Foto.find({
      usuario: req.usuario._id,
      $or: [
        { titulo: { $regex: termino, $options: 'i' } },
        { descripcion: { $regex: termino, $options: 'i' } },
        { etiquetas: { $in: [new RegExp(termino, 'i')] } },
        { ubicacion: { $regex: termino, $options: 'i' } }
      ]
    })
    .populate('mascota', 'nombre raza fotoPerfil')
    .sort({ fecha: -1 });
    
    res.json(fotos);
  } catch (error) {
    res.status(500).json({ error: 'Error en la búsqueda' });
  }
});

// Obtener todas las etiquetas utilizadas
router.get('/etiquetas', protegerRuta, async (req, res) => {
  try {
    const etiquetas = await Foto.distinct('etiquetas', {
      usuario: req.usuario._id
    });
    
    res.json(etiquetas.filter(etiqueta => etiqueta && etiqueta.trim() !== ''));
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener etiquetas' });
  }
});

// Actualizar foto
router.put('/:id', protegerRuta, async (req, res) => {
  try {
    const foto = await Foto.findOneAndUpdate(
      { _id: req.params.id, usuario: req.usuario._id },
      req.body,
      { new: true, runValidators: true }
    ).populate('mascota', 'nombre raza fotoPerfil');
    
    if (!foto) {
      return res.status(404).json({ error: 'Foto no encontrada' });
    }
    
    res.json({ mensaje: 'Foto actualizada correctamente', foto });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Establecer como foto de portada
router.patch('/:id/portada', protegerRuta, async (req, res) => {
  try {
    const foto = await Foto.findOneAndUpdate(
      { _id: req.params.id, usuario: req.usuario._id },
      { esPortada: true },
      { new: true }
    ).populate('mascota', 'nombre raza fotoPerfil');
    
    if (!foto) {
      return res.status(404).json({ error: 'Foto no encontrada' });
    }
    
    res.json({ mensaje: 'Foto establecida como portada', foto });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Eliminar foto
router.delete('/:id', protegerRuta, async (req, res) => {
  try {
    const foto = await Foto.findOneAndDelete({
      _id: req.params.id,
      usuario: req.usuario._id
    });
    
    if (!foto) {
      return res.status(404).json({ error: 'Foto no encontrada' });
    }
    
    res.json({ mensaje: 'Foto eliminada correctamente' });
  } catch (error) {
    res.status(500).json({ error: 'Error al eliminar foto' });
  }
});

// Estadísticas del álbum
router.get('/estadisticas', protegerRuta, async (req, res) => {
  try {
    const estadisticas = await Foto.aggregate([
      { $match: { usuario: req.usuario._id } },
      {
        $group: {
          _id: '$mascota',
          totalFotos: { $sum: 1 },
          ultimaFoto: { $max: '$fecha' }
        }
      },
      {
        $lookup: {
          from: 'mascotas',
          localField: '_id',
          foreignField: '_id',
          as: 'mascota'
        }
      },
      { $unwind: '$mascota' },
      {
        $project: {
          mascotaNombre: '$mascota.nombre',
          totalFotos: 1,
          ultimaFoto: 1
        }
      }
    ]);
    
    const totalFotos = await Foto.countDocuments({ usuario: req.usuario._id });
    
    res.json({
      totalFotos,
      porMascota: estadisticas
    });
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener estadísticas' });
  }
});

module.exports = router;