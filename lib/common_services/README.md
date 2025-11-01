# Common Services Module

This module contains shared services, entities, and controllers used across the application.

## Specialization Service

Fetches medical specializations from the API.

### Usage Example

```dart
// In your binding or main.dart
Get.put(SpecializationController());

// In your widget
class SpecializationListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpecializationController>();
    
    return Obx(() {
      if (controller.isLoading.value) {
        return CircularProgressIndicator();
      }
      
      if (controller.errorMessage.value != null) {
        return Text('Error: ${controller.errorMessage.value}');
      }
      
      return ListView.builder(
        itemCount: controller.specializations.length,
        itemBuilder: (context, index) {
          final spec = controller.specializations[index];
          return ListTile(
            leading: spec.icon != null 
              ? Icon(Icons.medical_services) 
              : null,
            title: Text(spec.name),
          );
        },
      );
    });
  }
}
```

### Entity Fields

- `id` (int): Unique identifier
- `name` (String): Specialization name
- `icon` (String?): Icon identifier (optional)

---

## Doctor Service

Fetches doctors list from the API with essential information.

### Usage Example

```dart
// In your binding or main.dart
Get.put(DoctorController());

// In your widget
class DoctorListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorController>();
    
    return Obx(() {
      if (controller.isLoading.value) {
        return CircularProgressIndicator();
      }
      
      if (controller.errorMessage.value != null) {
        return Text('Error: ${controller.errorMessage.value}');
      }
      
      return ListView.builder(
        itemCount: controller.doctors.length,
        itemBuilder: (context, index) {
          final doctor = controller.doctors[index];
          return ListTile(
            title: Text(doctor.name),
            subtitle: Text(doctor.qualifications.join(', ')),
            trailing: Text('₹${doctor.consultationFee}'),
          );
        },
      );
    });
  }
}
```

### Entity Fields

- `id` (int): Unique identifier
- `name` (String): Doctor name
- `qualifications` (List<String>): List of qualifications (e.g., MBBS, MD)
- `consultationFee` (double): Consultation fee amount
- `totalConsultations` (int): Total number of consultations
- `averageRating` (double): Average rating
- `totalRatings` (int): Total number of ratings
