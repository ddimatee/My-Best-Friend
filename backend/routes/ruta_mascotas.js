const express = require('express');
const router = express.Router();
const Mascota = require('../models/mascota');
const Usuario = require('../models/usuario');
const mongoose = require('mongoose');
const protegerRuta = require('../middlewares/protegerRuta');
const { validarMascota, validarId } = require('../middlewares/validaciones');

// Registrar nueva mascota
router.post('/', protegerRuta, validarMascota, async (req, res) => {
  try {
    const nuevaMascota = new Mascota({
      ...req.body,
      dueño: req.usuario._id
    });
    await nuevaMascota.save();
    res.status(201).json({ mensaje: 'Mascota registrada correctamente', mascota: nuevaMascota });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.get('/', protegerRuta, async (req, res) => {
  try {
    // Listar mascotas del usuario y poblar información básica del dueño/cuidador
    const mascotas = await Mascota.find({ dueño: req.usuario._id })
      .populate('dueño', 'nombre apellido correo celular fotoPerfil')
      .populate('cuidador', 'nombre apellido correo celular fotoPerfil');
    res.json(mascotas);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener mascotas' });
  }
})

router.get('/test', (req, res) => {
  res.send('Ruta de mascotas funcionando');
});

// Debug: mostrar resumen del stack del router antes de exportar
try {
  const resumen = router.stack ? router.stack.map((l) => ({
    path: l.route ? l.route.path : undefined,
    methods: l.route ? Object.keys(l.route.methods) : undefined,
    name: l.name
  })) : [];
  console.log('Debug ruta_mascotas router.stack:', JSON.stringify(resumen, null, 2));
} catch (e) {
  console.log('Error debug ruta_mascotas:', e.message);
}

router.get('/:id', protegerRuta, async (req, res) => {
  try {
    const { id } = req.params;

    // Validar que el id tenga formato ObjectId
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'Id inválido' });
    }

    console.debug('GET /api/mascotas/:id -> id recibido:', id, 'usuario:', req.usuario?._id);

    // Buscar por id y poblar relaciones
    const mascota = await Mascota.findById(id)
      .populate('dueño', 'nombre apellido correo celular fotoPerfil')
      .populate('cuidador', 'nombre apellido correo celular fotoPerfil');

    if (!mascota) {
      return res.status(404).json({ error: 'Mascota no encontrada' });
    }

  // Debido a que 'dueño' puede estar poblado (objeto) o no (ObjectId) normalizamos
  const duenioId = (mascota.dueño && mascota.dueño._id) ? mascota.dueño._id.toString() : (mascota.dueño ? mascota.dueño.toString() : null);
  const usuarioId = req.usuario?._id ? req.usuario._id.toString() : null;

    if (!duenioId || duenioId !== usuarioId) {
      return res.status(403).json({ error: 'No autorizado: la mascota no pertenece al usuario' });
    }

    res.json(mascota);
  } catch (error) {
    console.error('Error en GET /api/mascotas/:id ->', error);
    res.status(500).json({ error: 'Error al obtener la mascota' });
  }
});

router.put('/:id', protegerRuta, async (req, res) => {
  try {
    const mascota = await Mascota.findOneAndUpdate(
      { _id: req.params.id, dueño: req.usuario._id },
      req.body,
      { new: true, runValidators: true }
    ).populate('dueño', 'nombre apellido correo celular fotoPerfil')
     .populate('cuidador', 'nombre apellido correo celular fotoPerfil');

    if (!mascota) {
      return res.status(404).json({ error: 'Mascota no encontrada o no pertenece al usuario' });
    }

    res.json({ mensaje: 'Mascota actualizada correctamente', mascota });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Eliminar mascota (sólo dueño puede eliminar). También quitar referencia en Usuario.mascotas
router.delete('/:id', protegerRuta, async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'Id inválido' });
    }

    // Eliminar la mascota asegurando que pertenece al usuario (operación atómica)
    const mascotaEliminada = await Mascota.findOneAndDelete({ _id: id, dueño: req.usuario._id });
    if (!mascotaEliminada) {
      // Puede ser que no exista o no pertenezca al usuario
      return res.status(404).json({ error: 'Mascota no encontrada o no pertenece al usuario' });
    }

    // Quitar referencia en Usuario.mascotas si existe
    await Usuario.updateOne(
      { _id: req.usuario._id },
      { $pull: { mascotas: mascotaEliminada._id } }
    );

    res.json({ mensaje: 'Mascota eliminada correctamente' });
  } catch (error) {
    console.error('Error en DELETE /api/mascotas/:id ->', error);
    res.status(500).json({ error: 'Error al eliminar la mascota' });
  }
});

module.exports = router;
 