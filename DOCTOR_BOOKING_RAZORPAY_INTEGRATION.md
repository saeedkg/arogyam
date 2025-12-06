# Doctor Booking Razorpay Payment Integration

## Overview
Successfully integrated Razorpay payment flow into the DoctorBookingScreen for video consultation appointments, following the same pattern as instant consultation.

## Implementation Summary

### 1. New Entity Files Created

#### `lib/booking/entities/video_consultation_pricing.dart`
- Handles pricing information from `/patient/video-consultation/pricing` API
- Fields: consultationFee, platformFee, platformFeePercentage, totalAmount

#### `lib/booking/entities/video_consultation_payment_order.dart`
- Handles payment order creation response from `/patient/video-consultation/create-order` API
- Fields: orderId, amount, amountInPaise, currency, razorpayKey, pricing

#### `lib/booking/entities/video_consultation_complete_payment_response.dart`
- Handles payment completion response from `/patient/video-consultation/complete` API
- Fields: appointmentId, message

### 2. Service Layer Updates (`lib/booking/service/booking_service.dart`)

Added three new API methods:

#### `fetchVideoConsultationPricing(String doctorId)`
- GET `/patient/video-consultation/pricing?doctor_id={doctorId}`
- Returns: VideoConsultationPricing

#### `createVideoConsultationOrder(...)`
- POST `/patient/video-consultation/create-order`
- Parameters: doctor_id, scheduled_at, family_member_id (optional)
- Returns: VideoConsultationPaymentOrder

#### `completeVideoConsultationPayment(...)`
- POST `/patient/video-consultation/complete`
- Parameters: razorpay_payment_id, razorpay_order_id, razorpay_signature, doctor_id, scheduled_at, family_member_id (optional), patient_notes (optional)
- Returns: VideoConsultationCompletePaymentResponse

### 3. Controller Updates (`lib/booking/controller/booking_controller.dart`)

#### New Features:
- Razorpay instance initialization and event handlers
- Pricing loading functionality
- Payment initiation with context storage
- Payment success/error/wallet handlers

#### New Methods:
- `loadPricing(String doctorId)` - Fetches and stores pricing
- `initiatePayment(...)` - Creates order and opens Razorpay checkout
- `_handlePaymentSuccess(...)` - Completes payment and creates appointment
- `_handlePaymentError(...)` - Handles payment failures
- `_handleExternalWallet(...)` - Handles external wallet selection

#### New Observable Properties:
- `isPricingLoading` - Loading state for pricing
- `pricing` - Stores pricing information
- `appointmentId` - Stores created appointment ID after payment

### 4. UI Updates (`lib/booking/ui/doctor_booking_screen.dart`)

#### Changes:
1. **Pricing Load on Init**: Calls `bookingController.loadPricing(widget.doctorId)` in initState
2. **New Payment Details Section**: Added `_PaymentDetailsSection` widget showing:
   - Consultation Fee
   - Platform Fee with percentage
   - Total Amount (highlighted in green)
3. **Updated Bottom Button**:
   - Changed text to "Proceed to Payment"
   - Calls `initiatePayment()` instead of old booking flow
   - Added payment success/error listeners with navigation
4. **Enhanced Bottom Bar**: Added shadow and proper styling

#### New Component:
`_PaymentDetailsSection` - Displays pricing breakdown with loading states

## Payment Flow

1. **User selects date/time slot**
2. **Pricing loads automatically** (on screen init)
3. **User taps "Proceed to Payment"**
4. **Create Order API** is called with doctor_id, scheduled_at, family_member_id
5. **Razorpay Checkout** opens with order details
6. **User completes payment**
7. **Complete Payment API** is called with payment details
8. **Appointment created** and user navigated to pending consultation screen

## Error Handling

- Network failures show appropriate error messages
- Payment failures display Razorpay error messages
- API errors are caught and displayed in dialogs
- Loading states prevent multiple submissions

## UI/UX Improvements

- Clean pricing breakdown matching app theme
- Green accent colors throughout (AppColors.primaryGreen)
- Loading indicators for pricing and payment
- Smooth navigation after successful payment
- Error dialogs for failed payments

## API Integration

All three required APIs are integrated:
1. ✅ GET `/patient/video-consultation/pricing?doctor_id={id}`
2. ✅ POST `/patient/video-consultation/create-order`
3. ✅ POST `/patient/video-consultation/complete`

## Testing Checklist

- [ ] Pricing loads correctly for different doctors
- [ ] Payment order creation works
- [ ] Razorpay checkout opens with correct details
- [ ] Payment success creates appointment
- [ ] Payment failure shows error message
- [ ] Navigation works after successful payment
- [ ] Loading states display correctly
- [ ] Error handling works for all scenarios
