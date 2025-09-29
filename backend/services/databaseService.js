const mongoose = require('mongoose');

class DatabaseService {
  static async conectar(uri) {
    try {
      await mongoose.connect(uri, {
        serverSelectionTimeoutMS: 5000, // Timeout después de 5s
        socketTimeoutMS: 45000, // Cerrar sockets después de 45s de inactividad
        maxPoolSize: 10, // Máximo 10 conexiones en el pool
        minPoolSize: 5   // Mínimo 5 conexiones en el pool
      });
      
      console.log('✅ Conectado a MongoDB Atlas correctamente');
      return true;
    } catch (error) {
      console.error('❌ Error al conectar a MongoDB:', error.message);
      if (error.reason && error.reason.code === 'ENOTFOUND') {
        console.error('🔎 Posible problema DNS. Verifica que tu conexión a internet esté activa.');
      }
      // Información adicional para diagnósticos
      console.error('📌 URI usada:', uri ? uri.split('@').pop() : 'No definida');
      console.error('🛠  Node version:', process.version);
      console.error('🕒 Hora local:', new Date().toISOString());
      return false;
    }
  }

  static async desconectar() {
    try {
      await mongoose.connection.close();
      console.log('✅ Conexión a MongoDB cerrada correctamente');
      return true;
    } catch (error) {
      console.error('❌ Error al cerrar conexión:', error.message);
      return false;
    }
  }

  static obtenerEstadoConexion() {
    const estados = {
      0: 'desconectado',
      1: 'conectado',
      2: 'conectando',
      3: 'desconectando'
    };
    
    return {
      estado: estados[mongoose.connection.readyState],
      numeroEstado: mongoose.connection.readyState,
      host: mongoose.connection.host,
      nombre: mongoose.connection.name,
      puerto: mongoose.connection.port
    };
  }

  static configurarEventos() {
    mongoose.connection.on('connected', () => {
      console.log('🔗 Mongoose conectado a MongoDB');
    });

    mongoose.connection.on('error', (error) => {
      console.error('❌ Error en la conexión de Mongoose:', error);
    });

    mongoose.connection.on('disconnected', () => {
      console.log('🔌 Mongoose desconectado de MongoDB');
    });

    // Capturar señales de terminación para cerrar la conexión
    process.on('SIGINT', async () => {
      await this.desconectar();
      console.log('🚪 Aplicación terminada correctamente');
      process.exit(0);
    });
  }

  // Métodos de utilidad para manejo de transacciones
  static async iniciarTransaccion() {
    const session = await mongoose.startSession();
    session.startTransaction();
    return session;
  }

  static async confirmarTransaccion(session) {
    try {
      await session.commitTransaction();
      session.endSession();
      return true;
    } catch (error) {
      await session.abortTransaction();
      session.endSession();
      throw error;
    }
  }

  static async cancelarTransaccion(session) {
    try {
      await session.abortTransaction();
      session.endSession();
      return true;
    } catch (error) {
      console.error('Error al cancelar transacción:', error);
      return false;
    }
  }

  // Método para obtener estadísticas de la base de datos
  static async obtenerEstadisticas() {
    try {
      const db = mongoose.connection.db;
      const stats = await db.stats();
      
      return {
        baseDatos: db.databaseName,
        colecciones: stats.collections,
        documentos: stats.objects,
        tamañoEnBytes: stats.dataSize,
        tamañoIndicesBytes: stats.indexSize,
        tamañoPromedioDocumento: stats.avgObjSize
      };
    } catch (error) {
      console.error('Error al obtener estadísticas:', error);
      return null;
    }
  }

  // Método para crear respaldos de datos específicos
  static async crearRespaldoUsuario(usuarioId) {
    const session = await this.iniciarTransaccion();
    
    try {
      const Usuario = require('../models/usuario');
      const Mascota = require('../models/mascota');
      const Evento = require('../models/evento');
      const Vacuna = require('../models/vacuna');
      const RegistroPeso = require('../models/registroPeso');
      const Foto = require('../models/foto');

      const usuario = await Usuario.findById(usuarioId).session(session);
      if (!usuario) {
        throw new Error('Usuario no encontrado');
      }

      const mascotas = await Mascota.find({ dueño: usuarioId }).session(session);
      const mascotasIds = mascotas.map(m => m._id);

      const eventos = await Evento.find({ usuario: usuarioId }).session(session);
      const vacunas = await Vacuna.find({ usuario: usuarioId }).session(session);
      const registrosPeso = await RegistroPeso.find({ usuario: usuarioId }).session(session);
      const fotos = await Foto.find({ usuario: usuarioId }).session(session);

      const respaldo = {
        usuario: usuario.toJSON(),
        mascotas: mascotas.map(m => m.toJSON()),
        eventos: eventos.map(e => e.toJSON()),
        vacunas: vacunas.map(v => v.toJSON()),
        registrosPeso: registrosPeso.map(r => r.toJSON()),
        fotos: fotos.map(f => f.toJSON()),
        fechaRespaldo: new Date(),
        version: '1.0'
      };

      await this.confirmarTransaccion(session);
      return respaldo;

    } catch (error) {
      await this.cancelarTransaccion(session);
      throw error;
    }
  }
}

module.exports = DatabaseService;