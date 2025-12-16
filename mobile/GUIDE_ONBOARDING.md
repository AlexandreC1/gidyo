# Guide Onboarding & Verification Flow

## Overview

The guide onboarding flow is a 7-step verification wizard that allows new guides to register, provide their information, and get verified to start offering services on GIDYO. The flow collects identification, service offerings, vehicle info (if applicable), availability, and payment details.

## Status: Partially Implemented

### ✅ **Completed Components** (60%)

1. **Data Models** (`domain/entities/guide_onboarding_entity.dart`) - 371 lines
   - `GuideOnboardingData` - Complete form state
   - `ServiceOffering` - Service setup
   - `VehicleInformation` - Vehicle details
   - `WeeklySchedule` / `DayAvailability` - Availability
   - `BankAccountInfo` / `MonCashInfo` - Payment methods
   - Enums: `IDType`, `PayoutMethod`, `OnboardingStep`, `VerificationStatus`

2. **State Management** (`presentation/providers/guide_onboarding_providers.dart`)
   - `guideOnboardingDataProvider` - Main form state
   - `GuideOnboardingNotifier` - State management with methods for each step
   - `serviceTypesProvider` - Fetches available service categories
   - Auto-saves progress after each step
   - Handles navigation between steps

3. **API Layer** (`data/datasources/guide_onboarding_datasource.dart`)
   - `saveBasicInfo()` - Saves to Supabase
   - `saveIdentification()` - Uploads ID photos
   - `saveServices()` - Creates guide services
   - `saveVehicleInfo()` - Vehicle registration
   - `saveAvailability()` - Sets schedule
   - `savePaymentSetup()` - Payment info
   - `submitForReview()` - Final submission
   - `uploadPhoto()` - Supabase storage upload
   - `sendOTP()` / `verifyOTP()` - Phone verification

4. **Screen Implementations**
   - ✅ `BasicInfoScreen` (408 lines) - COMPLETE
   - ✅ `IdentificationScreen` (408 lines) - COMPLETE
   - ✅ `ServicesSetupScreen` (291 lines) - COMPLETE
   - ✅ `GuideOnboardingScreen` (496 lines) - Main wrapper/router

### ⚠️ **Incomplete/Placeholder** (40%)

5. **Screens Needing Full Implementation**
   - ⏳ `VehicleInfoScreen` - Empty file (needs 400+ lines)
   - ⏳ `AvailabilityScreen` - Placeholder (needs weekly grid UI)
   - ⏳ `PaymentSetupScreen` - Placeholder (needs bank/MonCash forms)
   - ⏳ `ReviewScreen` - Basic stub (needs full summary + edit)
   - ⏳ `UnderReviewScreen` - Basic stub (needs status UI)

---

## Architecture

```
lib/features/guide/onboarding/
├── data/
│   └── datasources/
│       └── guide_onboarding_datasource.dart    ✅ Complete
├── domain/
│   └── entities/
│       └── guide_onboarding_entity.dart        ✅ Complete
└── presentation/
    ├── pages/
    │   ├── guide_onboarding_screen.dart        ✅ Complete (router)
    │   ├── basic_info_screen.dart              ✅ Complete
    │   ├── identification_screen.dart          ✅ Complete
    │   ├── services_setup_screen.dart          ✅ Complete
    │   ├── vehicle_info_screen.dart            ⏳ Empty
    │   ├── availability_screen.dart            ⏳ Missing
    │   ├── payment_setup_screen.dart           ⏳ Missing
    │   ├── review_screen.dart                  ⏳ Missing
    │   └── under_review_screen.dart            ⏳ Missing
    └── providers/
        └── guide_onboarding_providers.dart     ✅ Complete
```

---

## Screen-by-Screen Breakdown

### Step 1: BasicInfoScreen ✅ COMPLETE

**File**: `basic_info_screen.dart` (408 lines)

**Features Implemented**:
- Full name input
- Phone number input with formatting
- OTP verification flow
  - "Send Code" button
  - 6-digit OTP input
  - Countdown timer
  - Resend functionality
- Email input with validation
- Profile photo upload
  - Camera or gallery picker
  - Upload to Supabase storage
  - Preview uploaded image
- Bio text field (multiline)
  - Minimum 50 characters
  - Character counter
