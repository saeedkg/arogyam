# Video Call Files Mapping - Doctor App vs Patient App

## Overview
This document maps all video call related files between the working doctor app and the broken patient app.

## File Structure Comparison

### Doctor App Structure
```
E:\JetPckProject\askitdoctor_flutter\lib\consultation\
├── constants/
├── controller/
│   ├── minimized_call_manager.dart
│   └── realtimekit_video_call_controller.dart
├── entities/
│   ├── connection_state.dart
│   ├── consultation_pricing.dart
│   ├── corner_position.dart
│   ├── end_call_option.dart
│   ├── minimized_call_state.dart
│   ├── participant_event.dart ⭐ (PATIENT APP MISSING)
│   ├── video_call_config.dart
│   └── video_call_error.dart
├── service/
│   ├── consultation_service.dart ⭐ (PATIENT APP MISSING)
│   ├── dyte_service.dart
│   └── realtimekit_service.dart
├── ui/
│   ├── widgets/
│   │   └── end_call_options_dialog.dart ⭐ (PATIENT APP MISSING)
│   ├── instant_consult_screen.dart
│   ├── minimized_call_widget.dart
│   └── realtimekit_video_call_screen.dart
├── utils/
│   └── permission_handler.dart
├── INSTANT_CONSULT_README.md
└── README.md
```

### Patient App Structure
```
lib/consultation/
├── controller/
│   ├── minimized_call_manager.dart
│   └── realtimekit_video_call_controller.dart
├── entities/
│   ├── connection_state.dart
│   ├── corner_position.dart
│   ├── minimized_call_state.dart
│   ├── video_call_config.dart
│   └── video_call_error.dart
├── service/
│   ├── dyte_service.dart
│   └── realtimekit_service.dart
├── ui/
│   ├── minimized_call_widget.dart
│   └── realtimekit_video_call_screen.dart
├── utils/
│   └── permission_handler.dart
└── README.md
```

## File-by-File Mapping

### Controllers
| Doctor App | Patient App | Status |
|------------|-------------|--------|
| controller/minimized_call_manager.dart | controller/minimized_call_manager.dart | ✅ EXISTS |
| controller/realtimekit_video_call_controller.dart | controller/realtimekit_video_call_controller.dart | ✅ EXISTS |

### Entities
| Doctor App | Patient App | Status |
|------------|-------------|--------|
| entities/connection_state.dart | entities/connection_state.dart | ✅ EXISTS |
| entities/consultation_pricing.dart | ❌ MISSING | ⚠️ NOT IN PATIENT APP |
| entities/corner_position.dart | entities/corner_position.dart | ✅ EXISTS |
| entities/end_call_option.dart | ❌ MISSING | ⚠️ NOT IN PATIENT APP |
| entities/minimized_call_state.dart | entities/minimized_call_state.dart | ✅ EXISTS |
| entities/participant_event.dart | ❌ MISSING | 🔴 CRITICAL - VIDEO CALL RELATED |
| entities/video_call_config.dart | entities/video_call_config.dart | ✅ EXISTS |
| entities/video_call_error.dart | entities/video_call_error.dart | ✅ EXISTS |

### Services
| Doctor App | Patient App | Status |
|------------|-------------|--------|
| service/consultation_service.dart | ❌ MISSING | ⚠️ NOT IN PATIENT APP |
| service/dyte_service.dart | service/dyte_service.dart | ✅ EXISTS |
| service/realtimekit_service.dart | service/realtimekit_service.dart | ✅ EXISTS |

### UI/Screens
| Doctor App | Patient App | Status |
|------------|-------------|--------|
| ui/instant_consult_screen.dart | ❌ MISSING | ⚠️ NOT IN PATIENT APP (different feature) |
| ui/minimized_call_widget.dart | ui/minimized_call_widget.dart | ✅ EXISTS |
| ui/realtimekit_video_call_screen.dart | ui/realtimekit_video_call_screen.dart | ✅ EXISTS |
| ui/widgets/end_call_options_dialog.dart | ❌ MISSING | ⚠️ NOT IN PATIENT APP |

