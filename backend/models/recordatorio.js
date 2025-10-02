const mongoose = require('mongoose');

const avisoSchema = new mongoose.Schema({
  tipo: { type: String, enum: ['a_la_hora', 'antes_de'], required: true },
  minutos: { type: Number, default: 0 },
  descripcion: { type: String, trim: true }
}, { _id: false });

const recordatorioSchema = new mongoose.Schema({
  usuario: { type: mongoose.Schema.Types.ObjectId, ref: 'Usuario', required: true },
  titulo: { type: String, required: true, trim: true },
  descripcion: { type: String, trim: true },
  // Categoria: permitir texto libre (UI usa "Juegos y entretenimiento", etc.)
  categoria: { type: String, trim: true, default: 'otro', maxlength: 60 },
  fechaHora: { type: Date, required: true },
  tipoRecordatorio: { type: String, enum: ['una_vez','repetir'], default: 'una_vez' },
  frecuencia: { type: String, enum: ['una_vez','diario','semanal','mensual','anual'], default: 'una_vez' },
  avisos: { type: [avisoSchema], default: [] },
  activo: { type: Boolean, default: true }
}, { timestamps: true });

recordatorioSchema.index({ usuario: 1, fechaHora: 1 });

module.exports = mongoose.model('Recordatorio', recordatorioSchema);