- Form validation
- Auto-save on continue

**State Updates**:
```dart
await ref.read(guideOnboardingDataProvider.notifier).saveBasicInfo(
  fullName: name,
  phone: phone,
  phoneVerified: true,
  email: email,
  profilePhotoUrl: photoUrl,
  bio: bio,
);
```

**Validation**:
- All fields required
- Phone must be verified
- Bio minimum 50 characters
- Valid email format

---

### Step 2: IdentificationScreen ✅ COMPLETE

**File**: `identification_screen.dart` (408 lines)

**Features Implemented**:
- ID Type selector (dropdown)
  - NIF (National ID)
  - Passport
  - Driver's License
- ID Front photo upload
  - Camera capture
  - Upload to storage
  - Preview
- ID Back photo upload
  - Same functionality
- Selfie photo upload
  - Camera only (for verification)
  - Face detection instructions
- Verification status display
  - Shows "Pending Review" after upload
- Upload progress indicators
- Error handling

**State Updates**:
```dart
await ref.read(guideOnboardingDataProvider.notifier).saveIdentification(
  idType: IDType.nif,
  idFrontPhotoUrl: frontUrl,
  idBackPhotoUrl: backUrl,
  selfiePhotoUrl: selfieUrl,
);
```

**Security Notes**:
- Photos stored in `/guide-verification/{userId}/` folder
- Only verified guides can proceed
- Admin manual review required

---

### Step 3: ServicesSetupScreen ✅ COMPLETE

**File**: `services_setup_screen.dart` (291 lines)

**Features Implemented**:
- Fetches service categories from `service_types` table
- Multi-select chips for service categories
- For each selected service:
  - Price input (in USD)
  - Description text field
  - "What's Included" text field (optional in current impl)
- Service-specific fields:
  - Detects if service requires vehicle
  - Flags for next step routing
- Validation per service
- Preview of selected services
- Add/remove services dynamically

**Service Categories** (from database):
- City Tour
- Airport Transfer
- Custom Itinerary
- Photography Tour
- Food & Culinary Tour
- Historical Sites Tour
- Beach & Nature Tour
- Shopping Guide

**State Updates**:
```dart
final services = [
  ServiceOffering(
    serviceTypeId: 'st1',
    serviceTypeName: 'City Tour',
    price: 50.0,
    description: 'Comprehensive Port-au-Prince tour',
    included: ['Transportation', 'Guide', 'Lunch'],
    requiresVehicle: true,
  ),
];

await ref.read(guideOnboardingDataProvider.notifier).saveServices(services);
```

**Auto-routing Logic**:
- If any service requires vehicle → Go to `VehicleInfoScreen`
- Otherwise → Skip to `AvailabilityScreen`

---

### Step 4: VehicleInfoScreen ⏳ PLACEHOLDER

**File**: `vehicle_info_screen.dart` (0 lines - empty)

**Required Features**:

```dart
// Vehicle Type Selection
enum VehicleType { sedan, suv, van, bus, motorcycle }
- ChoiceChips for selection

// Basic Info
- Make (TextField) - e.g., "Toyota"
- Model (TextField) - e.g., "Camry"
- Year (Number input) - 1990 to current year
- License Plate (TextField) - uppercase
- Passenger Capacity (Number) - 1-50

// Photo Uploads
- Vehicle Exterior Photo (required)
- Vehicle Interior Photo (required)
- Additional Photos (up to 5 total)
- Each with preview + remove button

// Insurance Document
- Upload insurance certificate (PDF or image)
- Display uploaded file name
- Remove and re-upload

// Validation
- At least 2 vehicle photos
- All fields filled
- Valid year range
```

**State Model** (already defined):
```dart
class VehicleInformation {
  final VehicleType vehicleType;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final int passengerCapacity;
  final List<String> vehiclePhotos;
  final String? insuranceDocumentUrl;
}
```

**API Call**:
```dart
await ref.read(guideOnboardingDataProvider.notifier).saveVehicleInfo(vehicleInfo);
```

**Navigation**: → `AvailabilityScreen`

---

### Step 5: AvailabilityScreen ⏳ NEEDS IMPLEMENTATION

**Current State**: Simple placeholder button

**Required Features**:

