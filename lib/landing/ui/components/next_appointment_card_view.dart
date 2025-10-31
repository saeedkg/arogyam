import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../_shared/ui/app_text.dart';
import '../../../appointment/entities/appointment.dart';

class _NextAppointmentCard extends StatelessWidget {
  final Appointment? appointment;
  const _NextAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    if (appointment == null) return const SizedBox.shrink();
    final a = appointment!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.video_call, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.label('Next Appointment', color: Colors.blue.shade700),
                const SizedBox(height: 6),
                AppText.titleMedium(a.doctorName),
                AppText.bodySmall(a.specialization, color: Colors.black54),
                const SizedBox(height: 8),
               // AppText.bodySmall('${a.startTime.day}/${a.startTime.month}/${a.startTime.year}  •  ${a.startTime.hour.toString().padLeft(2, '0')}:${a.startTime.minute.toString().padLeft(2, '0')}', color: Colors.black87),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(onPressed: () {}, child: const Text('Details')),
        ],
      ),
    );
  }
}
