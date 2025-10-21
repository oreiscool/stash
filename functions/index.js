// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp();

// HTTP-triggered function to clean up old trash items
exports.cleanupOldTrash = onRequest(async (req, res) => {
  try {
    const db = getFirestore();

    // Calculate the timestamp for 7 days ago
    const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

    logger.log("Starting cleanup of trash older than:", sevenDaysAgo);

    // Query all items older than 7 days in the trash
    const snapshot = await db
      .collectionGroup("stash_items")
      .where("isDeleted", "==", true)
      .where("deletedAt", "<", sevenDaysAgo)
      .get();

    logger.log(`Found ${snapshot.size} items to delete.`);

    if (snapshot.empty) {
      res.json({result: "No items to delete."});
      return;
    }

    // Batch delete all items
    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      logger.log(`Deleting item: ${doc.id}`);
      batch.delete(doc.ref);
    });

    await batch.commit();
    logger.log(`Deleted ${snapshot.size} old trash items.`);
    res.json({result: `Deleted ${snapshot.size} old trash items.`});
  } catch (error) {
    logger.error("Error during cleanup:", error);
    res.status(500).json({error: "Cleanup failed. Check logs for details."});
  }
});