**Tab 1: Weekly Recurring Schedule**
- 7-day grid (Monday - Sunday)
- For each day:
  - Toggle: Available / Unavailable
  - If available:
    - Start time picker (dropdown or time picker)
    - End time picker
    - Display: "9:00 AM - 5:00 PM"
- Quick presets:
  - "Weekdays 9-5"
  - "Weekends Only"
  - "Full Week"
  - "Custom"

**Tab 2: Specific Dates**
- Calendar view (table_calendar package)
- Tap date to mark available
- List of marked dates below
- Remove button for each

**UI Mock**:
```
┌─────────────────────────────────────┐
│  Set Your Availability              │
├─────────────────────────────────────┤
│  [Weekly] [Specific Dates]          │
├─────────────────────────────────────┤
│  Monday    ✓ Available               │
│            9:00 AM - 5:00 PM         │
│                                      │
│  Tuesday   ✓ Available               │
│            9:00 AM - 5:00 PM         │
│  ...                                 │
│  Sunday    ✗ Unavailable             │
├─────────────────────────────────────┤
│  [Continue]                          │
└─────────────────────────────────────┘
```

**State Model** (already defined):
```dart
class WeeklySchedule {
  final DayAvailability monday;
  final DayAvailability tuesday;
  // ...
}

class DayAvailability {
  final bool isAvailable;
  final int startHour; // 0-23
  final int endHour;
}
```

**API Call**:
```dart
await ref.read(guideOnboardingDataProvider.notifier).saveAvailability(
  weeklySchedule: weeklySchedule,
  specificDates: specificDates,
);
```

**Navigation**: → `PaymentSetupScreen`

---

### Step 6: PaymentSetupScreen ⏳ NEEDS IMPLEMENTATION

**Current State**: Simple placeholder button

**Required Features**:

**Step 1: Choose Payout Method**
- Radio buttons:
  - [ ] Bank Transfer
  - [ ] MonCash

**If Bank Transfer Selected**:
```
Bank Name: [TextField]
Account Number: [TextField]
Account Holder Name: [TextField]
Routing Number (optional): [TextField]

[Verify Account] button (optional micro-deposit)
```

**If MonCash Selected**:
```
Phone Number: [TextField with +509 prefix]
Account Holder Name: [TextField]

[Verify Number] button (sends test amount)
```

**Security Notes**:
- Display: "Your payment info is encrypted"
- Show lock icon
- Terms: "We'll transfer earnings every Monday"

**State Models** (already defined):
```dart
class BankAccountInfo {
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String? routingNumber;
}

class MonCashInfo {
  final String phoneNumber;
  final String accountHolderName;
}
```

**API Call**:
```dart
await ref.read(guideOnboardingDataProvider.notifier).savePaymentSetup(
  payoutMethod: PayoutMethod.moncash,
  moncashNumber: '+509 1234 5678',
);
```

**Navigation**: → `ReviewScreen`

---

### Step 7: ReviewScreen ⏳ NEEDS IMPLEMENTATION

**Current State**: Basic stub

**Required Features**:

**Layout**:
- Scrollable summary of all steps
- Each section expandable/collapsible
- Edit button for each section
- Final submit button

**Sections**:

1. **Basic Information** [Edit]
   - Name: John Doe
   - Phone: +509 1234 5678 ✓ Verified
   - Email: john@example.com
   - Bio: (first 100 chars...)
   - [Profile Photo Preview]

2. **Identification** [Edit]
   - ID Type: NIF
   - Status: Pending Review ⏳
   - [Thumbnail images of ID front/back/selfie]

3. **Services** [Edit]
   - City Tour - $50
   - Airport Transfer - $30
   - (2 services total)

4. **Vehicle Information** [Edit] (if applicable)
   - 2020 Toyota Camry
   - License: ABC-1234
   - Capacity: 4 passengers
   - [Vehicle photo thumbnails]

5. **Availability** [Edit]
   - Mon-Fri: 9 AM - 5 PM
   - Sat-Sun: Unavailable

6. **Payment** [Edit]
   - MonCash: +509 **** **78
   - or
   - Bank: UniBank **** 5678

**Bottom Section**:
```
☐ I agree to GIDYO's Terms of Service and Community Guidelines

Expected Review Time: 2-3 business days

[Submit for Verification]
```

