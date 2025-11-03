import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../controller/chose_patient_controller.dart';

class AddPatientSheet extends StatefulWidget {
  const AddPatientSheet({super.key});

  @override
  State<AddPatientSheet> createState() => _AddPatientSheetState();
}

class _AddPatientSheetState extends State<AddPatientSheet> {
  final nameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? relation;
  String? gender;
  String? bloodGroup;

  final List<String> relations = const ['self', 'spouse', 'child', 'parent', 'other'];
  final List<String> genders = const ['male', 'female', 'other'];
  final List<String> bloodGroups = const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 8,
        ),
        child: Form(
          key: _formKey,
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

              _textField(
                label: 'Name',
                controller: nameCtrl,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),

              _dropdown(
                label: 'Relation',
                value: relation,
                items: relations,
                onChanged: (v) => setState(() => relation = v),
                validator: (v) => v == null ? 'Select relation' : null,
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: _textField(
                    label: 'Date of Birth',
                    controller: dobCtrl,
                    hint: 'yyyy-MM-dd',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Select date' : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _dropdown(
                label: 'Gender',
                value: gender,
                items: genders,
                onChanged: (v) => setState(() => gender = v),
                validator: (v) => v == null ? 'Select gender' : null,
              ),
              const SizedBox(height: 12),

              _dropdown(
                label: 'Blood Group',
                value: bloodGroup,
                items: bloodGroups,
                onChanged: (v) => setState(() => bloodGroup = v),
                validator: (v) => v == null ? 'Select blood group' : null,
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
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
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = now.subtract(const Duration(days: 365 * 20));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primaryGreen),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      dobCtrl.text = '$y-$m-$d';
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = Get.find<ChosePatientController>();
    final ok = await ctrl.addMember(
      name: nameCtrl.text.trim(),
      relation: relation!,
      dateOfBirth: dobCtrl.text.trim(),
      gender: gender!,
      bloodGroup: bloodGroup!,
    );
    if (!mounted) return;
    if (ok) Get.back();
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
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

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem<String>(
                value: e,
                child: Text(e.toUpperCase()),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
    );
  }
}


