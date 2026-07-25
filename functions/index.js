const functions = require('firebase-functions');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');
const { sendEmail } = require('./emailService');

admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();

// --- CUSTOM CLAIMS: Role өзгергенде token жаңарту ---
exports.onUserRoleChanged = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const userId = context.params.userId;
    const before = change.before.data();
    const after = change.after.data();

    const beforeRole = JSON.stringify(before.role || []);
    const afterRole = JSON.stringify(after.role || []);

    if (beforeRole === afterRole) return null;

    const customClaims = {
      admin: after.role && after.role.includes('admin'),
      author: after.role && after.role.includes('author'),
    };

    await admin.auth().setCustomUserClaims(userId, customClaims);

    await change.after.ref.update({
      tokenClaimsUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Claims updated for ${userId}:`, customClaims);
    return null;
  });

// --- CUSTOM CLAIMS: Жаңа пользователь тіркелгенде ---
exports.onUserCreated = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;
    const data = snap.data();

    const customClaims = {
      admin: data.role && data.role.includes('admin'),
      author: data.role && data.role.includes('author'),
    };

    await admin.auth().setCustomUserClaims(userId, customClaims);
    console.log(`Claims set for new user ${userId}:`, customClaims);

    // Welcome email жіберу
    if (data.email) {
      const lang = data.language || 'kk';
      await sendEmail(data.email, 'welcome', lang, data.name || 'Қолданушы');
    }

    return null;
  });

// --- TEST EMAIL ---
exports.sendEmail = functions.firestore
  .document('settings/email_test')
  .onCreate(async (snap) => {
    const data = snap.data();
    if (data.action !== 'test') return;

    const configSnap = await admin.firestore().doc('settings/email').get();
    const config = configSnap.data();
    if (!config || !config.enabled) {
      console.error('SMTP not configured');
      await snap.ref.delete();
      return;
    }

    const nodemailer = require('nodemailer');
    const transporter = nodemailer.createTransport({
      host: config.host,
      port: Number(config.port),
      secure: config.secure,
      auth: { user: config.user, pass: config.pass }
    });

    try {
      await transporter.sendMail({
        from: `"${config.fromName || 'Tatti Til'}" <${config.fromEmail}>`,
        to: data.to || config.fromEmail,
        subject: 'Tatti Til — Тест хабарландыруы',
        html: `
          <div style="font-family: Arial, sans-serif; padding: 24px; background: #f8fafc;">
            <div style="max-width: 480px; margin: 0 auto; background: white; border-radius: 12px; padding: 32px; box-shadow: 0 2px 8px rgba(0,0,0,0.06);">
              <h2 style="color: #4f46e5; margin: 0 0 12px;">Tatti Til LMS</h2>
              <p style="color: #374151; line-height: 1.6; margin: 0 0 8px;">Бұл — SMTP баптауларының дұрыс екенін тексеруге арналған тест хабарландыруы.</p>
              <p style="color: #6b7280; font-size: 0.88rem;">Егер бұл хатты көріп отырсаңыз, SMTP дұрыс жұмыс істейді.</p>
              <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 20px 0;" />
              <p style="color: #9ca3af; font-size: 0.78rem; margin: 0;">Tatti Til Interactive Learning Platform</p>
            </div>
          </div>
        `
      });
      console.log('Test email sent successfully');
    } catch (err) {
      console.error('Failed to send test email:', err);
    }

    await snap.ref.delete();
  });

// --- ENROLLMENT EMAIL: Курста тіркелгенде ---
exports.onEnrollment = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const userId = context.params.userId;
    const before = change.before.data();
    const after = change.after.data();

    const beforeEnrolled = before.enrolled || [];
    const afterEnrolled = after.enrolled || [];

    if (afterEnrolled.length <= beforeEnrolled.length) return null;

    const newCourseIds = afterEnrolled.filter(id => !beforeEnrolled.includes(id));
    if (newCourseIds.length === 0) return null;

    const userEmail = after.email;
    const userName = after.name || 'Қолданушы';
    const lang = after.language || 'kk';

    if (!userEmail) return null;

    for (const courseId of newCourseIds) {
      try {
        const courseSnap = await admin.firestore().doc(`courses/${courseId}`).get();
        const courseData = courseSnap.data();
        if (courseData) {
          await sendEmail(userEmail, 'enrollment', lang, userName, courseData.name);
        }
      } catch (err) {
        console.error(`Enrollment email failed for course ${courseId}:`, err);
      }
    }

    return null;
  });

// --- LESSON COMPLETE EMAIL: Сабақ аяқтағанда ---
exports.onLessonProgress = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const userId = context.params.userId;
    const before = change.before.data();
    const after = change.after.data();

    const beforeLessons = before.completed_lessons || [];
    const afterLessons = after.completed_lessons || [];

    if (afterLessons.length <= beforeLessons.length) return null;

    const newLessons = afterLessons.filter(l => !beforeLessons.includes(l));
    if (newLessons.length === 0) return null;

    const userEmail = after.email;
    const userName = after.name || 'Қолданушы';
    const lang = after.language || 'kk';

    if (!userEmail) return null;

    for (const lessonKey of newLessons) {
      const [courseId, lessonId] = lessonKey.split('_');
      if (!courseId || !lessonId) continue;

      try {
        const courseSnap = await admin.firestore().doc(`courses/${courseId}`).get();
        const courseData = courseSnap.data();
        if (!courseData) continue;

        // Барлық сабақтар санын есептеу
        const sectionsSnap = await admin.firestore().collection(`courses/${courseId}/sections`).get();
        let totalCount = 0;
        let lessonName = '';

        for (const sectionDoc of sectionsSnap.docs) {
          const lessonsSnap = await admin.firestore()
            .collection(`courses/${courseId}/sections/${sectionDoc.id}/lessons`).get();
          totalCount += lessonsSnap.docs.length;

          for (const lessonDoc of lessonsSnap.docs) {
            if (lessonDoc.id === lessonId) {
              lessonName = lessonDoc.data().name || lessonDoc.id;
            }
          }
        }

        const completedCount = afterLessons.filter(l => l.startsWith(courseId + '_')).length;

        // Курс аяқталды ма?
        if (completedCount >= totalCount && totalCount > 0) {
          await sendEmail(userEmail, 'course_complete', lang, userName, courseData.name);
        } else {
          await sendEmail(userEmail, 'lesson_complete', lang, userName, courseData.name, lessonName, completedCount, totalCount);
        }
      } catch (err) {
        console.error(`Lesson progress email failed:`, err);
      }
    }

    return null;
  });

// ============================================================
// HEALTH CHECK: 6 сағат сайын Firebase/Google Cloud доступты
// және админ панель байланысын тексеру
// ============================================================
exports.checkAccessHealth = onSchedule('every 6 hours', async (event) => {
  const startTime = Date.now();
  const report = {
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    durationMs: 0,
    overall: 'ok',
    checks: {},
  };

  // --- 1. Firebase Auth байланысын тексеру ---
  try {
    const listResult = await auth.listUsers(1);
    report.checks.firebaseAuth = {
      status: 'ok',
      totalUsers: listResult.pageToken ? '1+' : listResult.users.length,
    };
  } catch (err) {
    report.checks.firebaseAuth = { status: 'error', message: err.message };
    report.overall = 'degraded';
  }

  // --- 2. Firestore байланысын тексеру ---
  try {
    const settingsSnap = await db.doc('settings/app').get();
    report.checks.firestore = {
      status: 'ok',
      settingsExists: settingsSnap.exists,
    };
  } catch (err) {
    report.checks.firestore = { status: 'error', message: err.message };
    report.overall = 'error';
  }

  // --- 3. Admin/Author custom claims синхронизациясын тексеру ---
  const claimsIssues = [];
  try {
    const usersSnap = await db.collection('users')
      .where('role', 'array-contains-any', ['admin', 'author']).get();

    for (const userDoc of usersSnap.docs) {
      const userData = userDoc.data();
      const uid = userDoc.id;
      const expectedAdmin = userData.role && userData.role.includes('admin');
      const expectedAuthor = userData.role && userData.role.includes('author');

      try {
        const userRecord = await auth.getUser(uid);
        const claims = userRecord.customClaims || {};

        if (claims.admin !== expectedAdmin || claims.author !== expectedAuthor) {
          claimsIssues.push({
            uid,
            email: userData.email,
            expected: { admin: expectedAdmin, author: expectedAuthor },
            actual: { admin: claims.admin || false, author: claims.author || false },
          });
          // Автоматты түзету
          await auth.setCustomUserClaims(uid, {
            admin: expectedAdmin,
            author: expectedAuthor,
          });
          await db.doc(`users/${uid}`).update({
            tokenClaimsUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      } catch (err) {
        claimsIssues.push({ uid, email: userData.email, error: err.message });
      }
    }

    report.checks.claimsSync = {
      status: claimsIssues.length === 0 ? 'ok' : 'fixed',
      totalAdminAuthor: usersSnap.docs.length,
      issuesFound: claimsIssues.length,
      details: claimsIssues,
    };
  } catch (err) {
    report.checks.claimsSync = { status: 'error', message: err.message };
    report.overall = 'degraded';
  }

  // --- 4. Мерзімі өткен курс доступтарын тексеру және тазалау ---
  const cleanedEnrollments = [];
  try {
    const usersWithExpirations = await db.collection('users')
      .where('enrolled', '!=', []).get();

    const now = new Date();

    for (const userDoc of usersWithExpirations.docs) {
      const userData = userDoc.data();
      const enrolled = userData.enrolled || [];
      const expirations = userData.enrolled_expirations || {};
      const userId = userDoc.id;

      let hasChanges = false;
      const activeEnrolled = enrolled.filter(courseId => {
        const exp = expirations[courseId];
        if (!exp) return true;
        const expTime = exp.toDate ? exp.toDate() : new Date(exp);
        if (now > expTime) {
          hasChanges = true;
          cleanedEnrollments.push({ userId, courseId, expiredAt: expTime.toISOString() });
          return false;
        }
        return true;
      });

      if (hasChanges) {
        const expiredIds = enrolled.filter(id => !activeEnrolled.includes(id));
        const updatedExpirations = { ...expirations };
        expiredIds.forEach(id => delete updatedExpirations[id]);

        await db.doc(`users/${userId}`).update({
          enrolled: activeEnrolled,
          enrolled_expirations: Object.keys(updatedExpirations).length > 0
            ? updatedExpirations
            : admin.firestore.FieldValue.delete(),
        });

        // Курстағы студент санын азайту
        for (const courseId of expiredIds) {
          try {
            const courseSnap = await db.doc(`courses/${courseId}`).get();
            if (courseSnap.exists) {
              const current = courseSnap.data().students || 0;
              await db.doc(`courses/${courseId}`).update({
                students: Math.max(0, current - 1),
              });
            }
          } catch (_) {}
        }
      }
    }

    report.checks.enrollmentCleanup = {
      status: 'ok',
      cleanedCount: cleanedEnrollments.length,
      details: cleanedEnrollments,
    };
  } catch (err) {
    report.checks.enrollmentCleanup = { status: 'error', message: err.message };
    report.overall = 'degraded';
  }

  // --- 5. Курсқа доступты тексеру ( Firestore rules дұрыс жұмыс істей ме) ---
  try {
    const coursesSnap = await db.collection('courses').limit(5).get();
    let accessibleCount = 0;
    for (const courseDoc of coursesSnap.docs) {
      const data = courseDoc.data();
      if (data.name && data.id) accessibleCount++;
    }
    report.checks.courseAccess = {
      status: 'ok',
      sampleSize: coursesSnap.docs.length,
      accessibleCount,
    };
  } catch (err) {
    report.checks.courseAccess = { status: 'error', message: err.message };
    report.overall = 'degraded';
  }

  // --- 6. Статистика ---
  try {
    const usersSnap = await db.collection('users').get();
    const coursesSnap = await db.collection('courses').get();

    let adminCount = 0;
    let authorCount = 0;
    let studentCount = 0;

    for (const doc of usersSnap.docs) {
      const role = doc.data().role || [];
      if (role.includes('admin')) adminCount++;
      else if (role.includes('author')) authorCount++;
      else studentCount++;
    }

    report.checks.stats = {
      status: 'ok',
      users: { total: usersSnap.docs.length, admin: adminCount, author: authorCount, student: studentCount },
      courses: { total: coursesSnap.docs.length },
    };
  } catch (err) {
    report.checks.stats = { status: 'error', message: err.message };
  }

  // --- Нәтижені Firestore-ға жазу ---
  report.durationMs = Date.now() - startTime;

  await db.collection('system_health').doc('latest').set(report);
  await db.collection('system_health').add({
    ...report,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`[HealthCheck] Completed in ${report.durationMs}ms — Status: ${report.overall}`);

  // Егер ауыр қате болса, админдерге хабарлау
  if (report.overall === 'error') {
    const adminsSnap = await db.collection('users')
      .where('role', 'array-contains', 'admin').get();

    for (const adminDoc of adminsSnap.docs) {
      const adminData = adminDoc.data();
      if (adminData.email) {
        try {
          await sendEmail(adminData.email, 'welcome', adminData.language || 'kk', adminData.name || 'Admin',
            `⚠️ Денсаулық тексеруі: ${report.overall}. Қателер: ${JSON.stringify(report.checks)}`);
        } catch (_) {}
      }
    }
  }

  return null;
});
