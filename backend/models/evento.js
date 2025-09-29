const mongoose = require('mongoose');

const eventoSchema = new mongoose.Schema({
  titulo: {
    type: String,
    required: true,
    trim: true
  },
  descripcion: {
    type: String,
    trim: true
  },
  fecha: {
    type: Date,
    required: true
  },
  hora: {
    type: String,
    required: true
  },
  tipo: {
    type: String,
    enum: ['veterinario', 'alimentacion', 'ejercicio', 'medicamento', 'baño', 'otro'],
    required: true
  },
  prioridad: {
    type: String,
    enum: ['baja', 'media', 'alta'],
    default: 'media'
  },
  completado: {
    type: Boolean,
    default: false
  },
  recordatorio: {
    activo: {
      type: Boolean,
      default: true
    },
    tiempoAntes: {
      type: Number, // minutos antes del evento
      default: 30
    }
  },
  mascota: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Mascota',
    required: true
  },
  usuario: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Evento', eventoSchema);