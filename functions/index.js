// /**
//  * Import function triggers from their respective submodules:
//  *
//  * const {onCall} = require("firebase-functions/v2/https");
//  * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
//  *
//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
//  */

// const {setGlobalOptions} = require("firebase-functions");
// const {onRequest} = require("firebase-functions/https");
// const logger = require("firebase-functions/logger");

// // For cost control, you can set the maximum number of containers that can be
// // running at the same time. This helps mitigate the impact of unexpected
// // traffic spikes by instead downgrading performance. This limit is a
// // per-function limit. You can override the limit for each function using the
// // `maxInstances` option in the function's options, e.g.
// // `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// // NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// // functions should each use functions.runWith({ maxInstances: 10 }) instead.
// // In the v1 API, each function can only serve one request per container, so
// // this will be the maximum concurrent request count.
// setGlobalOptions({ maxInstances: 10 });

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// // exports.helloWorld = onRequest((request, response) => {
// //   logger.info("Hello logs!", {structuredData: true});
// //   response.send("Hello from Firebase!");
// // });


const { setGlobalOptions } = require("firebase-functions");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");

const admin = require("firebase-admin");
admin.initializeApp();

// 🔥 Limit max instances (cost control)
setGlobalOptions({ maxInstances: 10 });

/**
 * Smart Timetable Notification System
 * Triggers when admin updates timetable
 */
exports.smartTimetableNotification = onDocumentUpdated(
//   "admins/{adminId}/admin_timetable/{timetableId}",
"admin_timetable/{timetableId}",
  async (event) => {
    try {
      const before = event.data.before.data();
      const after = event.data.after.data();

      if (!before || !after) return;

      // 🧠 Detect what changed
      const changedFields = [];

      const fieldsToCheck = [
        "day",
        "time",
        "courseTitle",
        "courseCode",
        "teacherId",
        "department",
        "shift",
        "room",
        "semester"
      ];

      fieldsToCheck.forEach((field) => {
        if (before[field] !== after[field]) {
          changedFields.push(field);
        }
      });

      // ❌ No real change → exit
      if (changedFields.length === 0) return;

      const db = admin.firestore();

      // 🎯 Find students matching updated timetable
      const studentsSnapshot = await db.collection("users")
        .where("department", "==", after.department)
        .where("semester", "==", after.semester)
        .where("shift", "==", after.shift)
        .get();

      const studentTokens = studentsSnapshot.docs
        .map(doc => doc.data().fcmToken)
        .filter(token => token);

      // 👨‍🏫 Teacher notification (optional but useful)
      let teacherToken = null;

      if (after.teacherId) {
        const teacherDoc = await db.collection("users")
          .doc(after.teacherId)
          .get();

        // teacherToken = teacherDoc.data()?.fcmToken;
        teacherToken = teacherDoc.data() && teacherDoc.data().fcmToken;
      }

      // Merge tokens
      const tokens = [...studentTokens];
      if (teacherToken) tokens.push(teacherToken);

      if (tokens.length === 0) return;

      // 🧾 Create readable message
      const readableFields = changedFields.map((f) => {
        switch (f) {
          case "day": return "Day";
          case "time": return "Time";
          case "courseTitle": return "Course Title";
          case "courseCode": return "Course Code";
          case "teacherId": return "Teacher";
          case "department": return "Department";
          case "shift": return "Shift";
          case "room": return "Room";
          case "semester": return "Semester";
          default: return f;
        }
      });

      // 📢 Send FCM notification
      const message = {
        notification: {
          title: "Timetable Updated",
          body: `Updated: ${readableFields.join(", ")}`,
        },
        tokens: tokens,
      };

      await admin.messaging().sendEachForMulticast(message);

      logger.info("Timetable notification sent successfully");

    } catch (error) {
      logger.error("Error sending timetable notification:", error);
    }
  }
);