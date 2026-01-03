import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../controller/family_member_controller.dart';

class AddPatientSheet extends StatefulWidget {
  const AddPatientSheet({super.key});

  @override
  State<AddPatientSheet> createState() => _AddPatientSheetState();
}

class _AddPatientSheetState extends State<AddPatientSheet>
    with TickerProviderStateMixin {
  final nameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? relation;
  String? gender = 'male';
  String? bloodGroup = 'O+';

  final List<String> relations = const ['self', 'spouse', 'child', 'parent', 'other'];
  final List<String> genders = const ['male', 'female', 'other'];
  final List<String> bloodGroups = const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    dobCtrl.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  top: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: AppColors.grey300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person_add_rounded,
                              color: AppColors.primaryGreen,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Add Family Member',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add a new member to your family profile',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildAnimatedFormField(
                        delay: 100,
                        child: _textField(
                          label: 'Full Name',
                          controller: nameCtrl,
                          icon: Icons.person_outline_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter full name' : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildAnimatedFormField(
                        delay: 200,
                        child: _dropdown(
                          label: 'Relationship',
                          value: relation,
                          items: relations,
                          icon: Icons.family_restroom_rounded,
                          onChanged: (v) => setState(() => relation = v),
                          validator: (v) => v == null ? 'Please select relationship' : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildAnimatedFormField(
                        delay: 300,
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: _textField(
                              label: 'Date of Birth',
                              controller: dobCtrl,
                              icon: Icons.calendar_today_rounded,
                              hint: 'Select date of birth',
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please select date of birth' : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildAnimatedFormField(
                        delay: 400,
                        child: Row(
                          children: [
                            Expanded(
                              child: _dropdown(
                                label: 'Gender',
                                value: gender,
                                items: genders,
                                icon: Icons.wc_rounded,
                                onChanged: (v) => setState(() => gender = v),
                                validator: null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _dropdown(
                                label: 'Blood Group',
                                value: bloodGroup,
                                items: bloodGroups,
                                icon: Icons.bloodtype_rounded,
                                onChanged: (v) => setState(() => bloodGroup = v),
                                validator: null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildAnimatedFormField(
                        delay: 500,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.grey300, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: AppColors.grey700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Add Member',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    final ctrl = Get.find<FamilyMemberController>();
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

  Widget _buildAnimatedFormField({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.grey500,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.grey600,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.errorRed, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.errorRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      _formatDropdownText(e),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          menuMaxHeight: 200,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppColors.grey600,
              size: 18,
            ),
            filled: true,
            fillColor: AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.errorRed, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.errorRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.grey600,
            size: 20,
          ),
        ),
      ],
    );
  }

  String _formatDropdownText(String text) {
    switch (text.toLowerCase()) {
      case 'self':
        return 'Self';
      case 'spouse':
        return 'Spouse';
      case 'child':
        return 'Child';
      case 'parent':
        return 'Parent';
      case 'other':
        return 'Other';
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      default:
        return text.toUpperCase();
    }
  }
}