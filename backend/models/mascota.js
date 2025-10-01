const mongoose = require('mongoose');

const mascotaSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: true,
    trim: true
  },
  especie: {
    type: String,
    trim: true,
    default: 'perro'
  },
  sexo: {
    type: String,
    enum: ['macho', 'hembra'],
    required: true
  },
  raza: {
    type: String,
    required: true,
    trim: true
  },
  fecha_nac: {
    type: Date
  },
  fotoPerfil: {
    type: String,
    default: ''
  },
  oculto: {
    type: Boolean,
    default: false
  },
  estiloVida: {
    type: String,
    enum: ['activo', 'tranquilo', 'mixto'],
    default: 'mixto'
  },
  cuidaConAlguien: {
    type: Boolean,
    default: false
  },
  dueño: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: true
  },
  cuidador: {
  type: mongoose.Schema.Types.ObjectId,
  ref: 'Usuario'
  }
}, {
  timestamps: true
});

// Virtual para exponer fechaNacimiento homogénea al frontend
mascotaSchema.virtual('fechaNacimiento').get(function() {
  return this.fecha_nac;
});

// Asegurar inclusión de virtuales al serializar
mascotaSchema.set('toJSON', { virtuals: true });
mascotaSchema.set('toObject', { virtuals: true });

// Índices recomendados
mascotaSchema.index({ dueño: 1 });
mascotaSchema.index({ dueño: 1, oculto: 1 });

module.exports = mongoose.model('Mascota', mascotaSchema);