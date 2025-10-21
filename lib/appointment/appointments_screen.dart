import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../_shared/routing/routing.dart';
import '../landing/controller/bookings_controller.dart';
import 'components/appontment_card.dart';
import 'components/patient_card.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(BookingsController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded))],
      ),
      body: Obx(() => c.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PatientCard(
                  name: 'Jane Doe',
                  dob: '01/01/1990',
                  id: 'AXY789',
                  imageUrl: 'https://i.pravatar.cc/150?img=65',
                  onChange: () {},
                ),
                const SizedBox(height: 16),
                ...c.items.map((b) => AppointmentCard(
                      id: b.id,
                      imageUrl: b.imageUrl,
                      name: b.doctorName,
                      specialization: b.specialization,
                      date: _formatDate(b.dateTime),
                      //time: _formatTime(b.dateTime),
                  time: "12",
                      status: _statusFromList(b),
                      onView: () => AppNavigation.toAppointmentDetail(b.id),
                    )),
              ],
            )),
    );
  }

  String _formatDate(DateTime dt) {
    return '${_month(dt.month)} ${dt.day}, ${dt.year} - ${_pad(dt.hour)}.${_pad(dt.minute)} ${dt.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
  String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];
  String _statusFromList(b) {
    // lightweight mapping: upcoming -> Confirmed, completed -> Completed, canceled -> Pending
    switch (Get.find<BookingsController>().tabIndex.value) {
      case 0:
        return 'Confirmed';
      case 1:
        return 'Completed';
      default:
        return 'Pending';
    }
  }
}

class _Tabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _Tabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _chip('Upcoming', 0),
          const SizedBox(width: 8),
          _chip('Completed', 1),
          const SizedBox(width: 8),
          _chip('Canceled', 2),
        ],
      ),
    );
  }

  Widget _chip(String label, int i) {
    final active = index == i;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onChanged(i),
      selectedColor: Colors.black87,
      labelStyle: TextStyle(color: active ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
      shape: const StadiumBorder(side: BorderSide(color: Colors.black12)),
    );
  }
}





