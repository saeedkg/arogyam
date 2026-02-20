# RealtimeKit SDK ProGuard Rules
# Keep all RealtimeKit classes and interfaces to prevent obfuscation
-keep class realtimekit.** { *; }
-keep interface realtimekit.** { *; }
-keepclassmembers class realtimekit.** { *; }
-dontwarn realtimekit.**

# Keep Flutter method channel classes
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep callback methods that might be called from native code
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep event listener interfaces
-keep interface * extends java.util.EventListener { *; }
-keepclassmembers class * implements java.util.EventListener {
    public <methods>;
}

# Keep WebRTC related classes (RealtimeKit likely uses WebRTC)
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# Keep Dyte SDK classes if RealtimeKit is based on Dyte
-keep class dyte.** { *; }
-keep interface dyte.** { *; }
-keepclassmembers class dyte.** { *; }
-dontwarn dyte.**
