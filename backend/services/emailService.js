const nodemailer = require('nodemailer');

let transporter;

function buildTransporter() {
  if (transporter) return transporter;
  const { EMAIL_HOST, EMAIL_PORT, EMAIL_USER, EMAIL_PASSWORD, EMAIL_SECURE, EMAIL_SERVICE, EMAIL_TLS_REJECT_UNAUTHORIZED } = process.env;
  if (!EMAIL_USER || !EMAIL_PASSWORD) {
    console.warn('Email deshabilitado: faltan EMAIL_USER / EMAIL_PASSWORD');
    return null;
  }
  const base = EMAIL_SERVICE ? { service: EMAIL_SERVICE } : { host: EMAIL_HOST, port: Number(EMAIL_PORT) || 587 };
  const tls = (EMAIL_TLS_REJECT_UNAUTHORIZED === '0') ? { rejectUnauthorized: false } : undefined;
  transporter = nodemailer.createTransport({
    ...base,
    secure: EMAIL_SECURE === '1' || base.port === 465,
    auth: { user: EMAIL_USER, pass: EMAIL_PASSWORD },
    tls
  });
  return transporter;
}

async function enviarCodigoRecuperacion({ correo, codigo }) {
  const t = buildTransporter();
  if (!t) return { enviado: false, motivo: 'no_config' };
  try {
    const info = await t.sendMail({
      from: `My Best Friend <${process.env.EMAIL_USER}>`,
      to: correo,
      subject: 'Código de recuperación de contraseña',
      text: `Tu código de recuperación es: ${codigo}. Expira en 15 minutos.`,
      html: `<p>Has solicitado recuperar tu contraseña.</p>
             <p><strong>Código:</strong> <span style="font-size:20px;letter-spacing:4px;">${codigo}</span></p>
             <p>Expira en 15 minutos.</p>
             <p>Si no solicitaste este código, ignora este correo.</p>`
    });
    return { enviado: true, messageId: info.messageId };
  } catch (e) {
    return { enviado: false, motivo: 'error_envio', error: e.message };
  }
}

module.exports = { enviarCodigoRecuperacion };