**API Call**:
```dart
await ref.read(guideOnboardingDataProvider.notifier).submitForReview();
```

**On Success**: Navigate to `UnderReviewScreen`

---

### UnderReviewScreen ⏳ NEEDS IMPLEMENTATION

**Current State**: Basic stub

**Required Features**:

**UI Design**:
```
┌────────────────────────────────────┐
│                                    │
│         [Clock Icon]               │
│                                    │
│    Application Under Review        │
│                                    │
│  Thank you for submitting your     │
│  guide application! Our team is    │
│  carefully reviewing your info.    │
│                                    │
├────────────────────────────────────┤
│  Estimated Wait Time               │
│  2-3 Business Days                 │
├────────────────────────────────────┤
│  What Happens Next:                │
│  1. ID Verification                │
│  2. Background Check               │
│  3. Service Review                 │
│  4. Approval Notification          │
├────────────────────────────────────┤
│  Submitted: Dec 15, 2025 2:30 PM   │
├────────────────────────────────────┤
│  [Check Status]  [Contact Support] │
└────────────────────────────────────┘
```

**Features**:
- Read-only view
- Real-time status updates
- Push notification setup
  - "We'll notify you when approved"
- Contact support button
- "Check Status" refreshes verification status

**Auto-redirect**:
When verification status changes to `approved`:
```dart
if (status == VerificationStatus.approved) {
  context.go('/guide/dashboard');
}
```

**Push Notification Trigger**:
- Admin approves → Send FCM notification
- App shows notification → User taps → Opens dashboard

---

## State Management

### GuideOnboardingNotifier

**Main Methods**:

```dart
// Step 1
Future<void> saveBasicInfo({...})
Future<String> uploadPhoto(String path, String filePath)
Future<String> sendOTP(String phone)
Future<bool> verifyOTP(String phone, String otp)

// Step 2
Future<void> saveIdentification({...})

// Step 3
Future<void> saveServices(List<ServiceOffering> services)

// Step 4
Future<void> saveVehicleInfo(VehicleInformation vehicleInfo)

// Step 5
Future<void> saveAvailability({
  WeeklySchedule? weeklySchedule,
  List<DateTime>? specificDates,
})

// Step 6
Future<void> savePaymentSetup({
  required PayoutMethod payoutMethod,
  BankAccountInfo? bankAccount,
  String? moncashNumber,
})

// Step 7
Future<void> submitForReview()

// Navigation
void goToStep(OnboardingStep step)
```

**Auto-save**: Each step saves to Supabase immediately upon completion

**Progress Tracking**:
```dart
final data = ref.watch(guideOnboardingDataProvider);

data.completedSteps // 0-6
data.completionPercentage // 0.0 to 1.0
data.currentStep // OnboardingStep enum
```

---

## Database Schema

### Tables Used

**1. `guide_profiles`**
```sql
CREATE TABLE guide_profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id),
  bio TEXT,
  rating DECIMAL(3,2) DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  total_trips INTEGER DEFAULT 0,
  languages TEXT[],
  certifications TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**2. `guide_verification`** (suggested new table)
```sql
CREATE TABLE guide_verification (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),

  -- Identification
  id_type TEXT, -- 'nif', 'passport', 'drivers_license'
  id_front_url TEXT,
  id_back_url TEXT,
  selfie_url TEXT,
  id_status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected'

  -- Vehicle (if applicable)
  vehicle_info JSONB,

  -- Status
  overall_status TEXT DEFAULT 'draft',
  submitted_at TIMESTAMPTZ,
  approved_at TIMESTAMPTZ,
  approved_by UUID REFERENCES users(id),
  rejection_reason TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**3. `guide_services`**
```sql
-- Already exists (see booking flow docs)
INSERT INTO guide_services (
  guide_id,
  service_type_id,
  price,
  description,
  included,
  is_active
) VALUES (...);
```

