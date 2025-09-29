const nodemailer = require('nodemailer');

// Cache del transporter
let transporter;
let usandoEthereal = false;

async function crearTransporter() {
  if (transporter) return transporter;

  const { EMAIL_HOST, EMAIL_PORT, EMAIL_USER, EMAIL_PASSWORD, EMAIL_SECURE, EMAIL_SERVICE } = process.env;

  if (!EMAIL_USER || !EMAIL_PASSWORD) {
    // Intentar crear una cuenta de prueba Ethereal automáticamente para desarrollo
    try {
      const testAccount = await nodemailer.createTestAccount();
      usandoEthereal = true;
      transporter = nodemailer.createTransport({
        host: testAccount.smtp.host,
        port: testAccount.smtp.port,
        secure: testAccount.smtp.secure,
        auth: { user: testAccount.user, pass: testAccount.pass }
      });
      console.warn('⚠️  No hay credenciales de correo reales. Usando cuenta de prueba Ethereal.');
      console.warn('    Los correos SOLO estarán disponibles mediante la URL de vista previa (no llegan a bandeja real).');
      return transporter;
    } catch (e) {
      console.warn('⚠️  No se pudo crear cuenta Ethereal:', e.message);
      return null;
    }
  }

  let baseConfig;
  if (EMAIL_SERVICE) {
    baseConfig = { service: EMAIL_SERVICE };
  } else {
    baseConfig = { host: EMAIL_HOST, port: Number(EMAIL_PORT) || 587 };
  }

  const tlsOptions = {};
  if (process.env.EMAIL_TLS_REJECT_UNAUTHORIZED === '0') {
    tlsOptions.rejectUnauthorized = false; // Úsalo solo en desarrollo si tu proxy corporativo inyecta certificados.
    console.warn('⚠️  TLS rejectUnauthorized=FALSE (no recomendado en producción)');
  }

  const enableDebug = process.env.EMAIL_SMTP_DEBUG === '1';
  transporter = nodemailer.createTransport({
    ...baseConfig,
    secure: EMAIL_SECURE === '1' || (baseConfig.port === 465),
    auth: { user: EMAIL_USER, pass: EMAIL_PASSWORD },
    tls: Object.keys(tlsOptions).length ? tlsOptions : undefined,
    logger: enableDebug,
    debug: enableDebug
  });
  console.log('✉️  Transporter SMTP creado con configuración:', {
    service: EMAIL_SERVICE || undefined,
    host: baseConfig.host,
    port: baseConfig.port,
    secure: EMAIL_SECURE === '1' || (baseConfig.port === 465),
    tlsRelaxed: !!tlsOptions.rejectUnauthorized
  });
  return transporter;
}

async function verificarConexion() {
  const t = await crearTransporter();
  if (!t) return { ok: false, motivo: 'no_config' };
  try {
    await t.verify();
    return { ok: true };
  } catch (e) {
    console.error('❌ Falló verificación SMTP:', e.message);
    return { ok: false, motivo: 'verify_fail', error: e.message };
  }
}

async function enviarCodigoRecuperacion({ correo, codigo }) {
  const t = await crearTransporter();
  if (!t) {
    return { enviado: false, motivo: 'credenciales no configuradas' };
  }

  const mailOptions = {
    from: `My Best Friend <${process.env.EMAIL_USER}>`,
    to: correo,
    subject: 'Código de recuperación de contraseña',
    text: `Tu código de recuperación es: ${codigo}. Expira en 15 minutos.`,
    html: `<p>Has solicitado recuperar tu contraseña.</p>
           <p><strong>Código:</strong> <span style="font-size:20px;letter-spacing:4px;">${codigo}</span></p>
           <p>Expira en 15 minutos.</p>
           <p>Si no solicitaste este código, ignora este correo.</p>`
  };
  try {
    const info = await t.sendMail(mailOptions);
    const previewUrl = (usandoEthereal && nodemailer.getTestMessageUrl(info)) || undefined;
    if (previewUrl) {
      console.log('📨 Vista previa (Ethereal):', previewUrl);
    }
    return { enviado: true, messageId: info.messageId, previewUrl, ethereal: usandoEthereal };
  } catch (e) {
    console.error('❌ Error enviando correo:', e.message);
    return { enviado: false, motivo: 'error_envio', error: e.message };
  }
}

module.exports = { enviarCodigoRecuperacion, verificarConexion };
