/* eslint-disable no-console */
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

/**
 * Usage:
 * 1) Download Firebase service account JSON from Firebase Console.
 * 2) Run:
 *    node scripts/create_admin.js "<serviceAccountPath>" "<adminEmail>" "<adminPassword>" "<adminName>"
 *
 * Example:
 *    node scripts/create_admin.js "./serviceAccount.json" "admin@pos.com" "Admin@123" "System Admin"
 */

function resolveServiceAccountPath(inputPath) {
  const candidatePaths = [
    inputPath,
    path.resolve(process.cwd(), inputPath),
    path.resolve(__dirname, inputPath),
  ];

  for (const candidatePath of candidatePaths) {
    if (fs.existsSync(candidatePath)) {
      return candidatePath;
    }
  }

  return null;
}

async function main() {
  const [, , serviceAccountPath, email, password, nameArg] = process.argv;
  const name = nameArg || 'System Admin';

  if (!serviceAccountPath || !email || !password) {
    console.error(
      'Missing arguments.\nUsage: node scripts/create_admin.js "<serviceAccountPath>" "<adminEmail>" "<adminPassword>" "<adminName>"',
    );
    process.exit(1);
  }

  const resolvedPath = resolveServiceAccountPath(serviceAccountPath);
  if (!resolvedPath) {
    console.error(`Service account file not found: ${serviceAccountPath}`);
    console.error(
      'Tip: pass an absolute path or a relative path from current folder or scripts folder.',
    );
    process.exit(1);
  }

  const serviceAccount = JSON.parse(fs.readFileSync(resolvedPath, 'utf8'));
  console.log(`Using service account file: ${resolvedPath}`);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  const db = admin.firestore();
  const now = new Date().toISOString();

  let uid;
  try {
    const userRecord = await admin.auth().getUserByEmail(email);
    uid = userRecord.uid;
    console.log(`Auth user already exists: ${uid}`);
  } catch (_) {
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: name,
      emailVerified: true,
      disabled: false,
    });
    uid = userRecord.uid;
    console.log(`Created auth user: ${uid}`);
  }

  await db.collection('users').doc(uid).set(
    {
      id: uid,
      email,
      name,
      role: 'admin',
      isActive: true,
      createdAt: now,
      lastLoginAt: null,
      permissions: {
        sales: {view: true, create: true, edit: true, delete: true},
        purchases: {view: true, create: true, edit: true, delete: true},
        invoices: {view: true, create: true, edit: true, delete: true},
        products: {view: true, create: true, edit: true, delete: true},
        users: {view: true, create: true, edit: true, delete: true},
      },
    },
    {merge: true},
  );

  console.log('Admin user document created/updated successfully.');
  process.exit(0);
}

main().catch((error) => {
  console.error('Failed to create admin:', error);
  process.exit(1);
});
