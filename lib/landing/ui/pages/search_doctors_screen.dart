import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../_shared/ui/app_text.dart';
import '../../controller/doctors_controller.dart';

class SearchDoctorsScreen extends StatelessWidget {
  const SearchDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DoctorsController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: Get.back),
        title: AppText.titleLarge('All Doctors'),
        centerTitle: true,
      ),
      body: Obx(() => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (v) => c.query.value = v,
                  decoration: InputDecoration(
                    hintText: 'Search doctor...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) {
                      final label = c.filters[i];
                      final active = c.activeFilter.value == label;
                      return ChoiceChip(
                        label: Text(label),
                        selected: active,
                        onSelected: (_) => c.activeFilter.value = label,
                        selectedColor: Colors.black87,
                        labelStyle: TextStyle(color: active ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                        shape: StadiumBorder(side: BorderSide(color: Colors.black12)),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: c.filters.length,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: c.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          itemCount: c.filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final d = c.filtered[i];
                            return Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 8))
                              ]),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(d.imageUrl, width: 96, height: 96, fit: BoxFit.cover),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(d.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                              ),
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(d.favorite ? Icons.favorite : Icons.favorite_border, color: Colors.black45),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(d.specialization, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                                          const SizedBox(height: 6),
                                          Row(children: [
                                            const Icon(Icons.place_outlined, size: 16, color: Colors.black54),
                                            const SizedBox(width: 4),
                                            Expanded(child: Text(d.hospital, style: const TextStyle(color: Colors.black54)))
                                          ]),
                                          const SizedBox(height: 6),
                                          Row(children: [
                                            const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(d.rating.toString()),
                                            const SizedBox(width: 8),
                                            Text(' | ${d.reviews} Reviews', style: const TextStyle(color: Colors.black54))
                                          ])
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          )),
    );
  }
}

