# Firestore Composite Indexes Requirement

The following composite indexes are required for the Festio_lk application to function correctly. Without these indexes, Firestore queries with multiple filters or sorting will fail.

## Collection: `events`

### Index 1: Main Event List & Upcoming Events
- **Field 1**: `isApproved` (Ascending)
- **Field 2**: `isSpam` (Ascending)
- **Field 3**: `startDate` (Ascending)
- **Query**: `_firestore.collection('events').where('isApproved', isEqualTo: true).where('isSpam', isEqualTo: false).orderBy('startDate', descending: false)`
- **Reason**: Used in `getApprovedEvents()` and `getUpcomingEvents()` to show valid events sorted by date.

### Index 2: Organizer Dashboard
- **Field 1**: `organizerId` (Ascending)
- **Field 2**: `submittedAt` (Descending)
- **Query**: `_firestore.collection('events').where('organizerId', isEqualTo: organizerId).orderBy('submittedAt', descending: true)`
- **Reason**: Used in `getOrganizerEvents()` to show an organizer's submission history.

### Index 3: Admin Approval Flow
- **Field 1**: `isApproved` (Ascending)
- **Field 2**: `isSpam` (Ascending)
- **Field 3**: `submittedAt` (Descending)
- **Query**: `_firestore.collection('events').where('isApproved', isEqualTo: false).where('isSpam', isEqualTo: false).orderBy('submittedAt', descending: true)`
- **Reason**: Used in `getPendingEvents()` to show events awaiting review.

## Collection: `bookings`

### Index 4: User Bookings
- **Field 1**: `userId` (Ascending)
- **Field 2**: `eventDate` (Ascending)
- **Query**: `_firestore.collection('bookings').where('userId', isEqualTo: userId).orderBy('eventDate', descending: false)`
- **Reason**: Used in `getUserBookings()` to show a user's upcoming tickets.

---

### How to create these indexes:
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Select your project.
3. In the left menu, go to **Build** > **Firestore Database**.
4. Click on the **Indexes** tab.
5. Click **Add Index** and enter the fields exactly as listed above.
6. Alternatively, click the link provided in the Flutter debug console when a query fails; it will take you directly to the index creation page with the fields pre-filled.