### Utils
| Doctor App | Patient App | Status |
|------------|-------------|--------|
| utils/permission_handler.dart | utils/permission_handler.dart | ✅ EXISTS |

## Critical Files to Compare (Core Video Call Functionality)

### Priority 1: MUST COMPARE (Core reconnection logic)
1. ✅ **service/realtimekit_service.dart** - SDK initialization, disposal, stream management
2. ✅ **controller/realtimekit_video_call_controller.dart** - Controller lifecycle, GetX patterns
3. ✅ **ui/realtimekit_video_call_screen.dart** - Screen initialization, controller access
4. ✅ **entities/video_call_config.dart** - Configuration data model
5. 🔴 **entities/participant_event.dart** - MISSING in patient app (may be critical!)

### Priority 2: SHOULD COMPARE (Supporting functionality)
6. ✅ **entities/connection_state.dart** - Connection state management
7. ✅ **entities/video_call_error.dart** - Error handling
8. ✅ **controller/minimized_call_manager.dart** - Call state management
9. ✅ **entities/minimized_call_state.dart** - Minimized call state
10. ✅ **entities/corner_position.dart** - UI positioning

### Priority 3: MAY COMPARE (Less likely to affect reconnection)
11. ✅ **ui/minimized_call_widget.dart** - Minimized UI
12. ✅ **utils/permission_handler.dart** - Permissions
13. ✅ **service/dyte_service.dart** - Alternative video service

## Missing Files Analysis

### Critical Missing File
- **entities/participant_event.dart** - This file exists in doctor app but NOT in patient app
  - This could be CRITICAL for handling participant join/leave events
  - May be required for proper SDK callback handling
  - Could explain why reconnection fails (SDK expects this event handling)

### Non-Critical Missing Files (Different Features)
- **entities/consultation_pricing.dart** - Pricing logic (doctor-specific)
- **entities/end_call_option.dart** - End call options (UI feature)
- **service/consultation_service.dart** - Consultation management (different feature)
- **ui/instant_consult_screen.dart** - Instant consultation (different feature)
- **ui/widgets/end_call_options_dialog.dart** - End call dialog (UI feature)

## Next Steps

1. **Compare Priority 1 files** (Tasks 2.1-2.4)
   - Read both versions of each file
   - Document line-by-line differences
   - Identify critical differences in:
     - SDK initialization patterns
     - GetX controller lifecycle
     - Stream management
     - Disposal patterns

2. **Investigate participant_event.dart**
   - Read doctor app version
   - Determine if it's required for video calls
   - Check if patient app has alternative implementation
   - If critical, add to patient app

3. **Analyze GetX registration patterns**
   - Search for where controllers are registered in both apps
   - Compare permanent vs temporary registration
   - Compare deletion strategies

4. **Generate detailed comparison report**
   - Compile all findings
   - Identify root cause hypothesis
   - Create fix strategy

## Files to Read for Analysis

### From Doctor App (via PowerShell commands)
```
E:\JetPckProject\askitdoctor_flutter\lib\consultation\service\realtimekit_service.dart
E:\JetPckProject\askitdoctor_flutter\lib\consultation\controller\realtimekit_video_call_controller.dart
E:\JetPckProject\askitdoctor_flutter\lib\consultation\ui\realtimekit_video_call_screen.dart
E:\JetPckProject\askitdoctor_flutter\lib\consultation\entities\video_call_config.dart
E:\JetPckProject\askitdoctor_flutter\lib\consultation\entities\participant_event.dart
E:\JetPckProject\askitdoctor_flutter\lib\consultation\entities\connection_state.dart
E:\JetPckProject\askitdoctor_flutter\lib\consultation\entities\video_call_error.dart
```

### From Patient App (current workspace)
```
lib/consultation/service/realtimekit_service.dart
lib/consultation/controller/realtimekit_video_call_controller.dart
lib/consultation/ui/realtimekit_video_call_screen.dart
lib/consultation/entities/video_call_config.dart
lib/consultation/entities/connection_state.dart
lib/consultation/entities/video_call_error.dart
```
