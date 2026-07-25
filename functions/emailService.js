const nodemailer = require('nodemailer');
const admin = require('firebase-admin');

let transporter = null;

const getTransporter = async () => {
  if (transporter) return transporter;

  const configSnap = await admin.firestore().doc('settings/email').get();
  const config = configSnap.data();
  if (!config || !config.enabled) return null;

  transporter = nodemailer.createTransport({
    host: config.host,
    port: Number(config.port),
    secure: config.secure,
    auth: { user: config.user, pass: config.pass }
  });

  return transporter;
};

const getFromAddress = async () => {
  const configSnap = await admin.firestore().doc('settings/email').get();
  const config = configSnap.data();
  return {
    from: `"${config?.fromName || 'Tatti Til'}" <${config?.fromEmail || 'noreply@tattitil.kz'}>`
  };
};

const wrapTemplate = (content, lang = 'kk') => {
  const footer = lang === 'ru'
    ? 'Tatti Til — Интерактивная платформа обучения'
    : 'Tatti Til — Интерактивті білім беру платформасы';

  const unsubscribe = lang === 'ru'
    ? 'Отписаться от уведомлений'
    : 'Хабарландырулардан бас тарту';

  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="margin:0;padding:0;font-family:Arial,sans-serif;background:#f6f8fc;">
  <div style="max-width:520px;margin:40px auto;background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.06);">
    <div style="background:linear-gradient(135deg,#4f46e5,#7c3aed);padding:28px 32px;text-align:center;">
      <h1 style="color:#fff;font-size:22px;margin:0;font-weight:700;">Tatti Til</h1>
    </div>
    <div style="padding:32px;">
      ${content}
    </div>
    <div style="padding:20px 32px;text-align:center;border-top:1px solid #e5e7eb;">
      <p style="color:#9ca3af;font-size:12px;margin:0 0 8px;">${footer}</p>
      <p style="color:#c4c8d4;font-size:11px;margin:0;">© ${new Date().getFullYear()} Tatti Til LMS. ${unsubscribe}</p>
    </div>
  </div>
</body>
</html>`;
};

const templates = {
  welcome: {
    kk: (name) => ({
      subject: 'Tatti Til-ge Қош келдіңіз!',
      html: wrapTemplate(`
        <h2 style="color:#1f2937;font-size:20px;margin:0 0 16px;">Сәлеметсіз бе, ${name}! 👋</h2>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 12px;">Tatti Til платформасына тіркелгеніңіз үшін рахмет!</p>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 24px;">Әлемдік деңгейдегі интерактивті курстарды бастауға дайынсыз ба?</p>
        <a href="https://tattitil.kz/courses" style="display:inline-block;background:#4f46e5;color:#fff;padding:14px 32px;border-radius:10px;text-decoration:none;font-weight:700;font-size:15px;">Курстарды Қарау →</a>
      `, 'kk')
    }),
    ru: (name) => ({
      subject: 'Добро пожаловать в Tatti Til!',
      html: wrapTemplate(`
        <h2 style="color:#1f2937;font-size:20px;margin:0 0 16px;">Здравствуйте, ${name}! 👋</h2>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 12px;">Спасибо за регистрацию на платформе Tatti Til!</p>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 24px;">Готовы начать изучение интерактивных курсов мирового уровня?</p>
        <a href="https://tattitil.kz/courses" style="display:inline-block;background:#4f46e5;color:#fff;padding:14px 32px;border-radius:10px;text-decoration:none;font-weight:700;font-size:15px;">Посмотреть курсы →</a>
      `, 'ru')
    })
  },

  enrollment: {
    kk: (name, courseName) => ({
      subject: `Сіз «${courseName}» курсына тіркелдіңіз`,
      html: wrapTemplate(`
        <h2 style="color:#1f2937;font-size:20px;margin:0 0 16px;">Тіркелу сәтті өтті! 🎉</h2>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 12px;">Сәлеметсіз бе, ${name}!</p>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 8px;">Сіз <strong style="color:#4f46e5;">${courseName}</strong> курсына сәтті тіркелдіңіз.</p>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 24px;">Бірінші сабақты бастауға дайынсыз ба?</p>
        <a href="https://tattitil.kz/my-courses" style="display:inline-block;background:#10b981;color:#fff;padding:14px 32px;border-radius:10px;text-decoration:none;font-weight:700;font-size:15px;">Сабақты Бастау →</a>
      `, 'kk')
    }),
    ru: (name, courseName) => ({
      subject: `Вы записались на курс «${courseName}»`,
      html: wrapTemplate(`
        <h2 style="color:#1f2937;font-size:20px;margin:0 0 16px;">Успешная запись! 🎉</h2>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 12px;">Здравствуйте, ${name}!</p>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 8px;">Вы успешно записались на курс <strong style="color:#4f46e5;">${courseName}</strong>.</p>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 24px;">Готовы начать первый урок?</p>
        <a href="https://tattitil.kz/my-courses" style="display:inline-block;background:#10b981;color:#fff;padding:14px 32px;border-radius:10px;text-decoration:none;font-weight:700;font-size:15px;">Начать урок →</a>
      `, 'ru')
    })
  },

  course_complete: {
    kk: (name, courseName) => ({
      subject: `Құттықтаймыз! «${courseName}» курсы аяқталды!`,
      html: wrapTemplate(`
        <h2 style="color:#1f2937;font-size:20px;margin:0 0 16px;">Құттықтаймыз! 🏆</h2>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 12px;">Сәлеметсіз бе, ${name}!</p>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 8px;">Сіз <strong style="color:#4f46e5;">${courseName}</strong> курсын сәтті аяқтадыңыз!</p>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 24px;">Сертификатыңызды жүктеп алыңыз.</p>
        <a href="https://tattitil.kz/my-courses" style="display:inline-block;background:#f59e0b;color:#fff;padding:14px 32px;border-radius:10px;text-decoration:none;font-weight:700;font-size:15px;">Сертификатты Жүктеу →</a>
      `, 'kk')
    }),
    ru: (name, courseName) => ({
      subject: `Поздравляем! Курс «${courseName}» завершён!`,
      html: wrapTemplate(`
        <h2 style="color:#1f2937;font-size:20px;margin:0 0 16px;">Поздравляем! 🏆</h2>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 12px;">Здравствуйте, ${name}!</p>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 8px;">Вы успешно завершили курс <strong style="color:#4f46e5;">${courseName}</strong>!</p>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 24px;">Скачайте свой сертификат.</p>
        <a href="https://tattitil.kz/my-courses" style="display:inline-block;background:#f59e0b;color:#fff;padding:14px 32px;border-radius:10px;text-decoration:none;font-weight:700;font-size:15px;">Скачать сертификат →</a>
      `, 'ru')
    })
  },

  lesson_complete: {
    kk: (name, courseName, lessonName, completedCount, totalCount) => ({
      subject: `Сабақ аяқталды! (${completedCount}/${totalCount})`,
      html: wrapTemplate(`
        <h2 style="color:#1f2937;font-size:20px;margin:0 0 16px;">Жақсы жұмыс! ⭐</h2>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 12px;">Сәлеметсіз бе, ${name}!</p>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 8px;">Сіз <strong>«${lessonName}»</strong> сабағын аяқтадыңыз.</p>
        <div style="background:#f0fdf4;border-radius:10px;padding:16px;margin:0 0 16px;">
          <p style="color:#166534;font-size:14px;margin:0;font-weight:600;">${courseName}</p>
          <div style="background:#dcfce7;border-radius:99px;height:8px;margin:10px 0 6px;overflow:hidden;">
            <div style="background:#10b981;height:100%;width:${Math.round((completedCount/totalCount)*100)}%;border-radius:99px;"></div>
          </div>
          <p style="color:#16a34a;font-size:12px;margin:0;">${completedCount} / ${totalCount} сабақ аяқталды</p>
        </div>
        <a href="https://tattitil.kz/my-courses" style="display:inline-block;background:#4f46e5;color:#fff;padding:14px 32px;border-radius:10px;text-decoration:none;font-weight:700;font-size:15px;">Келесі Сабаққа →</a>
      `, 'kk')
    }),
    ru: (name, courseName, lessonName, completedCount, totalCount) => ({
      subject: `Урок пройден! (${completedCount}/${totalCount})`,
      html: wrapTemplate(`
        <h2 style="color:#1f2937;font-size:20px;margin:0 0 16px;">Отличная работа! ⭐</h2>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 12px;">Здравствуйте, ${name}!</p>
        <p style="color:#4b5563;font-size:15px;line-height:1.7;margin:0 0 8px;">Вы завершили урок <strong>«${lessonName}»</strong>.</p>
        <div style="background:#f0fdf4;border-radius:10px;padding:16px;margin:0 0 16px;">
          <p style="color:#166534;font-size:14px;margin:0;font-weight:600;">${courseName}</p>
          <div style="background:#dcfce7;border-radius:99px;height:8px;margin:10px 0 6px;overflow:hidden;">
            <div style="background:#10b981;height:100%;width:${Math.round((completedCount/totalCount)*100)}%;border-radius:99px;"></div>
          </div>
          <p style="color:#16a34a;font-size:12px;margin:0;">${completedCount} / ${totalCount} уроков пройдено</p>
        </div>
        <a href="https://tattitil.kz/my-courses" style="display:inline-block;background:#4f46e5;color:#fff;padding:14px 32px;border-radius:10px;text-decoration:none;font-weight:700;font-size:15px;">К следующему уроку →</a>
      `, 'ru')
    })
  }
};

const sendEmail = async (to, templateName, lang = 'kk', ...args) => {
  const transport = await getTransporter();
  if (!transport) {
    console.error('SMTP not configured');
    return false;
  }

  const template = templates[templateName];
  if (!template) {
    console.error(`Template '${templateName}' not found`);
    return false;
  }

  const langTemplate = template[lang] || template.kk;
  const { subject, html } = langTemplate(...args);
  const from = await.getFromAddress();

  try {
    await transport.sendMail({ ...from, to, subject, html });

    await admin.firestore().collection('email_logs').add({
      to,
      template: templateName,
      lang,
      subject,
      status: 'sent',
      sent_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Email sent: ${templateName} to ${to}`);
    return true;
  } catch (err) {
    console.error(`Email failed: ${templateName} to ${to}`, err);

    await admin.firestore().collection('email_logs').add({
      to,
      template: templateName,
      lang,
      subject,
      status: 'failed',
      error: err.message,
      sent_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    return false;
  }
};

module.exports = { sendEmail, templates };
