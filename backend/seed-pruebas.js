/**
 * seed-pruebas.js — Datos de laboratorio para Sprint 2
 * Ejecutar con: node seed-pruebas.js
 *
 * Crea:
 *  - 2 usuarios de prueba: admin_qa y viewer_qa
 *  - 10 mascotas de prueba con casos borde
 */

require('dotenv').config();
const { MongoClient, ObjectId } = require('mongodb');
const crypto = require('crypto');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017';
const DATABASE_NAME = process.env.DATABASE_NAME || 'My-Best-Friend';

const TOKEN_ADMIN  = crypto.randomBytes(48).toString('hex');
const TOKEN_VIEWER = crypto.randomBytes(48).toString('hex');

async function seed() {
  const client = new MongoClient(MONGODB_URI);
  await client.connect();
  const db = client.db(DATABASE_NAME);

  // ── 1. USUARIOS DE PRUEBA ────────────────────────────────────────────────
  console.log('\n📦 Insertando usuarios de prueba...');

  // Eliminar seeds anteriores para idempotencia
  await db.collection('usuarios').deleteMany({
    correo: { $in: ['admin_qa@lab.test', 'viewer_qa@lab.test'] }
  });

  // Roles válidos del esquema: "dueno" | "cuidador"
  // Para el Sprint 2 usamos dueno=rol privilegiado, cuidador=rol restringido
  const adminResult = await db.collection('usuarios').insertOne({
    nombre:       'Admin',
    apellido:     'QA',
    correo:       'admin_qa@lab.test',
    password:     'Lab1234!',          // clave de laboratorio, NO producción
    celular:      '+570000000001',
    fotoPerfil:   '',
    direccion:    'Lab QA',
    rol:          'dueno',             // rol privilegiado del sistema
    authToken:    TOKEN_ADMIN,
    fcmToken:     '',
    fechaCreacion: new Date(),
    ultimoAcceso:  new Date()
  });

  const viewerResult = await db.collection('usuarios').insertOne({
    nombre:       'Viewer',
    apellido:     'QA',
    correo:       'viewer_qa@lab.test',
    password:     'Lab1234!',
    celular:      '+570000000002',
    fotoPerfil:   '',
    direccion:    'Lab QA',
    rol:          'cuidador',          // rol restringido del sistema
    authToken:    TOKEN_VIEWER,
    fcmToken:     '',
    fechaCreacion: new Date(),
    ultimoAcceso:  new Date()
  });

  const adminId  = adminResult.insertedId;
  const viewerId = viewerResult.insertedId;

  console.log(`  ✅ admin_qa  → _id: ${adminId}  | token: ${TOKEN_ADMIN}`);
  console.log(`  ✅ viewer_qa → _id: ${viewerId} | token: ${TOKEN_VIEWER}`);

  // ── 2. MASCOTAS DE PRUEBA (casos variados + borde) ───────────────────────
  console.log('\n📦 Insertando mascotas de prueba...');

  await db.collection('mascotas').deleteMany({ nombre: /^QA_/ });

  // Enums válidos del esquema:
  //   situacion: "Acabo de tener un perro" | "Ya conozco bien a mi perro"
  //   sexo:      "Macho" | "Hembra"
  //   rol:       "Dueño" | "Cuidador"
  const mascotas = [
    // Casos normales
    { nombre: 'QA_Labrador',   raza: 'Labrador Retriever', sexo: 'Macho',  situacion: 'Ya conozco bien a mi perro',  rol: 'Dueño',     seguimiento: true,  coCuidado: false, oculto: false, estiloVida: ['Activo', 'Familiar'],   userId: adminId,  fechaCreacion: new Date() },
    { nombre: 'QA_Siamesa',    raza: 'Siamés',             sexo: 'Hembra', situacion: 'Acabo de tener un perro',     rol: 'Dueño',     seguimiento: false, coCuidado: false, oculto: false, estiloVida: ['Tranquilo'],             userId: adminId,  fechaCreacion: new Date() },
    { nombre: 'QA_Bulldog',    raza: 'Bulldog Francés',    sexo: 'Macho',  situacion: 'Ya conozco bien a mi perro',  rol: 'Cuidador',  seguimiento: true,  coCuidado: true,  oculto: false, estiloVida: ['Jugueton'],              userId: viewerId, fechaCreacion: new Date() },
    { nombre: 'QA_Persa',      raza: 'Persa',              sexo: 'Hembra', situacion: 'Acabo de tener un perro',     rol: 'Cuidador',  seguimiento: false, coCuidado: false, oculto: false, estiloVida: ['Tranquilo', 'Familiar'], userId: viewerId, fechaCreacion: new Date() },
    // Caso con cumpleaños explícito
    { nombre: 'QA_ConCumple',  raza: 'Golden Retriever',   sexo: 'Macho',  situacion: 'Ya conozco bien a mi perro',  rol: 'Dueño',     seguimiento: true,  coCuidado: false, oculto: false, estiloVida: ['Activo'], cumpleanos: new Date('2021-03-10'), userId: adminId, fechaCreacion: new Date() },
    // Caso: mascota oculta → simula borrado lógico
    { nombre: 'QA_Oculta',     raza: 'Poodle',             sexo: 'Hembra', situacion: 'Ya conozco bien a mi perro',  rol: 'Dueño',     seguimiento: false, coCuidado: false, oculto: true,  estiloVida: [],                       userId: adminId,  fechaCreacion: new Date() },
    // Caso borde: nombre de 1 carácter
    { nombre: 'Q',             raza: 'Mestizo',             sexo: 'Macho',  situacion: 'Acabo de tener un perro',     rol: 'Dueño',     seguimiento: false, coCuidado: false, oculto: false, estiloVida: [],                       userId: adminId,  fechaCreacion: new Date() },
    // Caso borde: nombre de 100 caracteres
    { nombre: 'Q'.repeat(100), raza: 'Mestizo',             sexo: 'Hembra', situacion: 'Acabo de tener un perro',     rol: 'Dueño',     seguimiento: false, coCuidado: false, oculto: false, estiloVida: [],                       userId: adminId,  fechaCreacion: new Date() },
    // Caso: co-cuidado true
    { nombre: 'QA_CoCuidado',  raza: 'Beagle',              sexo: 'Macho',  situacion: 'Ya conozco bien a mi perro',  rol: 'Cuidador',  seguimiento: true,  coCuidado: true,  oculto: false, estiloVida: ['Activo', 'Jugueton'],   userId: viewerId, fechaCreacion: new Date() },
    // Caso: sin estiloVida
    { nombre: 'QA_SinEstilo',  raza: 'Schnauzer',           sexo: 'Hembra', situacion: 'Acabo de tener un perro',     rol: 'Dueño',     seguimiento: false, coCuidado: false, oculto: false, estiloVida: [],                       userId: adminId,  fechaCreacion: new Date() },
  ];

  const mascResult = await db.collection('mascotas').insertMany(mascotas);
  console.log(`  ✅ ${Object.keys(mascResult.insertedIds).length} mascotas insertadas`);

  // ── RESUMEN ──────────────────────────────────────────────────────────────
  console.log('\n══════════════════════════════════════════════════════════');
  console.log('  CUENTAS DE LABORATORIO (Sprint 2)');
  console.log('══════════════════════════════════════════════════════════');
  console.log(`  ROL DUEÑO (privilegiado)`);
  console.log(`    correo  : admin_qa@lab.test`);
  console.log(`    password: Lab1234!`);
  console.log(`    _id     : ${adminId}`);
  console.log(`    token   : ${TOKEN_ADMIN}`);
  console.log(`\n  ROL CUIDADOR (restringido)`);
  console.log(`    correo  : viewer_qa@lab.test`);
  console.log(`    password: Lab1234!`);
  console.log(`    _id     : ${viewerId}`);
  console.log(`    token   : ${TOKEN_VIEWER}`);
  console.log('══════════════════════════════════════════════════════════');
  console.log('\n✅ Seed completado. Guarda los tokens para las pruebas.\n');

  await client.close();
}

seed().catch(err => { console.error('❌ Error en seed:', err.message); process.exit(1); });
