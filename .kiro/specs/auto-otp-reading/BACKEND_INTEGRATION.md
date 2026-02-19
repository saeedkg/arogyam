# Backend Integration Guide for OTP Auto-Read

## Overview
The app now automatically sends the **app signature** (`e29y8cGDUM4`) to your backend when requesting OTP. Your backend needs to include this signature in the SMS message for automatic OTP reading to work.

## What Changed in the App

### API Request
When the app calls the `send-otp` API, it now includes an additional parameter:

**Before:**
```json
{
  "phone": "7306922302"
}
```

**After:**
```json
{
  "phone": "7306922302",
  "app_signature": "e29y8cGDUM4"
}
```

## What Backend Needs to Do

### 1. Accept the `app_signature` Parameter
Update your `/api/v1/auth/send-otp` endpoint to accept an optional `app_signature` parameter.

### 2. Include Signature in SMS Message

**Current SMS Format:**
```
Your ASKIT health verification code is 188448. Valid for 5 minutes. Do not share with anyone.
```

**New SMS Format (Required for Auto-Read):**
```
<#> Your ASKIT health verification code is 188448. Valid for 5 minutes. Do not share with anyone.
e29y8cGDUM4
```

### Important Format Rules:
1. Start with `<#>` followed by a space
2. Include your message text
3. End with the app signature on a new line or after the message
4. The signature MUST be exactly: `e29y8cGDUM4`

### Alternative Format (Also Works):
```
<#> Your ASKIT health verification code is 188448. Valid for 5 minutes. e29y8cGDUM4
```

## Example Backend Implementation

### Node.js/Express Example:
```javascript
app.post('/api/v1/auth/send-otp', async (req, res) => {
  const { phone, app_signature } = req.body;
  
  // Generate OTP
  const otp = generateOTP();
  
  // Build SMS message
  let smsMessage = `Your ASKIT health verification code is ${otp}. Valid for 5 minutes. Do not share with anyone.`;
  
  // Add app signature if provided (for Android auto-read)
  if (app_signature) {
    smsMessage = `<#> ${smsMessage}\n${app_signature}`;
  }
  
  // Send SMS
  await sendSMS(phone, smsMessage);
  
  res.json({
    success: true,
    message: "OTP sent successfully",
    method: "sms",
    expires_in: "300"
  });
});
```

### Python/Flask Example:
```python
@app.route('/api/v1/auth/send-otp', methods=['POST'])
def send_otp():
    data = request.json
    phone = data.get('phone')
    app_signature = data.get('app_signature')
    
    # Generate OTP
    otp = generate_otp()
    
    # Build SMS message
    sms_message = f"Your ASKIT health verification code is {otp}. Valid for 5 minutes. Do not share with anyone."
    
    # Add app signature if provided (for Android auto-read)
    if app_signature:
        sms_message = f"<#> {sms_message}\n{app_signature}"
    
    # Send SMS
    send_sms(phone, sms_message)
    
    return jsonify({
        "success": True,
        "message": "OTP sent successfully",
        "method": "sms",
        "expires_in": "300"
    })
```

### PHP/Laravel Example:
```php
public function sendOtp(Request $request)
{
    $phone = $request->input('phone');
    $appSignature = $request->input('app_signature');
    
    // Generate OTP
    $otp = $this->generateOTP();
    
    // Build SMS message
    $smsMessage = "Your ASKIT health verification code is {$otp}. Valid for 5 minutes. Do not share with anyone.";
    
    // Add app signature if provided (for Android auto-read)
    if ($appSignature) {
        $smsMessage = "<#> {$smsMessage}\n{$appSignature}";
    }
    
    // Send SMS
    $this->sendSMS($phone, $smsMessage);
    
    return response()->json([
        'success' => true,
        'message' => 'OTP sent successfully',
        'method' => 'sms',
        'expires_in' => '300'
    ]);
}
```

## Testing

### 1. Test Without Signature (Current Behavior)
If `app_signature` is not provided or is null, send SMS in the old format:
```
Your ASKIT health verification code is 188448. Valid for 5 minutes. Do not share with anyone.
```
**Result:** User must manually enter OTP

### 2. Test With Signature (New Behavior)
If `app_signature` is provided, send SMS in the new format:
```
<#> Your ASKIT health verification code is 188448. Valid for 5 minutes. Do not share with anyone.
e29y8cGDUM4
```
**Result:** OTP auto-fills automatically on Android

## Benefits

### For Users:
- ✅ No manual OTP entry needed
- ✅ Faster login experience
- ✅ Fewer typing errors
- ✅ No SMS permission required

### For Backend:
- ✅ Backward compatible (works with old app versions)
- ✅ Simple implementation
- ✅ No additional API endpoints needed
- ✅ Works with existing SMS provider

## Backward Compatibility

The implementation is fully backward compatible:
- **Old app versions**: Will send requests without `app_signature`, backend sends SMS in old format
- **New app versions**: Will send requests with `app_signature`, backend sends SMS in new format
- **iOS devices**: Will send requests with `app_signature` but it won't be used (iOS has its own autofill)

## SMS Provider Compatibility

This works with all SMS providers:
- Twilio
- AWS SNS
- Firebase Cloud Messaging
- MSG91
- TextLocal
- Any custom SMS gateway

The signature is just part of the message text, so no special SMS provider features are needed.

## Troubleshooting

### OTP Not Auto-Filling
1. **Check SMS format**: Ensure it starts with `<#>` and ends with the signature
2. **Verify signature**: Must be exactly `e29y8cGDUM4`
3. **Check spacing**: Signature should be on a new line or after the message
4. **Test on Android 8.0+**: Feature only works on Android 8.0 and above

### SMS Not Delivered
1. **Check message length**: Keep total message under 160 characters if possible
2. **Test without signature first**: Ensure basic SMS delivery works
3. **Verify phone number format**: Ensure correct country code

## Security Notes

1. **App signature is public**: It's not a secret, it's safe to include in SMS
2. **No security risk**: The signature only helps Android identify which app should receive the OTP
3. **OTP remains secure**: The actual OTP is still the security mechanism
4. **Signature is app-specific**: Each app has a unique signature

## Questions?

If you have any questions about the implementation, please contact the mobile development team.

## Summary

**What you need to do:**
1. Accept `app_signature` parameter in your send-otp API
2. When `app_signature` is provided, format SMS as: `<#> [your message] [signature]`
3. Deploy and test

**Expected timeline:** 1-2 hours of development + testing
