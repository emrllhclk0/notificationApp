const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotification = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "This function must be called while authenticated."
    );
  }

  // Validate input data
  const { title, body, topic, importanceLevel } = data;
  
  if (!title || !body || !topic) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required fields: title, body, or topic"
    );
  }

  // Create the message payload
  const message = {
    notification: {
      title: title,
      body: body,
      sound: "default",
    },
    data: {
      importanceLevel: importanceLevel || "normal",
      timestamp: new Date().toISOString(),
      click_action: "FLUTTER_NOTIFICATION_CLICK"
    },
    topic: topic,
    android: {
      priority: "high",
      notification: {
        channel_id: "noticlass_bildirimler",
        sound: "default",
        priority: "high",
        importance: "high",
      }
    },
    apns: {
      headers: {
        "apns-priority": "10"
      },
      payload: {
        aps: {
          sound: "default",
          badge: 1,
          "content-available": 1
        }
      }
    }
  };

  try {
    // Send the message
    const response = await admin.messaging().send(message);
    console.log("Successfully sent message:", response);
    return { success: true, messageId: response };
  } catch (error) {
    console.log("Error sending message:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to send notification: " + error.message
    );
  }
});

// Function to send notification to multiple topics
exports.sendNotificationToMultipleTopics = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "This function must be called while authenticated."
    );
  }

  // Validate input data
  const { title, body, topics, importanceLevel } = data;
  
  if (!title || !body || !topics || !Array.isArray(topics)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required fields: title, body, or topics (must be an array)"
    );
  }

  // Send notifications to each topic
  const results = [];
  
  for (const topic of topics) {
    try {
      const message = {
        notification: {
          title: title,
          body: body,
          sound: "default",
        },
        data: {
          importanceLevel: importanceLevel || "normal",
          timestamp: new Date().toISOString(),
          click_action: "FLUTTER_NOTIFICATION_CLICK"
        },
        topic: topic,
        android: {
          priority: "high",
          notification: {
            channel_id: "noticlass_bildirimler",
            sound: "default",
            priority: "high",
            importance: "high",
          }
        },
        apns: {
          headers: {
            "apns-priority": "10"
          },
          payload: {
            aps: {
              sound: "default",
              badge: 1,
              "content-available": 1
            }
          }
        }
      };

      const response = await admin.messaging().send(message);
      results.push({ topic: topic, success: true, messageId: response });
      console.log(`Successfully sent message to topic ${topic}:`, response);
    } catch (error) {
      console.log(`Error sending message to topic ${topic}:`, error);
      results.push({ topic: topic, success: false, error: error.message });
    }
  }

  return { results: results };
});