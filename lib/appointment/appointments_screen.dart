import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../landing/controller/bookings_controller.dart';
import 'components/appontment_card.dart';

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
                _PatientCard(
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
                      onView: () => Get.toNamed('/appointment_detail', arguments: b.id),
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

class _PatientCard extends StatelessWidget {
  final String name;
  final String dob;
  final String id;
  final String imageUrl;
  final VoidCallback onChange;
  const _PatientCard({required this.name, required this.dob, required this.id, required this.imageUrl, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFEFF8FF), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFD7EDFB))),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipOval(child: Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('DOB: $dob\nID: $id', style: const TextStyle(color: Colors.black54, height: 1.2)),
            ]),
          ),
          TextButton(
            onPressed: onChange,
            style: TextButton.styleFrom(backgroundColor: const Color(0xFF22C58B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Change Patient'),
          )
        ],
      ),
    );
  }
}



