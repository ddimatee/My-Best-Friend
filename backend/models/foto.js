const mongoose = require('mongoose');

const fotoSchema = new mongoose.Schema({
  url: {
    type: String,
    required: true
  },
  titulo: {
    type: String,
    trim: true,
    default: ''
  },
  descripcion: {
    type: String,
    trim: true,
    default: ''
  },
  fecha: {
    type: Date,
    default: Date.now
  },
  ubicacion: {
    type: String,
    trim: true
  },
  etiquetas: [{
    type: String,
    trim: true
  }],
  esPortada: {
    type: Boolean,
    default: false
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

// Solo una foto puede ser portada por mascota
fotoSchema.pre('save', async function(next) {
  if (this.esPortada) {
    await mongoose.model('Foto').updateMany(
      { mascota: this.mascota, _id: { $ne: this._id } },
      { esPortada: false }
    );
  }
  next();
});

module.exports = mongoose.model('Foto', fotoSchema);