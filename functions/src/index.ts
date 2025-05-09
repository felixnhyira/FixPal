import {onDocumentCreated, onDocumentUpdated} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import moment from "moment";

admin.initializeApp();

const db = admin.firestore();

// 1. Update stats when new user registers
export const updateUserStats = onDocumentCreated(
  "users/{userId}",
  async () => {
    const batch = db.batch();
    const overviewRef = db.collection("admin_stats").doc("overview");
    const weeklyRef = db.collection("admin_stats").doc("weekly");

    batch.update(overviewRef, {
      "total_users": admin.firestore.FieldValue.increment(1),
      "active_users": admin.firestore.FieldValue.increment(1),
      "new_users_today": admin.firestore.FieldValue.increment(1),
      "last_updated": admin.firestore.FieldValue.serverTimestamp(),
    });

    batch.update(weeklyRef, {
      "new_users": admin.firestore.FieldValue.increment(1),
    });

    await batch.commit();
  }
);

// 2. Update stats when report status changes
export const updateReportStats = onDocumentUpdated(
  "reports/{reportId}",
  async (event) => {
    if (!event.data) {
      console.log("Document deleted, no data available");
      return null;
    }

    const change = event.data;
    const before = change.before.data();
    const after = change.after.data();

    // Only process if status changed
    if (before.status === after.status) return null;

    const batch = db.batch();
    const overviewRef = db.collection("admin_stats").doc("overview");
    const weeklyRef = db.collection("admin_stats").doc("weekly");

    if (after.status === "resolved") {
      // Calculate resolution time in hours
      const createdAt = before.createdAt.toDate();
      const resolvedAt = after.resolvedAt.toDate();
      const resolutionHours = moment(resolvedAt).diff(moment(createdAt), "hours");

      batch.update(overviewRef, {
        "resolved_reports": admin.firestore.FieldValue.increment(1),
        "pending_reports": admin.firestore.FieldValue.increment(-1),
        "last_updated": admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update weekly average resolution time
      const weeklyDoc = await weeklyRef.get();
      const currentAvg = weeklyDoc.data()?.avg_resolution_time || 0;
      const totalResolved = weeklyDoc.data()?.resolved_reports || 0;
      const newAvg = ((currentAvg * totalResolved) + resolutionHours) / (totalResolved + 1);

      batch.update(weeklyRef, {
        "resolved_reports": admin.firestore.FieldValue.increment(1),
        "avg_resolution_time": newAvg,
      });
    } else if (after.status === "pending" && before.status === "resolved") {
      // Handle case when report is reopened
      batch.update(overviewRef, {
        "resolved_reports": admin.firestore.FieldValue.increment(-1),
        "pending_reports": admin.firestore.FieldValue.increment(1),
        "last_updated": admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return batch.commit();
  }
);

// 3. Daily reset of new_users_today
export const resetDailyStats = onSchedule(
  {
    schedule: "0 0 * * *",
    timeZone: "Africa/Accra",
  },
  async () => {
    await db.collection("admin_stats").doc("overview").update({
      "new_users_today": 0,
      "last_updated": admin.firestore.FieldValue.serverTimestamp(),
    });
  }
);

// 4. Weekly reset of weekly stats
export const resetWeeklyStats = onSchedule(
  {
    schedule: "0 0 * * 0", // Sundays
    timeZone: "Africa/Accra",
  },
  async () => {
    const now = moment();
    const startOfWeek = now.clone().startOf("week").toDate();
    const endOfWeek = now.clone().endOf("week").toDate();

    await db.collection("admin_stats").doc("weekly").set({
      "start_date": startOfWeek,
      "end_date": endOfWeek,
      "new_users": 0,
      "completed_jobs": 0,
      "revenue": 0,
      "avg_resolution_time": 0,
      "resolved_reports": 0,
    });
  }
);

// 5. Initialize stats (run manually once)
export const initializeStats = onRequest(async (req, res) => {
  const now = moment();
  const startOfWeek = now.clone().startOf("week").toDate();
  const endOfWeek = now.clone().endOf("week").toDate();

  const batch = db.batch();
  const overviewRef = db.collection("admin_stats").doc("overview");
  const weeklyRef = db.collection("admin_stats").doc("weekly");

  batch.set(overviewRef, {
    "total_users": 0,
    "active_users": 0,
    "total_reports": 0,
    "pending_reports": 0,
    "resolved_reports": 0,
    "new_users_today": 0,
    "last_updated": admin.firestore.FieldValue.serverTimestamp(),
  });

  batch.set(weeklyRef, {
    "start_date": startOfWeek,
    "end_date": endOfWeek,
    "new_users": 0,
    "completed_jobs": 0,
    "revenue": 0,
    "avg_resolution_time": 0,
    "resolved_reports": 0,
  });

  await batch.commit();
  res.send("Admin stats initialized successfully");
});
