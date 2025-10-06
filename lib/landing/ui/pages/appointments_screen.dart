import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/bookings_controller.dart';

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
                ...c.items.map((b) => _AppointmentTile(
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

class _AppointmentTile extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String name;
  final String specialization;
  final String date;
  final String time;
  final String status; // Confirmed, Pending, Completed
  final VoidCallback onView;

  const _AppointmentTile({required this.id, required this.imageUrl, required this.name, required this.specialization, required this.date, required this.time, required this.status, required this.onView});

  Color get _statusColor => status == 'Confirmed' ? const Color(0xFFB4F06E) : status == 'Completed' ? const Color(0xFF5EC9E7) : const Color(0xFFFF944D);
  Color get _statusTextColor => Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(16)), child: Text(status, style: TextStyle(color: _statusTextColor, fontWeight: FontWeight.w600)))
              ]),
              const SizedBox(height: 4),
              Text(specialization, style: const TextStyle(color: Colors.black54)),
            ]))
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.event, size: 16, color: Colors.black54),
            const SizedBox(width: 6),
            Text(date),
            const SizedBox(width: 16),
            const Icon(Icons.access_time, size: 16, color: Colors.black54),
            const SizedBox(width: 6),
            Text(time.toUpperCase()),
          ]),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(onPressed: onView, icon: const Icon(Icons.chevron_right_rounded), label: const Text('View Details')),
          )
        ]),
      ),
    );
  }
}

