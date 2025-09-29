const mongoose = require('mongoose');

class DatabaseService {
  static async conectar(uri) {
    try {
      await mongoose.connect(uri, {
        serverSelectionTimeoutMS: 5000,
        socketTimeoutMS: 45000,
        maxPoolSize: 10,
        minPoolSize: 1
      });
      console.log('Conectado a MongoDB');
      return true;
    } catch (error) {
      console.error('Error al conectar a MongoDB:', error.message);
      return false;
    }
  }

  static async desconectar() {
    try {
      await mongoose.connection.close();
      console.log('Conexión MongoDB cerrada');
    } catch (e) {
      console.error('Error cerrando conexión MongoDB:', e.message);
    }
  }

  static obtenerEstadoConexion() {
    const estados = { 0: 'desconectado', 1: 'conectado', 2: 'conectando', 3: 'desconectando' };
    return {
      estado: estados[mongoose.connection.readyState],
      numero: mongoose.connection.readyState,
      nombre: mongoose.connection.name
    };
  }

  static configurarEventos() {
    mongoose.connection.on('connected', () => console.log('Mongoose conectado'));
    mongoose.connection.on('error', err => console.error('Error Mongoose:', err.message));
    mongoose.connection.on('disconnected', () => console.log('Mongoose desconectado'));
    process.on('SIGINT', async () => { await this.desconectar(); process.exit(0); });
  }
}

module.exports = DatabaseService;