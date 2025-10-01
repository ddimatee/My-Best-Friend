const express = require('express');
const router = express.Router();
const path = require('path');
const fs = require('fs');
const multer = require('multer');
const Mascota = require('../models/mascota');
const Usuario = require('../models/usuario');
const mongoose = require('mongoose');
const protegerRuta = require('../middlewares/protegerRuta');
const { validarMascota, validarId } = require('../middlewares/validaciones');

// ---- Configuración subida de imágenes ----
const uploadDir = path.join(__dirname, '..', 'uploads', 'mascotas');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${Date.now()}-${Math.round(Math.random()*1e9)}${ext}`);
  }
});
const fileFilter = (req, file, cb) => {
  if (/^image\/(jpeg|png|webp|gif)$/.test(file.mimetype)) return cb(null, true);
  cb(new Error('Formato de imagen no permitido')); }
const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 }, // 2MB
  fileFilter
});

// Registrar nueva mascota
router.post('/', protegerRuta, validarMascota, async (req, res) => {
  try {
    const { fechaNacimiento, fecha_nac, ...resto } = req.body;
    const nuevaMascota = new Mascota({
      ...resto,
      fecha_nac: fechaNacimiento || fecha_nac,
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


router.get('/:id', protegerRuta, async (req, res) => {
  try {
    const { id } = req.params;

    // Validar que el id tenga formato ObjectId
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'Id inválido' });
    }

  // id validado y autenticado

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
    const { fechaNacimiento, fecha_nac, ...resto } = req.body;
    const update = { ...resto };
    if (fechaNacimiento || fecha_nac) {
      update.fecha_nac = fechaNacimiento || fecha_nac;
    }
    const mascota = await Mascota.findOneAndUpdate(
      { _id: req.params.id, dueño: req.usuario._id },
      update,
      { new: true, runValidators: true }
    )
      .populate('dueño', 'nombre apellido correo celular fotoPerfil')
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

// Subir / actualizar foto de perfil de mascota
router.post('/:id/foto', protegerRuta, upload.single('foto'), async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'Id inválido' });
    }
    if (!req.file) return res.status(400).json({ error: 'No se recibió archivo' });

    const mascota = await Mascota.findOneAndUpdate(
      { _id: id, dueño: req.usuario._id },
      { fotoPerfil: `/uploads/mascotas/${req.file.filename}` },
      { new: true }
    );
    if (!mascota) return res.status(404).json({ error: 'Mascota no encontrada o no pertenece al usuario' });
    res.json({ mensaje: 'Foto actualizada', mascota });
  } catch (e) {
    console.error('Error subiendo foto mascota:', e);
    res.status(500).json({ error: 'Error al subir foto' });
  }
});

module.exports = router;
 