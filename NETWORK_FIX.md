# Network Security Policy Fix

## Problem
The app was getting this error:
```
not permitted by network security policy
```

This happens because Android 9+ (API 28+) blocks cleartext (HTTP) traffic by default for security reasons.

## Solution Applied

### 1. Updated AndroidManifest.xml
Added two attributes to the `<application>` tag:
- `android:networkSecurityConfig="@xml/network_security_config"` - Points to our security config
- `android:usesCleartextTraffic="true"` - Allows HTTP traffic

Also added to `<activity>` tag:
- `android:enableOnBackInvokedCallback="true"` - Fixes back button warning

### 2. Created network_security_config.xml
Location: `android/app/src/main/res/xml/network_security_config.xml`

This file configures which domains can use HTTP (cleartext) traffic.

## Current Configuration (Development)
Currently allows HTTP for ALL domains - suitable for development and testing.

## For Production
Before releasing, update `network_security_config.xml` to only allow your specific API domains:

```xml
<domain-config cleartextTrafficPermitted="true">
    <domain includeSubdomains="true">api.yourdomain.com</domain>
</domain-config>
```

## Next Steps
1. Stop the app completely
2. Rebuild the app: `flutter clean && flutter run`
3. The network errors should be resolved

## Important Notes
- This fix allows HTTP traffic, which is less secure than HTTPS
- For production, always prefer HTTPS
- Only use HTTP for development or legacy systems that cannot be upgraded
- Update the config before releasing to production

## Network Security Config Details

The `network_security_config.xml` file structure:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Current: Allow cleartext for all domains (development) -->
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

### Production Configuration Example

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Only allow cleartext for specific domains -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">api.yourdomain.com</domain>
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">localhost</domain>
    </domain-config>
    
    <!-- All other domains require HTTPS -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

## References
- [Android Network Security Configuration](https://developer.android.com/training/articles/security-config)
- [Cleartext Traffic](https://developer.android.com/guide/topics/manifest/application-element#usesCleartextTraffic)

## Files Modified
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/xml/network_security_config.xml` (new)
