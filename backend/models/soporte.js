const mongoose = require('mongoose');

const soporteSchema = new mongoose.Schema({
  usuario: { type: mongoose.Schema.Types.ObjectId, ref: 'Usuario', required: false }, // opcional si se permite anónimo
  tipo: {
    type: String,
    enum: ['Soporte técnico', 'Sugerencia', 'Reporte de error', 'Solicitud de función', 'Otro'],
    required: true
  },
  mensaje: { type: String, required: true, trim: true },
  estado: { type: String, enum: ['nuevo', 'en_progreso', 'resuelto', 'cerrado'], default: 'nuevo' },
  origen: { type: String, default: 'app' },
  metadata: { type: Object, default: {} },
  respuesta: { type: String, default: '' },
  leido: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = mongoose.model('Soporte', soporteSchema);
