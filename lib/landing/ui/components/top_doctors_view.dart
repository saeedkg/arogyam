import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../entities/doctor.dart';

class TopDoctors extends StatelessWidget {
  final List<Doctor> doctors;
  const TopDoctors({required this.doctors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: doctors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final d = doctors[i];
              return Container(
                width: 180,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 8))
                ]),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(d.imageUrl, height: 120, width: 180, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(d.specialization, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          const SizedBox(height: 6),
                          Row(children: [const Icon(Icons.star_rounded, size: 16, color: Colors.amber), const SizedBox(width: 4), Text(d.rating.toString())])
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
