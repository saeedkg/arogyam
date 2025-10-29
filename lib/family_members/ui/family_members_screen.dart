import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../controller/family_members_controller.dart';

class FamilyMembersBottomSheet extends StatefulWidget {
  const FamilyMembersBottomSheet({super.key});

  @override
  State<FamilyMembersBottomSheet> createState() => _FamilyMembersBottomSheetState();
}

class _FamilyMembersBottomSheetState extends State<FamilyMembersBottomSheet> {
  final c = Get.put(FamilyMembersController());

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.5;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Header row
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Patient',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: _showAddMemberSheet,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    color: AppColors.primaryGreen,
                    tooltip: 'Add',
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Content
              Expanded(
                child: Obx(() {
                  if (c.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (c.members.isEmpty) {
                    return _EmptyState(onAdd: _showAddMemberSheet);
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16, top: 8),
                    itemBuilder: (_, i) {
                      final m = c.members[i];
                      return _FamilyCard(
                        name: m.name,
                        relation: m.relation,
                        dob: m.dateOfBirth,
                        onTap: () => Get.back(result: m),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: c.members.length,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMemberSheet() {
    final nameCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    final dobCtrl = TextEditingController(); // yyyy-MM-dd
    final genderCtrl = TextEditingController();
    final bloodCtrl = TextEditingController();

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const Text('Add Family Member', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              _field('Name', nameCtrl),
              const SizedBox(height: 10),
              _field('Relation', relationCtrl, hint: 'spouse/child/self'),
              const SizedBox(height: 10),
              _field('Date of Birth', dobCtrl, hint: 'yyyy-MM-dd'),
              const SizedBox(height: 10),
              _field('Gender', genderCtrl, hint: 'male/female'),
              const SizedBox(height: 10),
              _field('Blood Group', bloodCtrl, hint: 'A+'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final ok = await c.addMember(
                      name: nameCtrl.text.trim(),
                      relation: relationCtrl.text.trim(),
                      dateOfBirth: dobCtrl.text.trim(),
                      gender: genderCtrl.text.trim(),
                      bloodGroup: bloodCtrl.text.trim(),
                    );
                    if (!mounted) return;
                    if (ok) {
                      Get.back();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint}) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_rounded, color: AppColors.primaryGreen, size: 34),
          ),
          const SizedBox(height: 12),
          const Text('No family members yet', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Add a member to book on their behalf', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAdd,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
              foregroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Member'),
          ),
        ],
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  final String name;
  final String relation;
  final String dob;
  final VoidCallback onTap;
  const _FamilyCard({required this.name, required this.relation, required this.dob, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryGreen),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(relation, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 6),
                      Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(dob, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}