**4. `guide_vehicles`** (suggested)
```sql
CREATE TABLE guide_vehicles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  guide_id UUID REFERENCES users(id),
  vehicle_type TEXT,
  make TEXT,
  model TEXT,
  year INTEGER,
  license_plate TEXT,
  passenger_capacity INTEGER,
  photos TEXT[], -- URLs
  insurance_doc_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**5. `guide_availability`**
```sql
-- Already exists (see booking flow docs)
```

**6. `guide_payout_info`** (suggested)
```sql
CREATE TABLE guide_payout_info (
  user_id UUID PRIMARY KEY REFERENCES users(id),
  payout_method TEXT, -- 'bank_transfer', 'moncash'

  -- Bank info (encrypted)
  bank_name TEXT,
  account_number TEXT, -- encrypted
  account_holder_name TEXT,
  routing_number TEXT,

  -- MonCash info
  moncash_number TEXT, -- encrypted

  verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## File Upload Handling

### Storage Buckets

Create these buckets in Supabase:

1. **`guide-profiles`**
   - Profile photos
   - Public access
   - Max 5MB per file

2. **`guide-verification`**
   - ID photos (front, back)
   - Selfies
   - **Private access** (admin only)
   - Max 10MB per file

3. **`guide-vehicles`**
   - Vehicle photos
   - Insurance documents
   - Private access
   - Max 10MB per file

### Upload Function

Already implemented in `GuideOnboardingNotifier`:

```dart
Future<String> uploadPhoto(String path, String filePath) async {
  final datasource = _ref.read(guideOnboardingDatasourceProvider);
  return await datasource.uploadPhoto(path, filePath);
}

// In datasource:
Future<String> uploadPhoto(String bucketPath, String filePath) async {
  final file = File(filePath);
  final bytes = await file.readAsBytes();

  await _supabase.storage
      .from('guide-profiles')
      .uploadBinary(bucketPath, bytes);

  return _supabase.storage
      .from('guide-profiles')
      .getPublicUrl(bucketPath);
}
```

---

## Navigation Flow

```
Main Entry → GuideOnboardingScreen (router)
             ↓
       Check currentStep
             ↓
   ┌─────────┴─────────────────────────┐
   │                                   │
   ↓                                   ↓
BasicInfo                      UnderReviewScreen
   ↓                            (if status = pending)
Identification
   ↓
ServicesSetup
   ↓
   ├─ Has Vehicle Service? ──→ VehicleInfo ──┐
   │                                          │
   └─ No Vehicle ─────────────────────────────┤
                                              ↓
                                        Availability
                                              ↓
                                        PaymentSetup
                                              ↓
                                           Review
                                              ↓
                                      Submit for Review
                                              ↓
                                        UnderReviewScreen
                                              ↓
                                     (Wait for approval)
                                              ↓
                                       GuideDashboard
```

---

## Admin Review Workflow (Future)

### Admin Dashboard View

**Route**: `/admin/verifications`

**Features Needed**:
- List of pending verifications
- Sort by: Submission date, ID type
- For each application:
  - View all uploaded photos
  - Compare selfie to ID photo
  - Review services and pricing
  - Check vehicle info (if applicable)
  - View availability
  - Actions:
    - ✅ Approve
    - ❌ Reject (with reason)
    - 💬 Request more info

**Approval Process**:
1. Admin clicks "Approve"
2. Update `overall_status = 'approved'`
3. Send push notification to guide
4. Send welcome email
5. Guide can now access dashboard

**Rejection Process**:
1. Admin clicks "Reject"
2. Modal: "Reason for rejection"
3. Update `overall_status = 'rejected'`
4. Store rejection reason
5. Send notification with reason
6. Guide can edit and resubmit

---

## Testing Checklist

### Unit Tests

```dart
test('GuideOnboardingData validation works', () {
  final data = GuideOnboardingData(
    fullName: 'John Doe',
    phone: '+5091234567',
    phoneVerified: true,
    email: 'john@example.com',
    profilePhotoUrl: 'https://...',
    bio: 'I love guiding tourists...' * 10, // > 50 chars
  );

  expect(data.isBasicInfoComplete, true);
  expect(data.completedSteps, 1);
});

test('Vehicle info validation requires all fields', () {
  final vehicle = VehicleInformation(
    vehicleType: VehicleType.sedan,
    make: 'Toyota',
    model: 'Camry',
    year: 2020,
    licensePlate: 'ABC123',
    passengerCapacity: 4,
    vehiclePhotos: ['url1', 'url2'],
    insuranceDocumentUrl: 'url3',
  );

  expect(vehicle.isComplete, true);
});
```

### Integration Tests

```dart
testWidgets('Complete onboarding flow', (tester) async {
  // 1. Basic info
  await tester.enterText(find.byType(TextField).at(0), 'John Doe');
  await tester.enterText(find.byType(TextField).at(1), '+5091234567');
  // ... OTP verification
  await tester.tap(find.text('Continue'));

  // 2. Identification
  await tester.tap(find.text('NIF'));
  // ... Upload photos
  await tester.tap(find.text('Continue'));

  // ... Continue through all steps

  // Final: Submit
  await tester.tap(find.text('Submit for Verification'));
  await tester.pumpAndSettle();

  expect(find.text('Application Under Review'), findsOneWidget);
});
```

---

## Dependencies

Already included in `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.5.1      # State management
  supabase_flutter: ^2.8.0      # Backend
  image_picker: ^1.1.2          # Photo upload
  shared_preferences: ^2.3.2    # Local storage
  intl: ^0.19.0                 # Formatting
  table_calendar: ^3.1.2        # Availability calendar
```

---

## Next Steps to Complete

### Priority 1: Core Screens (1-2 days)

1. **VehicleInfoScreen** (~400 lines)
   - Copy structure from `BasicInfoScreen`
   - Add vehicle type chips
   - Add make/model/year/plate fields
   - Multiple photo upload
   - Insurance doc upload

2. **AvailabilityScreen** (~350 lines)
   - Weekly grid UI
   - Day toggle + time pickers
   - Or tab for specific dates calendar

3. **PaymentSetupScreen** (~300 lines)
   - Radio for bank/MonCash
   - Conditional forms
   - Validation

### Priority 2: Review & Status (1 day)

4. **ReviewScreen** (~400 lines)
   - Expandable sections
   - Edit navigation
   - Summary cards
   - Submit button

5. **UnderReviewScreen** (~200 lines)
   - Status UI
   - Expected wait time
   - Refresh button
   - Auto-redirect on approval

### Priority 3: Admin Tools (2-3 days)

6. **Admin Verification Dashboard**
   - List pending applications
   - Detailed review view
   - Approve/reject actions
   - Notification triggers

### Priority 4: Polish (1 day)

7. **Error Handling**
   - Network errors
   - Upload failures
   - Validation errors

8. **Loading States**
   - Skeleton screens
   - Progress indicators

9. **Animations**
   - Step transitions
   - Success celebrations

---

## Current Status Summary

**Total Lines**: ~1,603 (screens) + 371 (entities) + datasource + providers = ~2,500 lines

**Completion**: 60%

**What Works**:
- ✅ Steps 1-3 fully functional
- ✅ Data models complete
- ✅ State management complete
- ✅ API layer complete
- ✅ Photo uploads working
- ✅ OTP verification working

**What's Missing**:
- ⏳ Steps 4-7 need full UI implementation
- ⏳ Admin review tools
- ⏳ Push notifications
- ⏳ Email confirmations

**Estimated Time to 100%**: 4-6 days of development

---

## Usage Example

```dart
// In your app router
GoRoute(
  path: '/guide/onboarding',
  builder: (context, state) => const GuideOnboardingScreen(),
),

// User flow:
1. User registers as "Guide"
2. Redirected to /guide/onboarding
3. GuideOnboardingScreen shows current step
4. User completes each step
5. Data auto-saves to Supabase
6. Final submit → UnderReviewScreen
7. Admin approves → Navigate to /guide/dashboard
```

---

## Production Checklist

Before launching guide verification:

- [ ] Create all Supabase storage buckets
- [ ] Set up bucket permissions (private for verification)
- [ ] Implement RLS policies for guide tables
- [ ] Build admin review dashboard
- [ ] Set up FCM push notifications
- [ ] Create email templates (approval/rejection)
- [ ] Add SMS notifications for OTP
- [ ] Implement background check API (optional)
- [ ] Add ID verification AI (optional - AWS Rekognition)
- [ ] Create guide onboarding video/tutorial
- [ ] Write comprehensive guide handbook
- [ ] Test full flow end-to-end
- [ ] Security audit on photo uploads
- [ ] GDPR compliance for ID storage
- [ ] Create metrics dashboard (approval rate, time-to-review)

---

**Guide Onboarding Flow**: Partially complete, production-ready architecture, needs UI completion for steps 4-7.
