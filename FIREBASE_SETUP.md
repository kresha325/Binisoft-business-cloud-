# Firebase setup — Binisoft Business Cloud (Phase 2)

Firebase project: `binisoft-business-cloud`

## 1. Create Cloud Firestore
Firebase Console → Build → Firestore Database → Create database.
Choose a suitable EU region, then deploy the repository's `firestore.rules` promptly.
Never launch with open test-mode rules.

## 2. Deploy rules
Using Firebase CLI (recommended):
```bash
firebase login
firebase use binisoft-business-cloud
firebase deploy --only firestore:rules
```
Or copy the content of `firestore.rules` into Firebase Console → Firestore → Rules → Publish.

## 3. Bootstrap first platform administrator (manual, one-time)
1. Register your own email/password account in the Flutter application.
2. Once signed in, the Pending screen shows your Firebase Authentication UID.
3. In Firebase Console → Firestore → Data, create collection `platformAdmins`.
4. Create a document whose **document ID is exactly your UID**.
5. Set a simple field `enabled` (boolean) to `true`.
6. Reload the Flutter web app. It should display the Super Admin view.

IMPORTANT: `platformAdmins` has no client write permission. The document
must be created through Firebase Console or Admin SDK, never by the app.
Do not create a platform-admin document for a customer.

## 4. Register first business
1. Have the owner register using Email/Password.
2. The owner's pending screen shows their UID.
3. As Super Admin, tap "Biznes i ri".
4. Enter business name, industry and owner UID.
5. The Firestore batch creates `businesses/{businessId}` and sets the
   owner's `users/{uid}` to role `owner`, with `businessId` assigned.

## Data structure
```
platformAdmins/{uid}            // console/Admin SDK write only
users/{uid}                     // role: pending | owner
businesses/{businessId}         // name, type, ownerId, active, createdAt
```

## Current boundaries
- Email/password authentication and protected owner/superadmin routing implemented.
- Firebase phone verification is enabled in Console, but phone OTP UI is not implemented.
- Business creation is functional only after Firestore database and rules are deployed.
- Catalog CRUD, memberships/team roles, verification gating and subscription enforcement are not yet implemented.
- Firebase web is configured; native iOS/Android registrations are still pending.
- Do not store private account passwords or service-account keys in GitHub.
