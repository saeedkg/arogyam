import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../controller/family_members_controller.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  final c = Get.put(FamilyMembersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Patient'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemberSheet,
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (c.members.isEmpty) {
          return const Center(child: Text('No family members yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (_, i) => _FamilyTile(
            name: c.members[i].name,
            relation: c.members[i].relation,
            dob: c.members[i].dateOfBirth,
            onTap: () => Get.back(result: c.members[i]),
          ),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: c.members.length,
        );
      }),
    );
  }

  void _showAddMemberSheet() {
    final nameCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    final dobCtrl = TextEditingController(); // yyyy-MM-dd
    final genderCtrl = TextEditingController();
    final bloodCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Family Member', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _field('Name', nameCtrl),
              const SizedBox(height: 8),
              _field('Relation', relationCtrl, hint: 'spouse/child/self'),
              const SizedBox(height: 8),
              _field('Date of Birth', dobCtrl, hint: 'yyyy-MM-dd'),
              const SizedBox(height: 8),
              _field('Gender', genderCtrl, hint: 'male/female'),
              const SizedBox(height: 8),
              _field('Blood Group', bloodCtrl, hint: 'A+'),
              const SizedBox(height: 12),
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
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint}) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _FamilyTile extends StatelessWidget {
  final String name;
  final String relation;
  final String dob;
  final VoidCallback onTap;
  const _FamilyTile({required this.name, required this.relation, required this.dob, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('$relation • $dob'),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}


