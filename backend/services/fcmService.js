// Servicio sencillo para enviar notificaciones FCM usando HTTP v1 o legacy.
// Para simplificar se usa la API legacy con la clave del servidor en FCM_SERVER_KEY.
// En producción migra a HTTP v1 con servicio google.
const fetch = require('node-fetch');

async function enviarNotificacionFCM({ title, body, token, data = {}, topic }) {
  const serverKey = process.env.FCM_SERVER_KEY;
  if (!serverKey) {
    console.warn('⚠️  FCM_SERVER_KEY no configurado, no se envía push');
    return { enviado: false, motivo: 'no_server_key' };
  }
  const payload = {
    notification: { title, body },
    data,
  };
  if (token) payload.to = token; else if (topic) payload.to = `/topics/${topic}`;
  else return { enviado: false, motivo: 'sin_destino' };
  try {
    const resp = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${serverKey}`
      },
      body: JSON.stringify(payload)
    });
    const json = await resp.json().catch(()=>({}));
    if (resp.ok) return { enviado: true, respuesta: json };
    return { enviado: false, status: resp.status, respuesta: json };
  } catch (e) {
    return { enviado: false, error: e.message };
  }
}

module.exports = { enviarNotificacionFCM };
