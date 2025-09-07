const express = require('express');
const router = express.Router();
const Mascota = require('../models/mascota');
const protegerRuta = require('../middlewares/protegerRuta');

// Registrar nueva mascota
router.post('/', protegerRuta, async (req, res) => {
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
    const mascotas = await Mascota.find({ dueño: req.usuario._id });
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

module.exports = router;
 