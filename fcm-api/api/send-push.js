const admin = require('firebase-admin');

if (!admin.apps.length) {
  const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

module.exports = async (req, res) => {
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    return res.status(200).end();
  }

  res.setHeader('Access-Control-Allow-Origin', '*');

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed. Use POST.' });
  }

  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized — Bearer token required' });
  }

  const idToken = authHeader.split('Bearer ')[1];

  let decodedToken;
  try {
    decodedToken = await admin.auth().verifyIdToken(idToken);
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }

  const uid = decodedToken.uid;
  const userSnap = await admin.firestore().doc(`users/${uid}`).get();
  const userData = userSnap.data();

  if (!userData || !userData.role || !userData.role.includes('admin')) {
    return res.status(403).json({ error: 'Forbidden — admin role required' });
  }

  const { title, description, topic } = req.body;

  if (!title || !description) {
    return res.status(400).json({ error: 'title and description are required' });
  }

  const targetTopic = topic || 'all';

  const message = {
    notification: {
      title: title,
      body: description,
    },
    data: {
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
      id: '1',
      status: 'done',
      notification_type: 'custom',
      description: description,
      title: title,
    },
    android: {
      priority: 'high',
      notification: {
        sound: 'default',
        channelId: 'high_importance_channel',
      },
    },
    apns: {
      headers: {
        'apns-priority': '10',
      },
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
          'content-available': 1,
        },
      },
    },
    topic: targetTopic,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log(`FCM sent to topic '${targetTopic}' by admin ${uid}:`, response);
    return res.status(200).json({
      success: true,
      messageId: response,
      message: `Push notification sent to topic '${targetTopic}'`
    });
  } catch (error) {
    console.error('FCM send error:', error);
    return res.status(500).json({
      success: false,
      error: error.message
    });
  }
};
