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
        title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Obx(() => Column(
            children: [
              const SizedBox(height: 8),
              _Tabs(index: c.tabIndex.value, onChanged: (i) => c.tabIndex.value = i),
              const SizedBox(height: 8),
              Expanded(
                child: c.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: c.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final b = c.items[i];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 8))],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_formatDate(b.dateTime), style: const TextStyle(fontWeight: FontWeight.w800)),
                                  const Divider(height: 20),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(b.imageUrl, width: 84, height: 84, fit: BoxFit.cover),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(b.doctorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                            const SizedBox(height: 4),
                                            Text(b.specialization, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 6),
                                            Row(children: [
                                              const Icon(Icons.place_outlined, size: 16, color: Colors.black54),
                                              const SizedBox(width: 4),
                                              Expanded(child: Text(b.clinic, style: const TextStyle(color: Colors.black54)))
                                            ]),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {},
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: const StadiumBorder(),
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black87,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: const StadiumBorder(),
                                          ),
                                          child: const Text('Reschedule'),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              )
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

