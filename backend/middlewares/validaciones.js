const { body, param, query, validationResult } = require('express-validator');

// Middleware para manejar errores de validación
const manejarErrores = (req, res, next) => {
  const errores = validationResult(req);
  if (!errores.isEmpty()) {
    return res.status(400).json({
      error: 'Errores de validación',
      detalles: errores.array()
    });
  }
  next();
};

// Validaciones para usuarios
const validarRegistroUsuario = [
  body('nombre')
    .notEmpty()
    .withMessage('El nombre es obligatorio')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('El nombre debe tener entre 2 y 50 caracteres'),
  
  body('apellido')
    .notEmpty()
    .withMessage('El apellido es obligatorio')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('El apellido debe tener entre 2 y 50 caracteres'),
  
  body('correo')
    .isEmail()
    .withMessage('Debe ser un correo válido')
    .normalizeEmail(),
  
  body('celular')
    .matches(/^[0-9]{10}$/)
    .withMessage('El celular debe tener 10 dígitos'),
  
  body('contraseña')
    .isLength({ min: 6 })
    .withMessage('La contraseña debe tener al menos 6 caracteres')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('La contraseña debe contener al menos una minúscula, una mayúscula y un número'),
  
  body('comoLlegaste')
    .optional()
    .trim()
    .isLength({ max: 200 })
    .withMessage('El campo "¿Cómo llegaste?" no puede exceder 200 caracteres'),
  
  manejarErrores
];

const validarLoginUsuario = [
  body('correo')
    .isEmail()
    .withMessage('Debe ser un correo válido')
    .normalizeEmail(),
  
  body('contraseña')
    .notEmpty()
    .withMessage('La contraseña es obligatoria'),
  
  manejarErrores
];

// Validaciones para mascotas
const validarMascota = [
  body('nombre')
    .notEmpty()
    .withMessage('El nombre de la mascota es obligatorio')
    .trim()
    .isLength({ min: 1, max: 30 })
    .withMessage('El nombre debe tener entre 1 y 30 caracteres'),
  
  body('sexo')
    .isIn(['macho', 'hembra'])
    .withMessage('El sexo debe ser "macho" o "hembra"'),
  
  body('raza')
    .notEmpty()
    .withMessage('La raza es obligatoria')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('La raza debe tener entre 2 y 50 caracteres'),
  
  body('fecha_nac')
    .optional()
    .isISO8601()
    .withMessage('La fecha de nacimiento debe ser válida')
    .custom(fecha => {
      if (new Date(fecha) > new Date()) {
        throw new Error('La fecha de nacimiento no puede ser futura');
      }
      return true;
    }),
  
  body('estiloVida')
    .optional()
    .isIn(['activo', 'tranquilo', 'mixto'])
    .withMessage('El estilo de vida debe ser: activo, tranquilo o mixto'),
  
  manejarErrores
];

// Validaciones para eventos
const validarEvento = [
  body('titulo')
    .notEmpty()
    .withMessage('El título del evento es obligatorio')
    .trim()
    .isLength({ min: 3, max: 100 })
    .withMessage('El título debe tener entre 3 y 100 caracteres'),
  
  body('fecha')
    .isISO8601()
    .withMessage('La fecha debe ser válida'),
  
  body('hora')
    .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .withMessage('La hora debe tener formato HH:MM (24h)'),
  
  body('tipo')
    .isIn(['veterinario', 'alimentacion', 'ejercicio', 'medicamento', 'baño', 'otro'])
    .withMessage('Tipo de evento no válido'),
  
  body('mascota')
    .isMongoId()
    .withMessage('ID de mascota no válido'),
  
  body('prioridad')
    .optional()
    .isIn(['baja', 'media', 'alta'])
    .withMessage('La prioridad debe ser: baja, media o alta'),
  
  manejarErrores
];

// Validaciones para vacunas
const validarVacuna = [
  body('nombre')
    .notEmpty()
    .withMessage('El nombre de la vacuna es obligatorio')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('El nombre debe tener entre 2 y 100 caracteres'),
  
  body('fechaAplicacion')
    .isISO8601()
    .withMessage('La fecha de aplicación debe ser válida'),
  
  body('fechaVencimiento')
    .optional()
    .isISO8601()
    .withMessage('La fecha de vencimiento debe ser válida')
    .custom((fechaVencimiento, { req }) => {
      if (fechaVencimiento && req.body.fechaAplicacion) {
        if (new Date(fechaVencimiento) <= new Date(req.body.fechaAplicacion)) {
          throw new Error('La fecha de vencimiento debe ser posterior a la fecha de aplicación');
        }
      }
      return true;
    }),
  
  body('mascota')
    .isMongoId()
    .withMessage('ID de mascota no válido'),
  
  manejarErrores
];

// Validaciones para registro de peso
const validarPeso = [
  body('peso')
    .isFloat({ min: 0.1, max: 200 })
    .withMessage('El peso debe ser un número entre 0.1 y 200 kg'),
  
  body('fecha')
    .optional()
    .isISO8601()
    .withMessage('La fecha debe ser válida')
    .custom(fecha => {
      if (fecha && new Date(fecha) > new Date()) {
        throw new Error('La fecha no puede ser futura');
      }
      return true;
    }),
  
  body('tipoRegistro')
    .optional()
    .isIn(['rutina', 'veterinario', 'enfermedad', 'otro'])
    .withMessage('Tipo de registro no válido'),
  
  body('mascota')
    .isMongoId()
    .withMessage('ID de mascota no válido'),
  
  body('observaciones')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Las observaciones no pueden exceder 500 caracteres'),
  
  manejarErrores
];

// Validaciones para fotos
const validarFoto = [
  body('url')
    .isURL()
    .withMessage('La URL de la foto debe ser válida'),
  
  body('titulo')
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage('El título no puede exceder 100 caracteres'),
  
  body('descripcion')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('La descripción no puede exceder 500 caracteres'),
  
  body('mascota')
    .isMongoId()
    .withMessage('ID de mascota no válido'),
  
  body('etiquetas')
    .optional()
    .isArray()
    .withMessage('Las etiquetas deben ser un array'),
  
  body('etiquetas.*')
    .optional()
    .trim()
    .isLength({ min: 1, max: 30 })
    .withMessage('Cada etiqueta debe tener entre 1 y 30 caracteres'),
  
  manejarErrores
];

// Validaciones para parámetros de ID
const validarId = [
  param('id').isMongoId().withMessage('ID no válido'),
  manejarErrores
];

const validarMascotaId = [
  param('mascotaId').isMongoId().withMessage('ID de mascota no válido'),
  manejarErrores
];

// Validaciones para query parameters comunes
const validarFechas = [
  query('fechaInicio')
    .optional()
    .isISO8601()
    .withMessage('Fecha de inicio no válida'),
  
  query('fechaFin')
    .optional()
    .isISO8601()
    .withMessage('Fecha de fin no válida'),
  
  manejarErrores
];

module.exports = {
  manejarErrores,
  validarRegistroUsuario,
  validarLoginUsuario,
  validarMascota,
  validarEvento,
  validarVacuna,
  validarPeso,
  validarFoto,
  validarId,
  validarMascotaId,
  validarFechas
};