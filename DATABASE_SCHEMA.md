# Dental Case Manager - Database Schema

## Firestore Collections Structure

### 1. Users Collection (`users`)
```json
{
  "userId": "string (auto-generated)",
  "email": "string",
  "displayName": "string",
  "photoUrl": "string",
  "googleDriveConnected": "boolean",
  "driveFolderId": "string | null",
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp",
  "settings": {
    "biometricEnabled": "boolean",
    "autoBackup": "boolean",
    "notificationsEnabled": "boolean",
    "theme": "string (light/dark)"
  }
}
```

### 2. Patients Collection (`patients`)
```json
{
  "patientId": "string (auto-generated)",
  "userId": "string (reference to users)",
  "name": "string",
  "phone": "string",
  "age": "number",
  "gender": "string (male/female/other)",
  "medicalHistory": "string",
  "allergies": "string",
  "smokingStatus": "string (never/former/current)",
  "notes": "string",
  "profilePhotoUrl": "string | null",
  "profilePhotoLocal": "string | null",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "isActive": "boolean",
  "tags": "array<string>",
  "lastVisitDate": "timestamp | null",
  "nextAppointmentId": "string | null"
}
```

### 3. Treatments Collection (`treatments`)
```json
{
  "treatmentId": "string (auto-generated)",
  "patientId": "string (reference to patients)",
  "userId": "string (reference to users)",
  "category": "string (orthodontics/fillings/scaling_polishing)",
  "toothNumber": "string | null",
  "toothNumbers": "array<string> | null",
  "date": "timestamp",
  "diagnosis": "string",
  "treatmentNotes": "string",
  "materials": "array<string>",
  "progressNotes": "string",
  "status": "string (planned/in_progress/completed)",
  "cost": "number | null",
  "images": [
    {
      "imageId": "string",
      "url": "string",
      "localPath": "string | null",
      "label": "string (before/during/after)",
      "uploadedAt": "timestamp",
      "driveFileId": "string | null"
    }
  ],
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "syncedToDrive": "boolean",
  "driveFolderId": "string | null"
}
```

### 4. Appointments Collection (`appointments`)
```json
{
  "appointmentId": "string (auto-generated)",
  "patientId": "string (reference to patients)",
  "userId": "string (reference to users)",
  "title": "string",
  "treatmentType": "string",
  "date": "timestamp",
  "duration": "number (minutes)",
  "notes": "string",
  "status": "string (scheduled/confirmed/completed/cancelled)",
  "reminderEnabled": "boolean",
  "reminderTime": "timestamp | null",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### 5. Gallery Collection (`gallery`)
```json
{
  "galleryId": "string (auto-generated)",
  "userId": "string (reference to users)",
  "patientId": "string (reference to patients)",
  "treatmentId": "string (reference to treatments)",
  "category": "string (orthodontics/fillings/scaling_polishing)",
  "beforeImage": {
    "url": "string",
    "localPath": "string | null",
    "date": "timestamp"
  },
  "afterImage": {
    "url": "string",
    "localPath": "string | null",
    "date": "timestamp"
  },
  "duringImages": "array<ImageData>",
  "title": "string",
  "description": "string",
  "createdAt": "timestamp",
  "isPublic": "boolean"
}
```

### 6. BackupLogs Collection (`backup_logs`)
```json
{
  "logId": "string (auto-generated)",
  "userId": "string (reference to users)",
  "type": "string (auto/manual)",
  "status": "string (success/failed/in_progress)",
  "itemsSynced": "number",
  "totalItems": "number",
  "errors": "array<string>",
  "startedAt": "timestamp",
  "completedAt": "timestamp | null"
}
```

### 7. OfflineQueue Collection (`offline_queue`)
```json
{
  "queueId": "string (auto-generated)",
  "userId": "string (reference to users)",
  "operation": "string (create/update/delete)",
  "collection": "string",
  "documentId": "string",
  "data": "object",
  "createdAt": "timestamp",
  "retryCount": "number",
  "lastRetryAt": "timestamp | null"
}
```

## Indexes

### Patients Collection
- `userId` (Ascending)
- `name` (Ascending) - for search
- `phone` (Ascending) - for search
- `createdAt` (Descending)

### Treatments Collection
- `patientId` (Ascending)
- `userId` (Ascending)
- `category` (Ascending)
- `date` (Descending)
- `status` (Ascending)

### Appointments Collection
- `patientId` (Ascending)
- `userId` (Ascending)
- `date` (Ascending)
- `status` (Ascending)

## Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Patients - users can only access their own patients
    match /patients/{patientId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    // Treatments - users can only access their own treatments
    match /treatments/{treatmentId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    // Appointments - users can only access their own appointments
    match /appointments/{appointmentId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    // Gallery - users can only access their own gallery
    match /gallery/{galleryId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    // Backup logs - users can only access their own logs
    match /backup_logs/{logId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    // Offline queue - users can only access their own queue
    match /offline_queue/{queueId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
  }
}
```

## Storage Structure

### Firebase Storage Paths
```
/users/{userId}/
  /patients/
    /{patientId}/
      /profile.jpg
      /treatments/
        /{treatmentId}/
          /before_001.jpg
          /during_001.jpg
          /after_001.jpg
```

### Google Drive Folder Structure
```
/Dental Records/
  /{Patient Name}/
    /Profile/
      /profile.jpg
    /Orthodontics/
      /{date}/
        /before_001.jpg
        /during_001.jpg
        /after_001.jpg
    /Fillings/
      /{date}/
        /...
    /Scaling & Polishing/
      /{date}/
        /...
```

## Data Relationships

```
User (1) ──── (N) Patient
Patient (1) ──── (N) Treatment
Patient (1) ──── (N) Appointment
Treatment (1) ──── (N) Images
Treatment (1) ──── (1) Gallery Entry
```
