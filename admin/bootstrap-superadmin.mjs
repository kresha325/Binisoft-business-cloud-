/**
 * One-time, privileged bootstrap for Binisoft Business Cloud.
 * Run locally or in a trusted environment with Application Default Credentials.
 * NEVER run this in Flutter, a browser, or GitHub Pages.
 */
import admin from 'firebase-admin';

const PROJECT_ID = 'binisoft-business-cloud';
const SUPERADMIN_EMAIL = 'Kreshnik.sh.gashi@hotmail.com';
const DRY_RUN = !process.argv.includes('--apply');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: PROJECT_ID,
  });
}

const auth = admin.auth();
const db = admin.firestore();
const user = await auth.getUserByEmail(SUPERADMIN_EMAIL);

if (user.disabled) throw new Error('Firebase Auth user is disabled.');
if (!user.emailVerified) {
  throw new Error('Verify the Firebase Auth email address before granting platform access.');
}

const ref = db.collection('platformAdmins').doc(user.uid);
const current = await ref.get();
if (current.exists && current.data()?.email &&
    current.data().email.toLowerCase() !== SUPERADMIN_EMAIL.toLowerCase()) {
  throw new Error('Existing admin document has a different email; refusing to overwrite.');
}

console.log(JSON.stringify({
  projectId: PROJECT_ID,
  email: user.email,
  uid: user.uid,
  documentPath: ref.path,
  existingDocument: current.exists,
  existingEnabled: current.data()?.enabled ?? null,
  mode: DRY_RUN ? 'dry-run' : 'apply',
}, null, 2));

if (DRY_RUN) {
  console.log('No changes made. Re-run with --apply after verifying the identity.');
} else {
  await ref.set({
    enabled: true,
    email: user.email,
    // Owner attribution; never used as an authentication credential.
    identifier: 'kresha325',
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, {merge: true});
  console.log('Platform Super Admin enabled for verified Firebase UID.');
}
