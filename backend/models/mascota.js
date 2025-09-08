const mongoose = require('mongoose');

const mascotaSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: true,
    trim: true
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

module.exports = mongoose.model('Mascota', mascotaSchema);