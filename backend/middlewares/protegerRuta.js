const jwt = require('jsonwebtoken');
const Usuario = require('../models/usuario');

const protegerRuta = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token no proporcionado' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.usuario = await Usuario.findById(decoded.id).select('-contraseña');
    if (req.usuario) {
      req.usuario.ultimoAcceso = new Date();
      try { await req.usuario.save(); } catch (e) { /* ignorar errores menores */ }
    }
    next();
  } catch (error) {
    res.status(401).json({ error: 'Token inválido' });
  }
};

module.exports = protegerRuta;